//
//  BIFollowingViewController.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/31/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIFollowingViewController.h"
#import "BIFollowingTableViewCell.h"
#import "BIFollowManager.h"
#import "BIPaginationTableViewCell.h"
#import "BINoFollowResultsTableViewCell.h"

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
    [self fetchFriends];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
}

@end
