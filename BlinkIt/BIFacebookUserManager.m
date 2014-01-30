//
//  BIFacebookUserManager.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/30/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIFacebookUserManager.h"

@implementation BIFacebookUserManager

- (void)fetchAndSaveBasicUserInfo {
    FBRequest *request = [FBRequest requestForMe];
    
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            NSDictionary *userData = (NSDictionary *)result;
            
            PFUser *currentUser = [PFUser currentUser];
            currentUser[@"name"] = userData[@"name"];
            currentUser[@"location"] = userData[@"location"][@"name"];
            currentUser[@"gender"] = userData[@"gender"];
            currentUser[@"email"] = userData[@"email"];
            
            NSString *facebookID = userData[@"id"];
            NSString *pictureURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID];
            currentUser[@"photoURL"] = pictureURL;
            
            [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [self.delegate facebookManager:self didSaveUser:currentUser withError:error];
            }];
        }
    }];
}

@end
