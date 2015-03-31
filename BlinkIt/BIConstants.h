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
extern NSString *const kBIUserDefaultsReminderTimeKey;
extern NSString *const kBIUserDefaultsDateJoinedKey;
extern NSString *const kBIUserDefaultsTotalBlinksKey;
extern NSString *const kBIUserDefaultsRecentSearchesKey;

#pragma mark - Cache
extern NSString *const kBICachedProfilePicsKey;

#pragma mark - Notifications
extern NSString *const kBIRefreshHomeAndFeedNotification;
extern NSString *const kBIDidUpdateFollowedFriends;
extern NSString *const kBIDidUpdateFacebookFriends;
extern NSString *const kBITappedFollowButtonNotification;
extern NSString *const kBIUpdateHomeNotificationBadgeNotification;
extern NSString *const kBIUpdateSavedBlinkNotification;
extern NSString *const kBIDeleteBlinkNotification;
extern NSString *const kBIBlinkPrivacyUpdatedNotification;