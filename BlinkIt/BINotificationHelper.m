//
//  BINotificationHelper.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 2/12/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BINotificationHelper.h"
#import "BIAppDelegate.h"

@implementation BINotificationHelper

+ (void)fetchBadgeCount {
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query whereKey:@"toUser" equalTo:[PFUser currentUser]];
    [query whereKey:@"type" equalTo:@"request to follow"];
    [query countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        [self updateBadgeCount:count];
    }];
}

+ (void)updateBadgeCount:(NSInteger)count {
    // update tab badge
    BIAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    UITabBarController *tabBarController = (UITabBarController*)appDelegate.window.rootViewController;
    [[tabBarController.tabBar.items objectAtIndex:0] setBadgeValue:[NSString stringWithFormat:@"%d",count]];
    
    // update app badge
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:count];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kBIUpdateHomeNotificationBadgeNotification object:@(count)];
}

@end
