//
//  BIButton.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 2/7/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIButton.h"

@implementation BIButton

- (UIEdgeInsets)alignmentRectInsets {
    UIEdgeInsets insets;
    if (_barButtonSide == BIBarButtonTypeLeft) {
        insets = UIEdgeInsetsMake(0, 9.0f, 0, 0);
    }
    else if (_barButtonSide == BIBarButtonTypeRight) {
        insets = UIEdgeInsetsMake(0, 0, 0, 9.0f);
    }
    
    return insets;
}

@end
