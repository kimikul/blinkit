//
//  BISignUpViewController.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/8/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BISignUpViewController.h"

@interface BISignUpViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIView *textFieldContainer;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;

@end

@implementation BISignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _signupButton.layer.cornerRadius = 5.0;
    _signupButton.clipsToBounds = YES;

    _textFieldContainer.layer.cornerRadius = 5.0;
    _textFieldContainer.clipsToBounds = YES;

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelTapped:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
}

#pragma mark - ibactions

- (void)cancelTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)signupTapped:(id)sender {
    
}

@end
