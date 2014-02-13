//
//  BINotificationHelper.h
//  BlinkIt
//
//  Created by Kimberly Hsiao on 2/12/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BINotificationHelper : NSObject

+ (void)fetchAndUpdateBadgeCountWithCompletion:(void (^)(UIBackgroundFetchResult))completion;
+ (void)updateBadgeCount:(NSInteger)count;
+ (void)decrementBadgeCount;

@end
