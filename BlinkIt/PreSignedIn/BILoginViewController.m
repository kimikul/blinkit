//
//  BILoginViewController.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/8/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BILoginViewController.h"

@interface BILoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIView *textFieldContainer;
@end

@implementation BILoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupButtons];
    [_emailTextField becomeFirstResponder];
}

- (void)setupButtons {
    _loginButton.layer.cornerRadius = 5.0;
    _loginButton.clipsToBounds = YES;
    
    _textFieldContainer.layer.cornerRadius = 5.0;
    _textFieldContainer.clipsToBounds = YES;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelTapped:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
}

#pragma mark - ibactions

- (void)cancelTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)loginTapped:(id)sender {
    NSString *username = [_emailTextField.text stringByTrimmingWhiteSpace];
    NSString *password = [_passwordTextField.text stringByTrimmingWhiteSpace];
    
    [PFUser logInWithUsernameInBackground:username password:password
                                    block:^(PFUser *user, NSError *error) {
                                        if (user) {
                                            [self.delegate loginViewController:self didLoginUser:user];
                                        } else if (error) {
                                            NSString *errorString = [error userInfo][@"error"];
                                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                            [alert show];
                                            return;
                                        }
                                    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:_emailTextField]) {
        [_passwordTextField becomeFirstResponder];
    } else if ([textField isEqual:_passwordTextField]) {
        [self loginTapped:_loginButton];
    }
    
    return YES;
}

@end
