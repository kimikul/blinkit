//
//  BIFollowManager.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/31/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIFollowManager.h"

@implementation BIFollowManager

#pragma mark - follow request

+ (void)refreshRequestToFollowList {
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [query whereKey:@"type" equalTo:@"request to follow"];
    [query includeKey:@"toUser"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableArray *requestsToFollow = [NSMutableArray new];
            for (PFObject *activity in objects) {
                PFUser *user = activity[@"toUser"];
                NSString *fbID = user[@"facebookID"];
                if (fbID) {
                    [requestsToFollow addObject:fbID];
                }
            }
            
            [[BIDataStore shared] setRequestedFriends:[requestsToFollow copy]];
        }
    }];
}

+ (void)requestToFollowUserEventually:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    if ([[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        return;
    }
    
    // Create follow activity
    PFObject *requestFollowActivity = [PFObject objectWithClassName:@"Activity"];
    [requestFollowActivity setObject:[PFUser currentUser] forKey:@"fromUser"];
    [requestFollowActivity setObject:user forKey:@"toUser"];
    [requestFollowActivity setObject:@"request to follow" forKey:@"type"];
    
    [requestFollowActivity saveEventually:completionBlock];
}

+ (void)cancelRequestToFollowUserEventually:(PFUser *)user block:(void (^)(NSError *error))completionBlock {
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [query whereKey:@"toUser" equalTo:user];
    [query whereKey:@"type" equalTo:@"request to follow"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *requestToFollowActivities, NSError *error) {
        
        if (!error) {
            for (PFObject *requestToFollowActivity in requestToFollowActivities) {
                [requestToFollowActivity deleteEventually];
            }
            
            if (completionBlock) {
                completionBlock(error);
            }
        }
    }];
}

#pragma mark - follow

+ (void)followUserEventually:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    if ([[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        return;
    }
    
    // Create follow activity
    PFObject *followActivity = [PFObject objectWithClassName:@"Activity"];
    [followActivity setObject:[PFUser currentUser] forKey:@"fromUser"];
    [followActivity setObject:user forKey:@"toUser"];
    [followActivity setObject:@"follow" forKey:@"type"];
    
    [followActivity saveEventually:completionBlock];
}

+ (void)unfollowUserEventually:(PFUser *)user block:(void (^)(NSError *error))completionBlock {
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [query whereKey:@"toUser" equalTo:user];
    [query whereKey:@"type" equalTo:@"follow"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *followActivities, NSError *error) {
        
        if (!error) {
            for (PFObject *followActivity in followActivities) {
                [followActivity deleteEventually];
            }
            
            if (completionBlock) {
                completionBlock(error);
            }
        }
    }];
}

+ (void)refreshFollowingList {
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [query whereKey:@"type" equalTo:@"follow"];
    [query includeKey:@"toUser"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableArray *followedFriends = [NSMutableArray new];
            for (PFObject *activity in objects) {
                PFUser *user = activity[@"toUser"];
                NSString *fbID = user[@"facebookID"];
                if (fbID) {
                    [followedFriends addObject:fbID];
                }
            }
            
            [[BIDataStore shared] setFollowedFriends:[followedFriends copy]];
        }
    }];
}

@end
