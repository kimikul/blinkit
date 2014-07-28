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

+ (NSString*)spelledOutDateNoDay:(NSDate*)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM d, yyyy"];
    
    NSString *formattedDate = [dateFormatter stringFromDate:date];
    return formattedDate;
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

+ (NSInteger)numDaysSinceDate:(NSDate*)startDate {
    NSDate *endDate = [NSDate dateWithOutTime:[NSDate date]];
    startDate = [NSDate dateWithOutTime:startDate];
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                        fromDate:startDate
                                                          toDate:endDate
                                                         options:0];
    
    return [components day] + 1;
}

+ (NSDate*)dateWithOutTime:(NSDate *)date {
    NSDateComponents* comps = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    return [[NSCalendar currentCalendar] dateFromComponents:comps];
}

+ (NSDate*)beginningOfDay:(NSDate*)date {
    NSDateComponents* comps = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    return [[NSCalendar currentCalendar] dateFromComponents:comps];
}

+ (NSDate*)endOfDay:(NSDate*)date {
    NSDateComponents* comps = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:date];
    comps.hour = 23;
    comps.minute = 59;
    comps.second = 59;
    return [[NSCalendar currentCalendar] dateFromComponents:comps];
}

@end
