//
//  BITodayView.h
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/12/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BIPlaceholderTextView.h"
#import "BIViewController.h"

@class BITodayView;

@protocol BITodayViewDelegate <NSObject>

- (void)todayView:(BITodayView*)todayView didSubmitBlink:(PFObject*)blink;
- (void)todayView:(BITodayView *)todayView didTapEditExistingBlink:(PFObject*)blink;
- (void)todayView:(BITodayView *)todayView didTapCancelEditExistingBlink:(PFObject*)blink;
- (void)todayView:(BITodayView *)todayView didTapDeleteExistingBlink:(PFObject*)blink;
- (void)todayView:(BITodayView *)todayView addPhotoToBlink:(PFObject*)blink;

@end

@interface BITodayView : UIView

@property (nonatomic, weak) BIViewController <BITodayViewDelegate, UIActionSheetDelegate> * delegate;

@property (nonatomic, strong) PFObject *blink;
@property (nonatomic, assign) BOOL isExpanded;
@property (nonatomic, strong) UIImage *selectedImage;

@property (weak, nonatomic) IBOutlet BIPlaceholderTextView *contentTextView;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

- (void)updateRemainingCharLabel;
- (BOOL)contentTextFieldHasContent;

@end
