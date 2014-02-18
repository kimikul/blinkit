//
//  NSDate+BlinkIt.h
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/12/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (BlinkIt)

+ (NSString*)spelledOutDate:(NSDate*)date;
+ (NSString*)spelledOutTodaysDate;
+ (NSString*)formattedTime:(NSDate*)date;
+ (BOOL)isToday:(NSDate*)date;

@end
