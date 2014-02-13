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

#pragma mark - badge counts

+ (void)fetchAndUpdateBadgeCountWithCompletion:(void (^)(UIBackgroundFetchResult))completion {
    if (![PFUser currentUser]) return;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query whereKey:@"toUser" equalTo:[PFUser currentUser]];
    [query whereKey:@"type" equalTo:@"request to follow"];
    [query countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        if (!error) {
            [self updateBadgeCount:count];
            if (completion) { completion(UIBackgroundFetchResultNewData); }
        } else {
            if (completion) { completion(UIBackgroundFetchResultFailed); }
        }
        
    }];
}

+ (void)updateBadgeCount:(NSInteger)count {
    // update tab badge
    BIAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    UITabBarController *tabBarController = (UITabBarController*)appDelegate.window.rootViewController;
    NSString *tabBadgeText = nil;
    if (count > 0) {
        tabBadgeText = [NSString stringWithFormat:@"%@",@(count)];
    }

    [[tabBarController.tabBar.items objectAtIndex:0] setBadgeValue:tabBadgeText];
    
    // update app badge
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:count];
    
    // update parse object
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setBadge:count];
    [currentInstallation saveInBackground];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kBIUpdateHomeNotificationBadgeNotification object:@(count)];
}

+ (NSInteger)currentBadgeCount {
    return [[UIApplication sharedApplication] applicationIconBadgeNumber];
}

+ (void)decrementBadgeCount {
    NSInteger currentCount = [self currentBadgeCount];
    NSInteger newCount = MAX(currentCount - 1, 0);
    [self updateBadgeCount:newCount];
}

#pragma mark - push notifications

+ (void)registerUserToInstallation {
    PFUser *currentUser = [PFUser currentUser];
    if (!currentUser) return;
    
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        PFInstallation *installation = [PFInstallation currentInstallation];
        installation[@"user"] = currentUser;
        [installation saveInBackground];
    });
}

+ (void)sendPushNotificationToUser:(PFUser*)user {
    PFUser *currentUser = [PFUser currentUser];
    
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"user" equalTo:user];
    
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery];
    [push setMessage:[NSString stringWithFormat: @"%@ wants to follow you!",  currentUser[@"name"]]];
    [push sendPushInBackground];
}

@end
