//
//  BIDeleteBlinkHelper.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 2/18/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIDeleteBlinkHelper.h"

@implementation BIDeleteBlinkHelper

+ (void)deleteBlink:(PFObject*)blink completion:(void (^)(BOOL succeeded))completion {
    [blink deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            if (completion) completion(error);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kBIDeleteBlinkNotification object:blink];
        }
    }];
}

@end
