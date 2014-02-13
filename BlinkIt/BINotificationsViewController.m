//
//  BINotificationsViewController.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 2/12/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BINotificationsViewController.h"
#import "BINoFollowResultsTableViewCell.h"
#import "BIPaginationTableViewCell.h"
#import "BINotificationFollowRequestCell.h"

#define kNumNotificationsPerPage 15

@interface BINotificationsViewController () <BINotificationFollowRequestCellDelegate>
@property (nonatomic, strong) NSMutableArray *notificationsArray;  // array of Activitys
@end

@implementation BINotificationsViewController

#pragma mark - init

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.useEmptyTableFooter = YES;
        self.useRefreshTableHeaderView = YES;
    }
    
    return self;
}

#pragma mark - lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupButtons];
    
    [self fetchNotifications];
}

- (void)setupButtons {
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneTapped:)];
    self.navigationItem.rightBarButtonItem = doneButton;
}

#pragma mark - requests

- (void)fetchNotifications {
    self.loading = YES;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query whereKey:@"toUser" equalTo:[PFUser currentUser]];
    [query whereKey:@"type" equalTo:@"request to follow"];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"fromUser"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            
            _notificationsArray = [objects mutableCopy];
            [self reloadTableData];
        }
        
        self.loading = NO;
    }];

}

#pragma mark - UITableViewDelegate / UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // no results row
    if (_notificationsArray.count == 0) {
        return 1;
    }
    
    return _notificationsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // no results row
    if (_notificationsArray.count == 0 && !self.isLoading) {
        return [BINoFollowResultsTableViewCell cellHeight];
    }
    
    // pagination row
    if (indexPath.row == _notificationsArray.count) {
        return [BIPaginationTableViewCell cellHeight];
    }
    
    // regular row
    return [BINotificationFollowRequestCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // no results row
    if (_notificationsArray.count == 0 && !self.isLoading) {
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        BINoFollowResultsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BINoFollowResultsTableViewCell reuseIdentifier]];
        return cell;
    }
    
    // pagination row
    if (indexPath.row == _notificationsArray.count) {
        BIPaginationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BIPaginationTableViewCell reuseIdentifier]];
        [cell.aiv startAnimating];
        return cell;
    }
    
    // regular row
    PFObject *activity = [_notificationsArray objectAtIndex:indexPath.row];
    BINotificationFollowRequestCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BINotificationFollowRequestCell reuseIdentifier]];

    cell.activity = activity;
    cell.delegate = self;
    
    return cell;
}

#pragma mark - BINotificationFollowRequestCellDelegate

- (void)notificationCell:(BINotificationFollowRequestCell*)cell tappedAcceptRequestForActivity:(PFObject*)activity error:(NSError*)error {
    if (!error) {
        [_notificationsArray removeObject:activity];
        [self reloadTableData];
        
        [BINotificationHelper decrementBadgeCount];
    }
}

#pragma mark - ibactions

- (void)doneTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

