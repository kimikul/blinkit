//
//  NSString+BlinkIt.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/10/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "NSString+BlinkIt.h"

@implementation NSString (BlinkIt)

- (NSString*)stringByTrimmingWhiteSpace {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
