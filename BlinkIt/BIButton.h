//
//  BIButton.h
//  BlinkIt
//
//  Created by Kimberly Hsiao on 2/7/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    BIBarButtonTypeRight,
    BIBarButtonTypeLeft,
} BIBarButtonType;

@interface BIButton : UIButton
@property (nonatomic, assign) BIBarButtonType barButtonSide;
@end
