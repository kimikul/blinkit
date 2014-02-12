//
//  BINotificationHelper.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 2/12/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BINotificationHelper.h"

@implementation BINotificationHelper

+ (void)addNotificationFromUser:(PFUser*)fromUser toUser:(PFUser*)toUser type:(NSString*)type {
    PFObject *notification = [PFObject objectWithClassName:@"Notification"];
    [notification setObject:fromUser forKey:@"fromUser"];
    [notification setObject:toUser forKey:@"toUser"];
    [notification setObject:type forKey:@"type"];
    [notification saveEventually:nil];
}

+ (void)refreshNotificationsWithCompletion:(void (^)(NSArray*notifications, NSError* error))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Notification"];
    [query whereKey:@"toUser" equalTo:[PFUser currentUser]];
    [query includeKey:@"fromUser"];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (completion) completion(objects, error);
    }];
}

@end
