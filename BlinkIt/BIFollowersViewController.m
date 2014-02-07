//
//  BIFollowersViewController.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/31/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIFollowersViewController.h"
#import "BIFollowingTableViewCell.h"

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
    PFQuery *followersQuery = [PFQuery queryWithClassName:@"Activity"];
    [followersQuery whereKey:@"toUser" equalTo:[PFUser currentUser]];
    [followersQuery whereKey:@"type" equalTo:@"follow"];
    [followersQuery orderByAscending:@"name"];
    [followersQuery includeKey:@"fromUser"];
    [followersQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
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
    return _followersArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [BIFollowingTableViewCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PFUser *user = [_followersArray objectAtIndex:indexPath.row];
    BIFollowingTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BIFollowingTableViewCell reuseIdentifier]];
    
    cell.user = user;
    
    return cell;
}

@end
