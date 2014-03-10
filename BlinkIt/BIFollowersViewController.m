//
//  BIFollowersViewController.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/31/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIFollowersViewController.h"
#import "BIFollowingTableViewCell.h"
#import "BIPaginationTableViewCell.h"
#import "BINoFollowResultsTableViewCell.h"
#import "BIPendingRequestTableViewCell.h"
#import "BIProfileViewController.h"

#define kTABLE_SECTION_REQUESTS 0
#define kTABLE_SECTION_FOLLOWERS 1

@interface BIFollowersViewController () <BIPendingRequestTableViewCellDelegate>
@property (nonatomic, strong) NSMutableArray *followersArray;          // array of users
@property (nonatomic, strong) NSMutableArray *requestToFollowArray;    // array of Activitys
@end

@implementation BIFollowersViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.useEmptyTableFooter = YES;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNav];
    [self fetchFollowers];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [BIMixpanelHelper sendMixpanelEvent:@"FOLLOW_viewedFollowers" withProperties:nil];
}

- (void)setupNav {
    if (self.navigationController) {
        self.title = @"Followers";
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneTapped:)];
        doneButton.tintColor = [UIColor coral];
        self.navigationItem.rightBarButtonItem = doneButton;
    }
}

- (void)fetchFollowers {
    self.loading = YES;
    
    PFQuery *followersQuery = [PFQuery queryWithClassName:@"Activity"];
    [followersQuery whereKey:@"toUser" equalTo:[PFUser currentUser]];
    [followersQuery orderByAscending:@"name"];
    [followersQuery includeKey:@"fromUser"];
    [followersQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.loading = NO;
        
        if (!error) {
            NSMutableArray *followers = [NSMutableArray new];
            NSMutableArray *requestsToFollow = [NSMutableArray new];
            for (PFObject *activity in objects) {
                PFUser *user = activity[@"fromUser"];
                NSString *type = activity[@"type"];
                if ([type isEqualToString:@"follow"]) {
                    [followers addObject:user];
                } else if ([type isEqualToString:@"request to follow"]) {
                    [requestsToFollow addObject:activity];
                }
            }
            
            _followersArray = followers;
            _requestToFollowArray = requestsToFollow;
            
            [self reloadTableData];
        }
    }];
}

#pragma mark - UITableViewDelegate / UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kTABLE_SECTION_REQUESTS) {
        return _requestToFollowArray.count;
    } else {
        if (_followersArray.count == 0) {
            return 1;
        }
        
        return _followersArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kTABLE_SECTION_REQUESTS) {
        return [BIPendingRequestTableViewCell cellHeight];
    } else {
        if (self.isLoading) {
            return [BIPaginationTableViewCell cellHeight];
        } else if (_followersArray.count == 0) {
            return [BINoFollowResultsTableViewCell cellHeight];
        } else {
            return [BIFollowingTableViewCell cellHeight];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat height = 34;
    
    if (section == kTABLE_SECTION_REQUESTS) {
        return (_requestToFollowArray.count == 0) ? 0 : height;
    } else {
        return height;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *emptyView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (section == kTABLE_SECTION_REQUESTS) {
        NSInteger numRequests = _requestToFollowArray.count;
        NSString *title = [NSString stringWithFormat:@"Pending Requests (%d)",numRequests];
        return (_requestToFollowArray.count == 0) ? emptyView : [self headerWithTitle:title];
    } else {
        NSInteger numFollowers = _followersArray.count;
        NSString *title = [NSString stringWithFormat:@"Followers (%d)",numFollowers];
        return [self headerWithTitle:title];
    }
}

- (UIView*)headerWithTitle:(NSString*)title {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,34)];
    headerView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    headerView.layer.borderColor = [UIColor whiteColor].CGColor;
    headerView.layer.borderWidth = 3.0;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,0,300,34)];
    titleLabel.text = title;
    titleLabel.font = [UIFont fontWithName:@"Thonburi" size:17.0];
    titleLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    [headerView addSubview:titleLabel];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kTABLE_SECTION_REQUESTS) {
        PFObject *activity = [_requestToFollowArray objectAtIndex:indexPath.row];
        BIPendingRequestTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BIPendingRequestTableViewCell reuseIdentifier]];
        
        cell.delegate = self;
        cell.activity = activity;
        
        return cell;
    } else {
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;

        if (self.isLoading) {
            BIPaginationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BIPaginationTableViewCell reuseIdentifier]];
            [cell.aiv startAnimating];
            return cell;
        } else if (_followersArray.count == 0) {
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            
            BINoFollowResultsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BINoFollowResultsTableViewCell reuseIdentifier]];
            return cell;
        } else {
            PFUser *user = [_followersArray objectAtIndex:indexPath.row];
            BIFollowingTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BIFollowingTableViewCell reuseIdentifier]];
            
            cell.user = user;
            cell.followButton.hidden = YES;
            
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // do not allow selection on cells not connected to users
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (![cell isKindOfClass:[BIFollowingTableViewCell class]]) return;
    
    PFUser *user = [_followersArray objectAtIndex:indexPath.row];
    
    UIStoryboard *mainStoryboard = [UIStoryboard mainStoryboard];
    
    UINavigationController *profileNav = [mainStoryboard instantiateViewControllerWithIdentifier:@"BIProfileNavigationController"];
    BIProfileViewController *profileVC = (BIProfileViewController*)profileNav.topViewController;
    profileVC.user = user;
    [self presentViewController:profileNav animated:YES completion:nil];
}

#pragma mark - BIFollowingTableViewCellDelegate

- (void)pendingRequestCell:(BIPendingRequestTableViewCell*)cell tappedAcceptRequestForUser:(PFUser*)user error:(NSError*)error {
    if (!error) {
        [_followersArray addObject:user];
        [_requestToFollowArray removeObject:cell.activity];

        [self reloadTableData];
        
        [BINotificationHelper decrementBadgeCount];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error accepting this follower. Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    [BIMixpanelHelper sendMixpanelEvent:@"FOLLOW_acceptedFollower" withProperties:nil];
}

- (void)pendingRequestCell:(BIPendingRequestTableViewCell*)cell tappedIgnoreRequestForUser:(PFUser*)user {
    [_requestToFollowArray removeObject:cell.activity];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
//    [self reloadTableData];
    [BINotificationHelper decrementBadgeCount];
}

#pragma mark - ibactions

- (void)doneTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
