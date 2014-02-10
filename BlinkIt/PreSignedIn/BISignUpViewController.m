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
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIView *textFieldContainer;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;

@end

@implementation BISignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupButtons];
    [_emailTextField becomeFirstResponder];
    
}

- (void)setupButtons {
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
    BOOL validFields = [self validateFields];
    if (validFields) {
        PFUser *user = [PFUser user];
        user.username = [[_emailTextField.text stringByTrimmingWhiteSpace] lowercaseString];
        user.password = [_passwordTextField.text stringByTrimmingWhiteSpace];
        
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSString *errorString = [error userInfo][@"error"];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                return;
            }
            
            [self.delegate signUpViewController:self didSignUp:user];
        }];
    }
}

- (BOOL)validateFields {
    NSString *email = [_emailTextField.text stringByTrimmingWhiteSpace];
    NSString *password = [_passwordTextField.text stringByTrimmingWhiteSpace];
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest =[NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL validEmail = [emailTest evaluateWithObject:email];
    
    if (!validEmail) {
        UIAlertView *invalidEmailAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Invalid email address. Please try again!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [invalidEmailAlert show];
        return NO;
    }
    
    if (password.length < 8) {
        UIAlertView *pwLengthAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your password must be at least 8 characters long. Please try again!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [pwLengthAlert show];
        return NO;
    }
    
    return YES;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:_emailTextField]) {
        [_passwordTextField becomeFirstResponder];
    } else if ([textField isEqual:_passwordTextField]) {
        [self signupTapped:_signupButton];
    }
    
    return YES;
}

@end
