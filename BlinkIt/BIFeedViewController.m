//
//  BIFeedViewController.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/31/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIFeedViewController.h"
#import "BIProfileViewController.h"
#import "BIFollowingViewController.h"
#import <MessageUI/MessageUI.h>

#define kNumFeedEntriesPerPage 15

@interface BIFeedViewController () < MFMailComposeViewControllerDelegate>

@property (nonatomic, assign) BOOL isPresentingOtherVC;

@end

@implementation BIFeedViewController

#pragma mark - lifecycle

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.useRefreshTableHeaderView = YES;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupButtons];
    [self setupNav];
    [self setupObservers];
    [self fetchFeedForPagination:NO];
}

- (void)setupButtons {
    UIImage *friendsImage = [[UIImage imageNamed:@"add-friend"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    BIButton *friendsButton = [BIButton buttonWithType:UIButtonTypeCustom];
    friendsButton.frame = CGRectMake(0, 0, 30, 30);
    friendsButton.barButtonSide = BIBarButtonTypeRight;
    [friendsButton setImage:friendsImage forState:UIControlStateNormal];
    [friendsButton addTarget:self action:@selector(tappedFriends:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:friendsButton];
    
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

- (void)setupNav {
    self.navigationController.navigationBar.barTintColor = [UIColor mintGreen];
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    logoImageView.frame = CGRectMake(0, 0, 160, 24);
    logoImageView.autoresizingMask = self.navigationItem.titleView.autoresizingMask;
    self.navigationItem.titleView = logoImageView;
}

- (void)setupObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFeed) name:kBIRefreshHomeAndFeedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateForTodaysBlink:) name:kBIUpdateSavedBlinkNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deletedBlink:) name:kBIDeleteBlinkNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggledBlinkPrivacy:) name:kBIBlinkPrivacyUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFeed) name:kBIDidUpdateFollowedFriends object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_isPresentingOtherVC) {
        [self refreshFeed];
    }
    
    _isPresentingOtherVC = NO;
}


#pragma mark - requests

- (void)fetchFeedForPagination:(BOOL)pagination {
    if (self.isLoading) return;
    self.loading = YES;
    
    // ppl i'm following + me
    NSMutableArray *followedFriends = [[BIDataStore shared].followedFriends mutableCopy];
    NSString *myID = [[PFUser currentUser] objectForKey:@"facebookID"];
    if (myID) {
        [followedFriends addObject:myID];
    }
    
    PFQuery *followedUsers = [PFUser query];
    [followedUsers whereKey:@"facebookID" containedIn:followedFriends];

    // their public blinks
    PFQuery *blinksFromFollowed = [PFQuery queryWithClassName:@"Blink"];
    blinksFromFollowed.limit = kNumFeedEntriesPerPage;
    blinksFromFollowed.skip = pagination ? self.allBlinksArray.count : 0;
    [blinksFromFollowed whereKey:@"user" matchesQuery:followedUsers];
    [blinksFromFollowed includeKey:@"user"];
    [blinksFromFollowed whereKey:@"private" equalTo:@NO];
    [blinksFromFollowed orderByDescending:@"date"];
    
    [blinksFromFollowed findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.loading = NO;

        if (!error) {
            self.canPaginate = objects.count > 0 && (objects.count % kNumFeedEntriesPerPage == 0);

            NSMutableArray *blinks = pagination ? [[self.allBlinksArray arrayByAddingObjectsFromArray:objects] mutableCopy] : [objects mutableCopy];
            self.allBlinksArray = [blinks mutableCopy];
            
            [self sectionalizeBlinks:blinks pagination:pagination];
        }
    }];
    
    if (pagination) {
        [BIMixpanelHelper sendMixpanelEvent:@"FEED_paginateFeed" withProperties:nil];
    }
}

- (void)refreshFeed {
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    [self fetchFeedForPagination:NO];
}

#pragma mark - refresh and pagination

- (void)refreshTableHeaderDidTriggerRefresh {
    [self fetchFeedForPagination:NO];
}

- (void)performPaginationRequestIfNecessary {
    if([self hasReachedTableEnd:self.tableView] && self.canPaginate) {
        [self fetchFeedForPagination:YES];
    }
}

