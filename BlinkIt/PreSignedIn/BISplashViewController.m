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
#import "BIFacebookUserManager.h"
#import "BIWebViewController.h"

@interface BISplashViewController () <BILoginViewControllerDelegate, BISignUpViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIImageView *launchImage;
@end

@implementation BISplashViewController

#pragma mark - lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _loginButton.layer.cornerRadius = 3.0;
    _loginButton.clipsToBounds = YES;
    
    _signupButton.layer.cornerRadius = 3.0;
    _signupButton.clipsToBounds = YES;
    
    _facebookButton.layer.cornerRadius = 3.0;
    _facebookButton.clipsToBounds = YES;
    _facebookButton.imageView.contentMode = UIViewContentModeScaleAspectFit;

    UIImage *defaultImage = [self correctIphoneLaunchImage];
    self.launchImage.image = defaultImage;
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
    
    [BIMixpanelHelper sendMixpanelEvent:@"SIGNUP_regularSignUp" withProperties:nil];
}

#pragma mark - BILoginViewControllerDelegate

- (void)loginViewController:(BILoginViewController*)loginVC didLoginUser:(PFUser*)user {
    [self transitionToHomeViewController];
    
    [BIMixpanelHelper sendMixpanelEvent:@"LOGIN_regularLogin" withProperties:nil];

}

#pragma mark - facebook / BIFacebookUserManagerDelegate

- (IBAction)tappedLoginThroughFacebook:(id)sender {
    NSArray *permissions = @[@"basic_info", @"email"];

    [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
        if (!user) {
            [self showFacebookLoginErrorAlert:error];
        } else {
            [[BIFacebookUserManager shared] fetchAndSaveBasicUserInfoWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    [self transitionToHomeViewController];
                    [BIMixpanelHelper sendMixpanelEvent:@"FACEBOOK_linkFacebookSuccess" withProperties:@{@"source":@"login"}];
                } else {
                    [self showFacebookLoginErrorAlert:error];
                }
            }];
        }
    }];
    
    [BIMixpanelHelper sendMixpanelEvent:@"FACEBOOK_attemptLinkFacebook" withProperties:@{@"source":@"login"}];
}

- (void)showFacebookLoginErrorAlert:(NSError*)error {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    
    NSLog(@"error logging into facebook : %@", error.localizedDescription);
}

#pragma mark - transition

- (void)transitionToHomeViewController {
    [[BIFacebookUserManager shared] refreshCurrentUserFacebookFriends];
    [BIFollowManager refreshFollowingList];
    [BIFollowManager refreshRequestToFollowList];
    [BINotificationHelper registerUserToInstallation];
    [BIMixpanelHelper setupSuperPropertiesForUser:[PFUser currentUser]];
    [BICrashlyticsHelper setupCrashlyticsProperties];
    
    UIStoryboard *mainStoryboard = [UIStoryboard mainStoryboard];
    UINavigationController *homeVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"BITabBarController"];
    
    BIAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate setRootViewController:homeVC];
}

- (IBAction)tappedPrivacy:(id)sender {
    BIWebViewController *webViewVC = [BIWebViewController new];
    webViewVC.URL = [NSURL URLWithString:@"http://blinkit.herokuapp.com/privacy"];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webViewVC];
    [self presentViewController:nav animated:YES completion:nil];
}

- (IBAction)tappedTOS:(id)sender {
    BIWebViewController *webViewVC = [BIWebViewController new];
    webViewVC.URL = [NSURL URLWithString:@"http://blinkit.herokuapp.com/termsofservice"];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webViewVC];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - launch background

- (UIImage*)correctIphoneLaunchImage {
    UIScreen *screen = [UIScreen mainScreen];
    CGFloat screenHeight = screen.bounds.size.height;
    CGFloat screenWidth = screen.bounds.size.width;
    
    NSString *imageName = @"LaunchImage-700@2x";    // iphone4
    
    if (screenHeight >= 736) {  // iphone6+ portrait
        imageName = @"LaunchImage-800-Portrait-736h@3x.png";
    } else if (screenWidth >= 736) {    // iphone6+ landscape
        imageName = @"LaunchImage-800-Landscape-736h@3x.png";
    } else if (screenHeight >= 667) { // iphone6
        imageName = @"LaunchImage-800-667h@2x.png";
    } else if (screenHeight >= 568) {   // iphone5
        imageName = @"LaunchImage-700-568h@2x.png";
    }
    
    return [UIImage imageNamed:imageName];
}

@end
