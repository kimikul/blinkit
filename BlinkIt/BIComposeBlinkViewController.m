//
//  BIComposeBlinkViewController.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/10/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIComposeBlinkViewController.h"

@interface BIComposeBlinkViewController ()
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UILabel *remainingCharactersLabel;

@end

@implementation BIComposeBlinkViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupButtons];
    [self setupTextView];
    
    [_contentTextView becomeFirstResponder];
}

- (void)setupTextView {
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)setupButtons {
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelTapped:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStylePlain target:self action:@selector(blinkTapped:)];
    self.navigationItem.rightBarButtonItem = submitButton;
}

#pragma mark - ibactions

- (void)cancelTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)blinkTapped:(id)sender {
    PFObject *newBlink = [PFObject objectWithClassName:@"Blink"];
    newBlink[@"content"] = [_contentTextView.text stringByTrimmingWhiteSpace];
    newBlink[@"date"] = [NSDate date];
    [newBlink saveInBackground];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - uitextviewdelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (textView.text.length < 300 || text.length == 0) {
        return YES;
    }
    
    return NO;
}

- (void)textViewDidChange:(UITextView *)textView {
    NSInteger remainingCharacterCount = 300 - textView.text.length;
    NSString *pluralString = (remainingCharacterCount == 1) ? @"" : @"s";
    
    NSString *remainingCharactersLabel = [NSString stringWithFormat:@"%d character%@ remaining", remainingCharacterCount, pluralString];
    
    _remainingCharactersLabel.text = remainingCharactersLabel;
}

@end
