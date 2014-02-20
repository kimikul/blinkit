//
//  BIFacebookUserManager.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/30/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIFacebookUserManager.h"

@implementation BIFacebookUserManager

static BIFacebookUserManager *shared = nil;

+ (BIFacebookUserManager*)shared {
    @synchronized (self) {
        if (!shared) {
            shared = [[BIFacebookUserManager alloc] init];
        }
    }
    
    return shared;
}

- (void)fetchAndSaveBasicUserInfoWithBlock:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    FBRequest *request = [FBRequest requestForMe];
    
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            NSDictionary *userData = (NSDictionary *)result;
            
            PFUser *currentUser = [PFUser currentUser];
            
            NSString *facebookID = userData[@"id"];
            NSString *name = userData[@"name"];
            NSString *location = userData[@"location"][@"name"];
            NSString *gender = userData[@"gender"];
            NSString *email = userData[@"email"];
            
            currentUser[@"name"] = name ? name : @"";
            currentUser[@"location"] = location ? location : @"";
            currentUser[@"gender"] = gender ? gender : @"";
            currentUser[@"email"] = email ? [email lowercaseString] : @"";
            currentUser[@"username"] = email ? [email lowercaseString] : @"";
            currentUser[@"facebookID"] = facebookID ? facebookID : @"";
            
            NSString *pictureURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square&return_ssl_resources=1&width=100&height=100", facebookID];
            currentUser[@"photoURL"] = pictureURL ? pictureURL : @"";
            
            // save fb info into parse user
            [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (completionBlock) {
                    completionBlock(succeeded,error);
                }
            }];
        }
    }];
}

- (void)refreshCurrentUserFacebookFriends {
    FBRequest *friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {

        // create facebook friends dict
        NSMutableDictionary *fbFriendsDict = [NSMutableDictionary new];
        
        NSArray *friends = result[@"data"];
        for (NSDictionary<FBGraphUser>* friend in friends) {
            [fbFriendsDict setObject:friend forKey:friend.id];
        }
        
        if (!error) {
            [[BIDataStore shared] setFacebookFriends:[fbFriendsDict copy]];
        }
    }];
}

@end
