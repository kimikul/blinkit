//
//  BIFacebookUserManager.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/30/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIFacebookUserManager.h"
#import "BIDataStore.h"

@implementation BIFacebookUserManager

- (void)fetchAndSaveBasicUserInfo {
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
            
            [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [self.delegate facebookManager:self didSaveUser:currentUser withError:error];
            }];
        }
    }];
}

- (void)fetchAndSaveFriends {
    FBRequest *friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {

        // clear friends and save new list
        [BIDataStore shared].fbFriends = [NSMutableDictionary new];
        
        NSArray *friends = result[@"data"];
        for (NSDictionary<FBGraphUser>* friend in friends) {
            [[BIDataStore shared].fbFriends setObject:friend forKey:friend.id];
        }
        
        [self.delegate facebookManager:self didRefreshFriendsList:[BIDataStore shared].fbFriends withError:error];
    }];
}

@end
