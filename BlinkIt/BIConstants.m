//
//  BIConstants.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/31/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIConstants.h"

#pragma mark - NSUserDefaults
NSString *const kBIUserDefaultsFacebookFriendsKey = @"kBIUserDefaultsFacebookFriendsKey";
NSString *const kBIUserDefaultsFollowedFriendsKey = @"kBIUserDefaultsFollowedFriendsKey";
NSString *const kBIUserDefaultsRequestedFriendsKey = @"kBIUserDefaultsRequestedFriendsKey";

#pragma mark - cache
NSString *const kBICachedProfilePicsKey = @"kBICachedProfilePicsKey";

#pragma mark - Notifications
NSString *const kBIRefreshHomeAndFeedNotification = @"kBIRefreshHomeAndFeedNotification";
NSString *const kBITappedFollowButtonNotification = @"kBITappedFollowButtonNotification";
NSString *const kBIUpdateHomeNotificationBadgeNotification = @"kBIUpdateHomeNotificationBadgeNotification";
NSString *const kBIUpdateSavedBlinkNotification = @"kBIUpdateSavedBlinkNotification";
NSString *const kBIDeleteBlinkNotification = @"kBIDeleteTodaysBlinkNotification";
NSString *const kBIBlinkPrivacyUpdatedNotification = @"kBIBlinkPrivacyUpdatedNotification";