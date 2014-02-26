//
//  BIReminderTimeViewController.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 2/25/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIReminderTimeViewController.h"

@interface BIReminderTimeViewController ()
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@end

@implementation BIReminderTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupButtons];
    
    if (_originalDate) {
        _datePicker.date = _originalDate;
    }
}

- (void)setupButtons {
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(tappedSave:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(tappedCancel:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
}

#pragma mark - ibactions

- (void)tappedSave:(UIButton*)sender {
    [self.delegate reminderTimeVC:self didSaveDate:_datePicker.date];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tappedCancel:(UIButton*)sender {
    [self.delegate reminderTimeVC:self didTapCancelWithOriginalDate:_originalDate];
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
