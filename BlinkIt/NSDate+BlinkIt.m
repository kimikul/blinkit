//
//  NSDate+BlinkIt.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/12/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "NSDate+BlinkIt.h"

@implementation NSDate (BlinkIt)

+ (NSString*)spelledOutDate:(NSDate*)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"eeee, MMMM d, yyyy"];
    
    NSString *formattedDate = [dateFormatter stringFromDate:date];
    return formattedDate;
}

+ (NSString*)spelledOutTodaysDate {
    return [self spelledOutDate:[NSDate date]];
}

+ (NSString*)formattedTime:(NSDate*)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm aa"];
    
    NSString *formattedDate = [dateFormatter stringFromDate:date];
    return formattedDate;
}

+ (BOOL)isToday:(NSDate*)date {
    NSDateComponents *otherDay = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
    if([today day] == [otherDay day] &&
       [today month] == [otherDay month] &&
       [today year] == [otherDay year]) {
        return YES;
    }
    
    return NO;
}

@end
