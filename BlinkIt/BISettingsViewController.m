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

#define kTableSectionAccount 0
#define kTableSectionNotifications 1
#define kTableSectionLogout 2

#define kTableRowEmail 0
#define kTableRowDefaultPrivacy 1

#define kTableRowReminders 0

#define kTableRowLogout 0

@interface BISettingsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UISwitch *privacySwitch;
@property (weak, nonatomic) IBOutlet UISwitch *dailyRemindersSwitch;

@end

@implementation BISettingsViewController

#pragma mark - init

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupButtons];
    [self displayCurrentSettings];
}

- (void)setupButtons {
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(tappedDone:)];
    self.navigationItem.rightBarButtonItem = cancelButton;
}

- (void)displayCurrentSettings {
    PFUser *user = [PFUser currentUser];
    _emailLabel.text = user[@"username"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _privacySwitch.on = [defaults boolForKey:BIPrivacyDefaultSettings];
    _dailyRemindersSwitch.on = [defaults boolForKey:BIDailyReminderSettings];
}

#pragma mark - tableviewdelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger section = indexPath.section;
    
    if (section == kTableSectionLogout) {
        [self logout];
    }
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

@end
