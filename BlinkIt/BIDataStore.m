//
//  BIDataStore.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/31/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIDataStore.h"

@implementation BIDataStore

static BIDataStore *shared = nil;

+ (BIDataStore*)shared {
    @synchronized (self) {
        if (!shared) {
            shared = [[BIDataStore alloc] init];
        }
    }
    
    return shared;
}

#pragma mark - lifecycle

- (id) init {
    self = [super init];
    if (self) {
        _fbFriends = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void) reset {
    [_fbFriends removeAllObjects];
}



@end
