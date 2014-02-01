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

@interface BIFollowingViewController () <BIFollowingTableViewCellDelegate>
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
    NSArray *facebookFriends = [BIDataStore shared].facebookFriends.allKeys;

    PFQuery *friendsQuery = [PFUser query];
    [friendsQuery whereKey:@"facebookID" containedIn:facebookFriends];
    [friendsQuery orderByAscending:@"name"];
    [friendsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        _friendsArray = objects;
        [self reloadTableData];
    }];
}

#pragma mark - UITableViewDelegate / UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _friendsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [BIFollowingTableViewCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PFUser *user = [_friendsArray objectAtIndex:indexPath.row];
    BIFollowingTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BIFollowingTableViewCell reuseIdentifier]];
    
    cell.delegate = self;
    cell.user = user;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - BIFollowingTableViewCellDelegate

- (void)followingCell:(BIFollowingTableViewCell*)followingCell tappedFollowButton:(UIButton*)button {
    PFUser *user = followingCell.user;
    
    if (followingCell.followButton.isSelected) {
        followingCell.followButton.selected = NO;
        [BIFollowManager unfollowUserEventually:user block:^(NSError *error) {
            if (!error) {
                [[BIDataStore shared] removeFollowedFriend:user];
            }
        }];
    } else {
        followingCell.followButton.selected = YES;
        [BIFollowManager followUserEventually:user block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [[BIDataStore shared] addFollowedFriend:user];
            }
        }];
    }
}

@end