//
//  NSArray+BlinkIt.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 2/23/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "NSArray+BlinkIt.h"

@implementation NSArray (BlinkIt)

- (id)safeObjectAtIndex:(NSUInteger)index {
    if(index >= [self count]) return nil;
    id object = nil;
    
    @try {
        object = [self objectAtIndex:index];
    } @catch (NSException *exception) {}
    return object;
}

@end
