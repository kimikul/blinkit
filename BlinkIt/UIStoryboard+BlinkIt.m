//
//  UIStoryboard+BlinkIt.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/10/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "UIStoryboard+BlinkIt.h"

@implementation UIStoryboard (BlinkIt)

+ (UIStoryboard*)mainStoryboard {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return mainStoryboard;
}

@end
