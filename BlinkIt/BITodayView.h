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
@property (weak, nonatomic) IBOutlet BIPlaceholderTextView *contentTextView;
@property (nonatomic, strong) IBOutlet UILabel *remainingCharactersLabel;
@property (nonatomic, strong) PFObject *blink;
@end
