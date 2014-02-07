//
//  BIFeedViewController.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/31/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIFeedViewController.h"
#import "BIFollowViewController.h"
#import "BIPaginationTableViewCell.h"
#import "BINoFollowResultsTableViewCell.h"
#import "BIFeedTableViewCell.h"

@interface BIFeedViewController ()
@property (nonatomic, strong) NSArray *blinksArray;
@end

@implementation BIFeedViewController

#pragma mark - lifecycle

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.useEmptyTableFooter = YES;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupButtons];
    [self fetchFeed];
}

- (void)setupButtons {
    UIImage *friendsImage = [[UIImage imageNamed:@"Tab-friends"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIBarButtonItem *friendsButton = [[UIBarButtonItem alloc] initWithImage:friendsImage style:UIBarButtonItemStylePlain target:self action:@selector(tappedFriends:)];
    self.navigationItem.rightBarButtonItem = friendsButton;
}

#pragma mark - requests

- (void)fetchFeed {
    self.loading = YES;
    
    // Query for the friends the current user is following
    PFQuery *followedUsers = [PFUser query];
    [followedUsers whereKey:@"facebookID" containedIn:[BIDataStore shared].followedFriends];
    
    // Using the activities from the query above, we find all of the photos taken by
    // the friends the current user is following
    PFQuery *blinksFromFollowed = [PFQuery queryWithClassName:@"Blink"];
    [blinksFromFollowed whereKey:@"user" matchesQuery:followedUsers];
    [blinksFromFollowed includeKey:@"user"];
    [blinksFromFollowed orderByDescending:@"updatedAt"];
    
    [blinksFromFollowed findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.loading = NO;
        
        if (!error) {
            _blinksArray = objects;
            [self reloadTableData];
        }
    }];
}

#pragma mark - UITableViewDelegate / UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_blinksArray.count == 0) {
        return 1;
    }
    
    return _blinksArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isLoading) {
        return [BIPaginationTableViewCell cellHeight];
    } else if (_blinksArray.count == 0) {
        return [BINoFollowResultsTableViewCell cellHeight];
    } else {
        PFObject *blink = [_blinksArray objectAtIndex:indexPath.row];
        return [BIFeedTableViewCell heightForContent:blink[@"content"]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isLoading) {
        BIPaginationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BIPaginationTableViewCell reuseIdentifier]];
        [cell.aiv startAnimating];
        return cell;
    } else if (_blinksArray.count == 0) {
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        BINoFollowResultsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BINoFollowResultsTableViewCell reuseIdentifier]];
        return cell;
    } else {
        PFObject *blink = [_blinksArray objectAtIndex:indexPath.row];
        BIFeedTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BIFeedTableViewCell reuseIdentifier]];
        
        cell.blink = blink;
        
        return cell;
    }
}

#pragma mark - button actions

- (void)tappedFriends:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard mainStoryboard];
    UINavigationController *nav = [mainStoryboard instantiateViewControllerWithIdentifier:@"BIFollowNavigationController"];
    
    [self presentViewController:nav animated:YES completion:nil];
}


@end
