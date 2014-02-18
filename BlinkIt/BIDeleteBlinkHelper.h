//
//  BIDeleteBlinkHelper.h
//  BlinkIt
//
//  Created by Kimberly Hsiao on 2/18/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BIDeleteBlinkHelper : NSObject

+ (void)deleteBlink:(PFObject*)blink completion:(void (^)(NSError *error))completion;

@end
