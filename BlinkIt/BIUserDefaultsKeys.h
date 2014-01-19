//
//  BIUserDefaultsKeys.h
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/18/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BIUserDefaultsKeys : NSObject

extern NSString *BIPrivacyDefaultSettings;  // YES = private, NO = public
extern NSString *BIDailyReminderSettings;  // YES = reminders on, NO = reminders off

@end
