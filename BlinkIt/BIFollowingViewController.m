//
//  BIFollowingViewController.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/31/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIFollowingViewController.h"
#import "BIFollowingTableViewCell.h"
#import "BIPaginationTableViewCell.h"
#import "BINoFollowResultsTableViewCell.h"
#import "BIProfileViewController.h"

@interface BIFollowingViewController ()
@property (nonatomic, strong) NSArray *friendsArray;
@end

@implementation BIFollowingViewController

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
    [self fetchFriends];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [BIMixpanelHelper sendMixpanelEvent:@"FOLLOW_viewedFollowing" withProperties:nil];
}

- (void)setupNav {
    if (self.navigationController) {
        self.title = @"Following";
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneTapped:)];
        doneButton.tintColor = [UIColor coral];
        self.navigationItem.rightBarButtonItem = doneButton;
    }
}

- (void)fetchFriends {
    self.loading = YES;
    
    NSArray *facebookFriends = [BIDataStore shared].facebookFriends.allKeys;

    PFQuery *friendsQuery = [PFUser query];
    [friendsQuery whereKey:@"facebookID" containedIn:facebookFriends];
    [friendsQuery orderByAscending:@"name"];
    [friendsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.loading = NO;
        
        _friendsArray = objects;
        [self reloadTableData];
    }];
}

#pragma mark - UITableViewDelegate / UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_friendsArray.count == 0) {
        return 1;
    }
    
    return _friendsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isLoading) {
        return [BIPaginationTableViewCell cellHeight];
    } else if (_friendsArray.count == 0) {
        return [BINoFollowResultsTableViewCell cellHeight];
    } else {
        return [BIFollowingTableViewCell cellHeight];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return (_friendsArray.count == 0) ? 0 : 34;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *emptyView = [[UIView alloc] initWithFrame:CGRectZero];

    if (_friendsArray.count == 0) {
        return emptyView;
    } else {
        NSInteger numFollowing = [[BIDataStore shared] followedFriends].count;
        NSString *title = [NSString stringWithFormat:@"Following (%d)", numFollowing];
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
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;

    if (self.isLoading) {
        BIPaginationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BIPaginationTableViewCell reuseIdentifier]];
        [cell.aiv startAnimating];
        return cell;
    } else if (_friendsArray.count == 0) {
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

        BINoFollowResultsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BINoFollowResultsTableViewCell reuseIdentifier]];
        return cell;
    } else {
        PFUser *user = [_friendsArray objectAtIndex:indexPath.row];
        BIFollowingTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BIFollowingTableViewCell reuseIdentifier]];
        
        cell.user = user;
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // do not allow selection on cells not connected to users
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (![cell isKindOfClass:[BIFollowingTableViewCell class]]) return;
    
    PFUser *user = [_friendsArray objectAtIndex:indexPath.row];
    
    UIStoryboard *mainStoryboard = [UIStoryboard mainStoryboard];
    
    UINavigationController *profileNav = [mainStoryboard instantiateViewControllerWithIdentifier:@"BIProfileNavigationController"];
    BIProfileViewController *profileVC = (BIProfileViewController*)profileNav.topViewController;
    profileVC.user = user;
    [self presentViewController:profileNav animated:YES completion:nil];
}

#pragma mark - ibactions

- (void)doneTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
