//
//  BISettingsViewController.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/18/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BISettingsViewController.h"
#import "BISplashViewController.h"
#import "BIAppDelegate.h"
#import "BIFacebookUserManager.h"
#import "BIFollowManager.h"

#define kTableSectionAccount 0
#define kTableSectionNotifications 1
#define kTableSectionLogout 2

#define kTableRowEmail 0
#define kTableRowFacebook 1
#define kTableRowDefaultPrivacy 2

#define kTableRowReminders 0

#define kTableRowLogout 0

@interface BISettingsViewController () <UIActionSheetDelegate>

@property (nonatomic, strong) PFUser *currentUser;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UISwitch *privacySwitch;
@property (weak, nonatomic) IBOutlet UISwitch *dailyRemindersSwitch;
@property (weak, nonatomic) IBOutlet UILabel *facebookLinkLabel;

@end

@implementation BISettingsViewController

#pragma mark - init

- (void)viewDidLoad {
    [super viewDidLoad];

    _currentUser = [PFUser currentUser];

    [self setupButtons];
    [self displayCurrentSettings];
}

- (void)setupButtons {
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(tappedDone:)];
    self.navigationItem.rightBarButtonItem = cancelButton;
}

- (void)displayCurrentSettings {
    _emailLabel.text = _currentUser[@"username"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _privacySwitch.on = [defaults boolForKey:BIPrivacyDefaultSettings];
    _dailyRemindersSwitch.on = [defaults boolForKey:BIDailyReminderSettings];

    [self updateFacebookLinkLabel];
}

- (void)updateFacebookLinkLabel {
    _facebookLinkLabel.text = [PFFacebookUtils isLinkedWithUser:_currentUser] ? _currentUser[@"name"] : @"Click to link account";
    [_facebookLinkLabel fadeTransitionWithDuration:0.2];
}

#pragma mark - tableviewdelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (section == kTableSectionAccount && row == kTableRowFacebook) {
        if ([PFFacebookUtils isLinkedWithUser:_currentUser]) {
            [self promptForUnlinkWithFacebook];
        } else {
            [self linkToFacebook];
        }
    } else if (section == kTableSectionLogout) {
        [self logout];
    }
}

- (void)linkToFacebook {
    NSArray *permissions = @[@"basic_info", @"email"];

    if (![PFFacebookUtils isLinkedWithUser:_currentUser]) {
        [PFFacebookUtils linkUser:_currentUser permissions:permissions block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [[BIFacebookUserManager shared] fetchAndSaveBasicUserInfoWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        [[BIFacebookUserManager shared] refreshCurrentUserFacebookFriends];
                        [BIFollowManager refreshFollowingList];
                        [self updateFacebookLinkLabel];
                    } else {
                        [self showFacebookLinkErrorAlert:error];
                    }
                }];
            } else {
                [self showFacebookLinkErrorAlert:error];
            }
        }];
    }
}

- (void)promptForUnlinkWithFacebook {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"This will disconnect your account with Facebook. Are you sure?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Continue" otherButtonTitles:nil];
    [actionSheet showInView:self.view];
}

- (void)unlinkWithFacebook {
    [PFFacebookUtils unlinkUserInBackground:_currentUser block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self updateFacebookLinkLabel];
        } else {
            [self showFacebookLinkErrorAlert:error];
        }
    }];
}

- (void)showFacebookLinkErrorAlert:(NSError*)error {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    
    NSLog(@"error linking to facebook : %@", error.localizedDescription);
}

#pragma mark - button actions

- (void)tappedDone:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)logout {
    [PFUser logOut];
    
    UIStoryboard *mainStoryboard = [UIStoryboard mainStoryboard];
    BISplashViewController *splashVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"BISplashViewController"];
    
    BIAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    [appDelegate setRootViewController:splashVC];
}

- (IBAction)togglePrivacySettings:(UISwitch*)privacySwitch {
    BOOL newValue = privacySwitch.on;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:newValue forKey:BIPrivacyDefaultSettings];
    [defaults synchronize];
}

- (IBAction)toggleDailyReminders:(UISwitch*)remindersSwitch {
    BOOL newValue = remindersSwitch.on;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:newValue forKey:BIDailyReminderSettings];
    [defaults synchronize];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [self unlinkWithFacebook];
    }
}

@end