#pragma mark - UITableViewDelegate / UITableViewDataSource

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Report";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([MFMailComposeViewController canSendMail]) {
            NSArray *blinksOnDate = [self.blinksArray objectAtIndex:indexPath.section];
            PFObject *inappropBlink = [blinksOnDate objectAtIndex:indexPath.row];
            PFUser *me = [PFUser currentUser];
            
            NSString *msg = [NSString stringWithFormat:@"I am reporting this post as inappropriate because:\n\n\n\nFor Internal Use\nPost ID: %@\nSender ID: %@", inappropBlink.objectId, me.objectId];
            MFMailComposeViewController *contactUsMailComposeViewController = [[MFMailComposeViewController alloc] init];
            [contactUsMailComposeViewController setMailComposeDelegate:self];
            [contactUsMailComposeViewController setSubject:@"Reporting inappropriate content"];
            [contactUsMailComposeViewController setToRecipients:[NSArray arrayWithObject:@"blinkit.contact@gmail.com"]];
            [contactUsMailComposeViewController setMessageBody:msg isHTML:NO];
            [self.navigationController presentViewController:contactUsMailComposeViewController animated:YES completion:nil];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mail App Not Configured" message:@"Contact us at blinkit.contact@gmail.com. To send email from this app, you must configure your account in the Mail app." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - button actions

- (void)tappedFriends:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard mainStoryboard];
    UINavigationController *nav = nil;
    
    if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        BIFollowingViewController *followingVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"BIFollowingViewController"];
        followingVC.showUnfollowingFacebookFriends = YES;
        nav = [[UINavigationController alloc] initWithRootViewController:followingVC];
    } else {
        nav = [mainStoryboard instantiateViewControllerWithIdentifier:@"BIFollowNavigationController"];
    }
    
    [self presentViewController:nav animated:YES completion:nil];
    _isPresentingOtherVC = YES;
    
    [BIMixpanelHelper sendMixpanelEvent:@"FOLLOW_tappedFriendsButton" withProperties:nil];
}

- (void)updateForTodaysBlink:(NSNotification*)note {
    PFObject *updatedBlink = note.object;
    
    if (![updatedBlink[@"private"] boolValue]) {
        PFObject *existingBlink = [self blinkWithID:updatedBlink.objectId fromBlinks:self.allBlinksArray];
        if (existingBlink) {
            [self.allBlinksArray removeObject:existingBlink];
        }
        
        [self.allBlinksArray insertObject:updatedBlink atIndex:0];
        [self sectionalizeBlinks:self.allBlinksArray pagination:NO];
    } else {
        PFObject *privatedBlink = [self blinkWithID:updatedBlink.objectId fromBlinks:self.allBlinksArray];
        [self.allBlinksArray removeObject:privatedBlink];
        [self sectionalizeBlinks:self.allBlinksArray pagination:NO];
    }
}

- (PFObject*)blinkWithID:(NSString*)objectID fromBlinks:(NSArray*)blinkArray {
    for (PFObject *blink in blinkArray) {
        if ([[blink objectId] isEqualToString:objectID]) {
            return blink;
        }
    }
    
    return nil;
}

- (void)deletedBlink:(NSNotification*)note {
    PFObject *deletedBlink = note.object;
    PFObject *deletedBlinkInArray = [self blinkWithID:deletedBlink.objectId fromBlinks:self.allBlinksArray];
    [self.allBlinksArray removeObject:deletedBlinkInArray];
    [self sectionalizeBlinks:self.allBlinksArray pagination:NO];
}

- (void)toggledBlinkPrivacy:(NSNotification*)note {
    PFObject *updatedBlink = note.object;
    
    if ([updatedBlink[@"private"] boolValue]) {
        PFObject *updatedBlinkInArray = [self blinkWithID:updatedBlink.objectId fromBlinks:self.allBlinksArray];
        [self.allBlinksArray removeObject:updatedBlinkInArray];
        [self sectionalizeBlinks:self.allBlinksArray pagination:NO];
    } else {
        [self refreshFeed];
    }
}

@end
