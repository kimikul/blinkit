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
#import "BIReminderTimeViewController.h"

#define kTableSectionAccount 0
#define kTableSectionNotifications 1
#define kTableSectionLogout 2

#define kTableRowEmail 0
#define kTableRowFacebook 1
#define kTableRowDefaultPrivacy 2
#define kTableRowUsername 3

#define kTableRowReminders 0

#define kTableRowLogout 0

@interface BISettingsViewController () <UIActionSheetDelegate, BIReminderTimeViewControllerDelegate>

@property (nonatomic, strong) PFUser *currentUser;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UISwitch *privacySwitch;
@property (weak, nonatomic) IBOutlet UILabel *dailyReminderTimeLabel;
@property (weak, nonatomic) IBOutlet UISwitch *dailyRemindersSwitch;
@property (weak, nonatomic) IBOutlet UILabel *facebookLinkLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *usernameCell;

@end

@implementation BISettingsViewController

#pragma mark - init

- (void)viewDidLoad {
    [super viewDidLoad];

    _currentUser = [PFUser currentUser];

    [self setupButtons];
    [self setupObservers];
    [self displayCurrentSettings];
    
    [BIMixpanelHelper sendMixpanelEvent:@"SETTINGS_viewSettings" withProperties:nil];
}

- (void)setupButtons {
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(tappedDone:)];
    self.navigationItem.rightBarButtonItem = cancelButton;
}

- (void)setupObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayCurrentSettings) name:kBIUsernameUpdatedNotification object:nil];
}

- (void)displayCurrentSettings {
    _emailLabel.text = _currentUser[@"username"];
    
    NSString *blinkitUsername = _currentUser[@"blinkitUsername"];
    if (blinkitUsername.hasContent) {
        _usernameLabel.text = blinkitUsername;
        _usernameCell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        _usernameLabel.text = @"Tap to select username";
        _usernameCell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _privacySwitch.on = [defaults boolForKey:BIPrivacyDefaultSettings];

    [self updateFacebookLinkLabel];
    [self updateReminderTimeRow];
}

- (void)updateFacebookLinkLabel {
    _facebookLinkLabel.text = [PFFacebookUtils isLinkedWithUser:_currentUser] ? _currentUser[@"name"] : @"Tap to link account";
    [_facebookLinkLabel fadeTransitionWithDuration:0.2];
}

- (void)updateReminderTimeRow {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _dailyRemindersSwitch.on = [defaults boolForKey:BIDailyReminderSettings];

    NSDate *reminderTime = [defaults objectForKey:kBIUserDefaultsReminderTimeKey];
    _dailyReminderTimeLabel.text = reminderTime ? [NSDate formattedTime:reminderTime] : @"Reminder time not set";
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
    } else if (section == kTableSectionAccount && row == kTableRowUsername) {
        [self presentUsernamePrompt];
    } else if (section == kTableSectionNotifications) {
        [self showReminderTimePicker];
    } else if (section == kTableSectionLogout) {
        [self promptForLogout];
    }
}

- (void)presentUsernamePrompt {
    NSString *blinkitUsername = _currentUser[@"blinkitUsername"];

    if (!blinkitUsername.hasContent) {
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"BIChooseUsernameView" owner:self options:nil];
        BIChooseUsernameView *usernameView = [nibs safeObjectAtIndex:0];
        usernameView.frame = [UIApplication sharedApplication].keyWindow.bounds;
        
        [[UIApplication sharedApplication].keyWindow addSubview:usernameView];
        
        [usernameView present];
    }
}

- (void)linkToFacebook {
    NSArray *permissions = @[@"public_profile", @"email", @"user_friends"];

    if (![PFFacebookUtils isLinkedWithUser:_currentUser]) {
        [PFFacebookUtils linkUser:_currentUser permissions:permissions block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [[BIFacebookUserManager shared] fetchAndSaveBasicUserInfoWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        [[BIFacebookUserManager shared] refreshCurrentUserFacebookFriends];
                        [BIFollowManager refreshFollowingList];
                        [BIFollowManager refreshRequestToFollowList];
                        [BIMixpanelHelper setupSuperPropertiesForUser:[PFUser currentUser]];
                        [BICrashlyticsHelper setupCrashlyticsProperties];
                        [self updateFacebookLinkLabel];
                        
                        [BIMixpanelHelper sendMixpanelEvent:@"FACEBOOK_linkFacebookSuccess" withProperties:@{@"source":@"settings"}];
                    } else {
                        [self showFacebookLinkErrorAlert:error];
                    }
                }];
            } else {
                [self showFacebookLinkErrorAlert:error];
            }
        }];
    }
    
    [BIMixpanelHelper sendMixpanelEvent:@"FACEBOOK_attemptLinkFacebook" withProperties:@{@"source":@"settings"}];
}

