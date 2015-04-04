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
    NSString *username = [[_emailTextField.text stringByTrimmingWhiteSpace] lowercaseString];
    NSString *password = [_passwordTextField.text stringByTrimmingWhiteSpace];
    
    [PFUser logInWithUsernameInBackground:username password:password
                                    block:^(PFUser *user, NSError *error) {
                                        [self.passwordTextField resignFirstResponder];

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

- (IBAction)tappedForgotPassword:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Forgot Password" message:@"Enter your email address and we'll send you an email to reset your password" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"email";
    }];
    
    UIAlertAction *submit = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *email = [(UITextField*)alertController.textFields[0] text];
        if (email.hasContent) {
            [PFUser requestPasswordResetForEmailInBackground:email target:self selector:@selector(sentResetPasswordRequest:error:)];
        }
    }];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alertController addAction:submit];
    [alertController addAction:cancel];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - reset password {

- (void)sentResetPasswordRequest:(NSNumber*)result error:(NSError*)error {
    BOOL success = result.boolValue;
    if (success) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Email Sent" message:@"You should receive an email to reset your password" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    } else {
        NSString *errorMsg = error.code == 205 ? @"No user was found with that email" : @"An error occurred. Please try again";
        
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
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
