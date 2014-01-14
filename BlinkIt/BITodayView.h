//
//  BITodayView.h
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/12/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BIPlaceholderTextView.h"

@interface BITodayView : UIView

@property (nonatomic, strong) PFObject *blink;
@property (nonatomic, assign) BOOL isExpanded;

@property (weak, nonatomic) IBOutlet BIPlaceholderTextView *contentTextView;
@property (nonatomic, strong) IBOutlet UILabel *remainingCharactersLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;

@end