- (void)promptForUnlinkWithFacebook {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"This will disconnect your account with Facebook. Are you sure?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Continue" otherButtonTitles:nil];
    actionSheet.tag = kTableSectionAccount;
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
    
    [BIMixpanelHelper sendMixpanelEvent:@"FACEBOOK_unlinkFacebook" withProperties:nil];
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

#pragma mark - logout

- (void)promptForLogout {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to logout?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Continue" otherButtonTitles:nil];
    actionSheet.tag = kTableSectionLogout;
    [actionSheet showInView:self.view];
}

- (void)logout {
    [[PFFacebookUtils session] closeAndClearTokenInformation];
    [PFUser logOut];
    
    // clear userdefaults
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    // clear cache
    [[BIDataStore shared] reset];
    
    UIStoryboard *mainStoryboard = [UIStoryboard mainStoryboard];
    BISplashViewController *splashVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"BISplashViewController"];
    
    BIAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    [appDelegate setRootViewController:splashVC];
    
    [BIMixpanelHelper sendMixpanelEvent:@"LOGOUT" withProperties:nil];
}

- (IBAction)togglePrivacySettings:(UISwitch*)privacySwitch {
    BOOL newValue = privacySwitch.on;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:newValue forKey:BIPrivacyDefaultSettings];
    [defaults synchronize];
    
    [BIMixpanelHelper sendMixpanelEvent:@"SETTINGS_togglePrivacy" withProperties:@{@"changeToPrivate":@(newValue)}];
}

- (IBAction)toggleDailyReminders:(UISwitch*)remindersSwitch {
    BOOL newValue = remindersSwitch.on;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:newValue forKey:BIDailyReminderSettings];
    [defaults synchronize];
    
    if (newValue && ![defaults objectForKey:kBIUserDefaultsReminderTimeKey]) {
        [self showReminderTimePicker];
    }
    
    if (!newValue) {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
}

- (void)showReminderTimePicker {
    UIStoryboard *mainStoryboard = [UIStoryboard mainStoryboard];
    UINavigationController *nav = [mainStoryboard instantiateViewControllerWithIdentifier:@"BIReminderTimeNavigationController"];
    BIReminderTimeViewController *reminderTimeVC = (BIReminderTimeViewController*)nav.topViewController;
    reminderTimeVC.originalDate = [[NSUserDefaults standardUserDefaults] objectForKey:kBIUserDefaultsReminderTimeKey];
    reminderTimeVC.delegate = self;
    
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        if (actionSheet.tag == kTableSectionAccount) {
            [self unlinkWithFacebook];
        } else if (actionSheet.tag == kTableSectionLogout) {
            [self logout];
        }
    }
}

#pragma mark - BIReminderTimeViewControllerDelegate

- (void)reminderTimeVC:(BIReminderTimeViewController*)reminderTimeVC didTapCancelWithOriginalDate:(NSDate*)date {
    if (!date) {
        _dailyRemindersSwitch.on = NO;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:NO forKey:BIDailyReminderSettings];
        [defaults synchronize];
        
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
}

- (void)reminderTimeVC:(BIReminderTimeViewController*)reminderTimeVC didSaveDate:(NSDate*)date {
    _dailyReminderTimeLabel.text = [NSDate formattedTime:date];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:date forKey:kBIUserDefaultsReminderTimeKey];
    [defaults synchronize];
    
    [self scheduleNotification:date];
}

- (void)scheduleNotification:(NSDate*)pickerDate {
    [BIMixpanelHelper sendMixpanelEvent:@"REMINDERS_scheduledReminder" withProperties:@{@"reminderTime" : pickerDate}];

    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    
    // Break the date up into components
    NSDateComponents *dateComponents = [calendar components:( NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit )
												   fromDate:pickerDate];
    NSDateComponents *timeComponents = [calendar components:( NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit )
												   fromDate:pickerDate];
    // Set up the fire time
    NSDateComponents *dateComps = [[NSDateComponents alloc] init];
    [dateComps setDay:[dateComponents day]];
    [dateComps setMonth:[dateComponents month]];
    [dateComps setYear:[dateComponents year]];
    [dateComps setHour:[timeComponents hour]];
    [dateComps setMinute:[timeComponents minute]];
	[dateComps setSecond:[timeComponents second]];
    
    NSDate *itemDate = [calendar dateFromComponents:dateComps];
    
    UILocalNotification *localNotif = [UILocalNotification new];
    localNotif.fireDate = itemDate;
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    localNotif.repeatInterval = NSDayCalendarUnit;
    
	// Notification details
    localNotif.alertBody = @"Don't forget to blink today! :)";
    
	// Set the action button
    localNotif.alertAction = @"View";
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    
	// Schedule the notification
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}

@end
