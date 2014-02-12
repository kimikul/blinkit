//
//  BIConstants.h
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/31/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - NSUserDefaults
extern NSString *const kBIUserDefaultsFacebookFriendsKey;
extern NSString *const kBIUserDefaultsFollowedFriendsKey;
extern NSString *const kBIUserDefaultsRequestedFriendsKey;

#pragma mark - Notifications
extern NSString *const kBIRefreshHomeAndFeedNotification;
extern NSString *const kBITappedFollowButtonNotification;
extern NSString *const kBIUpdateHomeNotificationBadgeNotification;