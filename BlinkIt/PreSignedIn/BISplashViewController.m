//
//  BISplashViewController.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/8/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BISplashViewController.h"
#import "BILoginViewController.h"
#import "BISignUpViewController.h"
#import "BIHomeViewController.h"
#import "BIAppDelegate.h"

@interface BISplashViewController () <BILoginViewControllerDelegate, BISignUpViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@end

@implementation BISplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _loginButton.layer.cornerRadius = 3.0;
    _loginButton.clipsToBounds = YES;
    
    _signupButton.layer.cornerRadius = 3.0;
    _signupButton.clipsToBounds = YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UINavigationController *nav = segue.destinationViewController;

    if ([segue.identifier isEqualToString:@"LoginSegue"]) {
        BILoginViewController *loginVC = (BILoginViewController*)nav.topViewController;
        loginVC.delegate = self;
    } else if ([segue.identifier isEqualToString:@"SignupSegue"]) {
        BISignUpViewController *signupVC = (BISignUpViewController*)nav.topViewController;
        signupVC.delegate = self;
    }
}

#pragma mark - BISignupViewControllerDelegate

- (void)signUpViewController:(BISignUpViewController*)signupVC didSignUp:(PFUser*)user {
    [self transitionToHomeViewController];
}

#pragma mark - BILoginViewControllerDelegate

- (void)loginViewController:(BILoginViewController*)loginVC didLoginUser:(PFUser*)user {
    [self transitionToHomeViewController];
}

#pragma mark - transition

- (void)transitionToHomeViewController {
    UIStoryboard *mainStoryboard = [UIStoryboard mainStoryboard];
    BIHomeViewController *homeVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"BIHomeNavigationController"];
    
    BIAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate setRootViewController:homeVC];
}

@end
