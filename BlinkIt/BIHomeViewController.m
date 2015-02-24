//
//  BIHomeViewController.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/10/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIHomeViewController.h"
#import "BIHomeTableViewCell.h"
#import "BIImageUploadManager.h"
#import "BIHomePhotoTableViewCell.h"
#import "BISettingsViewController.h"
#import "BIPaginationTableViewCell.h"
#import "BINoFollowResultsTableViewCell.h"
#import "BIComposeBlinkViewController.h"
#import "BIHomeHeaderView.h"
#import "BIFollowingViewController.h"
#import "BIFollowersViewController.h"

#define kDeletePreviousBlinkActionSheet 2
#define kNumBlinksPerPage 15

@interface BIHomeViewController () <UIActionSheetDelegate, BIHomeHeaderViewDelegate>

@property (nonatomic, strong) PFObject *todaysBlink;
@property (nonatomic, strong) BIHomeTableViewCell *togglePrivacyCell;
@property (nonatomic, strong) BIHomeHeaderView *homeHeaderView;
@property (nonatomic, assign) BOOL shouldRefreshNumbers;
@end

@implementation BIHomeViewController

#pragma mark - init

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.useRefreshTableHeaderView = YES;
        
        [self fetchBlinksForPagination:NO];
    }
    
    return self;
}

#pragma mark - lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupButtons];
    [self setupNav];
    [self setupHeader];
    [self setupObservers];
}

- (void)setupButtons {
    //settings
    BIButton *settingsButton = [BIButton buttonWithType:UIButtonTypeCustom];
    settingsButton.barButtonSide = BIBarButtonTypeRight;
    settingsButton.frame = CGRectMake(0,0,25,25);
    
    UIImage *settingsImage = [[UIImage imageNamed:@"settings"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [settingsButton setBackgroundImage:settingsImage forState:UIControlStateNormal];
    [settingsButton addTarget:self action:@selector(tappedSettings:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *settingsBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:settingsButton];
    settingsBarButtonItem.customView.hidden = YES;
    self.navigationItem.rightBarButtonItem = settingsBarButtonItem;
}

- (void)setupHeader {
    PFUser *user = [PFUser currentUser];
    
    if ([PFFacebookUtils isLinkedWithUser:user]) {
        BIHomeHeaderView *headerView = [[UINib nibWithNibName:@"BIHomeHeaderView" bundle:nil] instantiateWithOwner:self options:nil][0];
        headerView.user = [PFUser currentUser];
        headerView.delegate = self;
        _homeHeaderView = headerView;
        self.tableView.tableHeaderView = headerView;
    }
}

- (void)setupNav {
    self.navigationController.navigationBar.barTintColor = [UIColor mintGreen];
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    logoImageView.frame = CGRectMake(0, 0, 160, 24);
    logoImageView.autoresizingMask = self.navigationItem.titleView.autoresizingMask;
    logoImageView.hidden = YES;
    self.navigationItem.titleView = logoImageView;
}

- (void)setupObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHome) name:kBIRefreshHomeAndFeedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateForTodaysBlink:) name:kBIUpdateSavedBlinkNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deletedBlink:) name:kBIDeleteBlinkNotification object:nil];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_shouldRefreshNumbers) {
        _shouldRefreshNumbers = NO;
        [_homeHeaderView refreshNumbers];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.navigationItem.titleView.hidden) {
        [self.navigationItem.titleView fadeInWithDuration:0.5 completion:nil];
        [self.navigationItem.leftBarButtonItem.customView fadeInWithDuration:0.5 completion:nil];
        [self.navigationItem.rightBarButtonItem.customView fadeInWithDuration:0.5 completion:nil];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - requests

- (void)fetchBlinksForPagination:(BOOL)pagination {
    if (self.isLoading) return;
    self.loading = YES;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Blink"];
    query.limit = kNumBlinksPerPage;
    query.skip = pagination ? self.allBlinksArray.count : 0;
    [query orderByDescending:@"date"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.loading = NO;

        if (!error) {
            self.canPaginate = objects.count > 0 && (objects.count % kNumBlinksPerPage == 0);

            NSMutableArray *blinks = pagination ? [[self.allBlinksArray arrayByAddingObjectsFromArray:objects] mutableCopy] : [objects mutableCopy];
            self.allBlinksArray = [blinks mutableCopy];
            
            [self sortOutTodaysBlinkFromObjects:blinks];
            
            // append or replace existing data source
            [self reloadTableData];
        }
    }];
    
    if (pagination) {
        [BIMixpanelHelper sendMixpanelEvent:@"HOME_paginateHome" withProperties:nil];
    }
}

- (void)sortOutTodaysBlinkFromObjects:(NSArray*)blinks {
    BOOL isBlinkToday = NO;
    for (PFObject *blink in blinks) {
        NSDate *date = blink[@"date"];
        if ([NSDate isToday:date]) {
            _todaysBlink = blink;
            isBlinkToday = YES;
            break;
        }
    }
    
    if (!isBlinkToday) {
        _todaysBlink = nil;
    }

}

- (void)refreshHome {
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    [self fetchBlinksForPagination:NO];
    _homeHeaderView.user = [PFUser currentUser];
}

#pragma mark - refresh and pagination

- (void)refreshTableHeaderDidTriggerRefresh {
    [self fetchBlinksForPagination:NO];
    [_homeHeaderView refreshNumbers];
}

- (void)performPaginationRequestIfNecessary {
    if([self hasReachedTableEnd:self.tableView] && self.canPaginate) {
        [self fetchBlinksForPagination:YES];
    }
}

