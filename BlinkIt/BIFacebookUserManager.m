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

            currentUser[@"name"] = userData[@"name"];
            currentUser[@"location"] = userData[@"location"][@"name"];
            currentUser[@"gender"] = userData[@"gender"];
            currentUser[@"email"] = userData[@"email"];
            currentUser[@"username"] = userData[@"email"];
            currentUser[@"facebookID"] = facebookID;
            
            NSString *pictureURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID];
            currentUser[@"photoURL"] = pictureURL;
            
            // save fb info into parse user
            [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (completionBlock) {
                    completionBlock(succeeded,error);
                }
            }];
        }
    }];
}

- (void)fetchAndSaveFriendsForUser:(PFUser*)user block:(void (^)(NSDictionary *friendDict, NSError *error))completionBlock {
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
        
        // call completion block with friends dict
        if (completionBlock) {
            completionBlock(fbFriendsDict, error);
        }
    }];
}

@end
