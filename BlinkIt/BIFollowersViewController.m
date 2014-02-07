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

@interface BIFollowersViewController ()
@property (nonatomic, strong) NSArray *followersArray;
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
    [self fetchFollowers];
}

- (void)fetchFollowers {
    self.loading = YES;
    
    PFQuery *followersQuery = [PFQuery queryWithClassName:@"Activity"];
    [followersQuery whereKey:@"toUser" equalTo:[PFUser currentUser]];
    [followersQuery whereKey:@"type" equalTo:@"follow"];
    [followersQuery orderByAscending:@"name"];
    [followersQuery includeKey:@"fromUser"];
    [followersQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.loading = NO;
        
        if (!error) {
            NSMutableArray *followers = [NSMutableArray new];
            for (PFObject *activity in objects) {
                PFUser *user = activity[@"fromUser"];
                [followers addObject:user];
            }
            
            _followersArray = followers;
            [self reloadTableData];
        }
    }];
}

#pragma mark - UITableViewDelegate / UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_followersArray.count == 0) {
        return 1;
    }
    
    return _followersArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isLoading) {
        return [BIPaginationTableViewCell cellHeight];
    } else if (_followersArray.count == 0) {
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
    } else if (_followersArray.count == 0) {
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        BINoFollowResultsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BINoFollowResultsTableViewCell reuseIdentifier]];
        return cell;
    } else {
        PFUser *user = [_followersArray objectAtIndex:indexPath.row];
        BIFollowingTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BIFollowingTableViewCell reuseIdentifier]];
        
        cell.user = user;
        
        return cell;
    }
}

@end