- (void)updateForTodaysBlink:(NSNotification*)note {
    PFObject *blink = note.object;
    
    if (![self blinkArray:self.allBlinksArray containsBlink:blink]) {
        [self.allBlinksArray insertObject:blink atIndex:0];
        [_homeHeaderView updateBlinkCountWithIncrement:YES];
    }
    
    [self sortOutTodaysBlinkFromObjects:self.allBlinksArray];
    [self reloadTableData];
}

- (BOOL)blinkArray:(NSArray*)blinkArray containsBlink:(PFObject*)targetedBlink {
    for (PFObject *blink in blinkArray) {
        if ([blink.objectId isEqualToString:targetedBlink.objectId]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)deletedBlink:(NSNotification*)note {
    PFObject *blinkToDelete = note.object;
    [self updateForDeletingBlink:blinkToDelete];
}

#pragma mark - UITableViewDelegate / UITableViewDataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[BIHomeTableViewCell class]]) {
        return YES;
    }
         
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIActionSheet *deleteActionSheet = [[UIActionSheet alloc] initWithTitle:@"This will permanently delete your entry. Are you sure?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
        deleteActionSheet.tag = kDeletePreviousBlinkActionSheet;
        deleteActionSheet.accessibilityLabel = [NSString stringWithFormat:@"%d",indexPath.row];
        [deleteActionSheet showFromTabBar:self.tabBarController.tabBar];
    }
}

- (void)deleteBlinkAtIndex:(NSInteger)row {
    PFObject *blinkToDelete = [self.allBlinksArray objectAtIndex:row];

    [BIDeleteBlinkHelper deleteBlink:blinkToDelete completion:^(NSError* error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error deleting your entry. Please try again!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }];
}

- (void)updateForDeletingBlink:(PFObject*)blinkToDelete {
    if ([[blinkToDelete objectId] isEqualToString:[_todaysBlink objectId]]) {
        _todaysBlink = nil;
    }
    
    [self.allBlinksArray removeObject:blinkToDelete];
    [self reloadTableData];
    [_homeHeaderView updateBlinkCountWithIncrement:NO];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == kDeletePreviousBlinkActionSheet) {
        if (buttonIndex == actionSheet.destructiveButtonIndex) {
            NSInteger indexOfDeletedBlink = [actionSheet.accessibilityLabel integerValue];
            [self deleteBlinkAtIndex:indexOfDeletedBlink];
            
            [BIMixpanelHelper sendMixpanelEvent:@"MYBLINKS_deletedPreviousBlink" withProperties:nil];
        }
    }
}

#pragma mark - BIHomeTableViewCellDelegate

- (void)homeCell:(BIHomeTableViewCell*)homeCell togglePrivacyTo:(BOOL)private {
    _togglePrivacyCell = homeCell;
    
    NSString *msg = private ? @"Are you sure you want to make this blink private?" : @"Are you sure you want to make this blink public to your followers?";

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Toggle Privacy Setting" message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue",nil];
    alertView.tag = private;
    [alertView show];
}

#pragma mark - BIHomeHeaderViewDelegate

- (void)headerView:(BIHomeHeaderView*)headerView didTapFollowersButton:(UIButton*)button {
    
    UIStoryboard *mainStoryboard = [UIStoryboard mainStoryboard];
    BIFollowersViewController *followersVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"BIFollowersViewController"];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:followersVC];
    [self presentViewController:nav animated:YES completion:nil];
    
    _shouldRefreshNumbers = YES;
}

- (void)headerView:(BIHomeHeaderView*)headerView didTapFollowingButton:(UIButton*)button {
    UIStoryboard *mainStoryboard = [UIStoryboard mainStoryboard];
    BIFollowingViewController *followingVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"BIFollowingViewController"];
    followingVC.showUnfollowingFacebookFriends = NO;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:followingVC];
    [self presentViewController:nav animated:YES completion:nil];
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    // remember to reset toggle properties after its over
    if (buttonIndex != alertView.cancelButtonIndex) {
        BOOL newPrivacySetting = alertView.tag;
        
        PFObject *blink = _togglePrivacyCell.blink;
        blink[@"private"] = [NSNumber numberWithBool:newPrivacySetting];
    
        [blink saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kBIBlinkPrivacyUpdatedNotification object:blink];
                [_togglePrivacyCell updatePrivacyButtonTo:newPrivacySetting];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Privacy setting was not updated. Please try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
            
            _togglePrivacyCell = nil;
        }];
        
        [BIMixpanelHelper sendMixpanelEvent:@"MYBLINKS_updatePrivacyOfPreviousBlink" withProperties:@{@"changeToPrivate":@(newPrivacySetting)}];
    }
}

#pragma mark - ibactions

- (void)tappedSettings:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard mainStoryboard];
    
    UINavigationController *settingsNav = [mainStoryboard instantiateViewControllerWithIdentifier:@"BISettingsNavigationController"];
    [self presentViewController:settingsNav animated:YES completion:nil];
}

- (void)presentTodaysBlinkVC {
    UIStoryboard *mainStoryboard = [UIStoryboard mainStoryboard];
    UINavigationController *nav = [mainStoryboard instantiateViewControllerWithIdentifier:@"BIComposeBlinkNavigationController"];
    BIComposeBlinkViewController *todaysBlinkVC = (BIComposeBlinkViewController*)nav.topViewController;
    todaysBlinkVC.blink = _todaysBlink;
    
    [self presentViewController:nav animated:YES completion:nil];
    
    [BIMixpanelHelper sendMixpanelEvent:@"TODAY_composeBlink" withProperties:nil];
}



@end
