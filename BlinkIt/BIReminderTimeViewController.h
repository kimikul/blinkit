//
//  BIReminderTimeViewController.h
//  BlinkIt
//
//  Created by Kimberly Hsiao on 2/25/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIViewController.h"

@class BIReminderTimeViewController;

@protocol BIReminderTimeViewControllerDelegate <NSObject>

- (void)reminderTimeVC:(BIReminderTimeViewController*)reminderTimeVC didTapCancelWithOriginalDate:(NSDate*)date;
- (void)reminderTimeVC:(BIReminderTimeViewController*)reminderTimeVC didSaveDate:(NSDate*)date;

@end

@interface BIReminderTimeViewController : BIViewController
@property (nonatomic, weak) id <BIReminderTimeViewControllerDelegate> delegate;
@property (nonatomic, strong) NSDate *originalDate;
@end
