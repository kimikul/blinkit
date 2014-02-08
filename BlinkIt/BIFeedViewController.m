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
@property (nonatomic, strong) NSArray *dateArray;       // array of dates with 1+ associated blinks
@property (nonatomic, strong) NSArray *blinksArray;     // array of array of blinks associated with the date
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
    [self setupNav];
    [self fetchFeed];
}

- (void)setupButtons {
    UIImage *friendsImage = [[UIImage imageNamed:@"Tab-friends"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIBarButtonItem *friendsButton = [[UIBarButtonItem alloc] initWithImage:friendsImage style:UIBarButtonItemStylePlain target:self action:@selector(tappedFriends:)];
    self.navigationItem.rightBarButtonItem = friendsButton;
}

- (void)setupNav {
    self.navigationController.navigationBar.barTintColor = [UIColor mintGreen];
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    logoImageView.frame = CGRectMake(0, 0, 160, 24);
    logoImageView.autoresizingMask = self.navigationItem.titleView.autoresizingMask;
    self.navigationItem.titleView = logoImageView;
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
            [self sectionalizeBlinks:objects];
        }
    }];
}

- (void)sectionalizeBlinks:(NSArray*)blinks {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMMM dd, YYYY"];
    
    NSMutableArray *dateArray = [NSMutableArray new];
    NSMutableArray *blinkArray = [NSMutableArray new];
    NSMutableArray *innerBlinkArray = [NSMutableArray new];
    
    for (PFObject *blink in blinks) {
        NSDate *date = blink[@"date"];
        NSString *spelledOutDate = [NSDate spelledOutDate:date];
        if (![dateArray containsObject:spelledOutDate]) {
            [dateArray addObject:spelledOutDate];
            innerBlinkArray = [NSMutableArray arrayWithObject:blink];
        } else {
            [innerBlinkArray addObject:blink];
        }
        
        NSInteger index = [dateArray indexOfObject:spelledOutDate];
        [blinkArray setObject:innerBlinkArray atIndexedSubscript:index];
    }
    
    _dateArray = [dateArray copy];
    _blinksArray = [blinkArray copy];
    
    [self reloadTableData];
}

#pragma mark - UITableViewDelegate / UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dateArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *blinksOnDate = [_blinksArray objectAtIndex:section];
    
    return blinksOnDate.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSArray *blinksOnDate = [_blinksArray objectAtIndex:indexPath.section];
    PFObject *blink = [blinksOnDate objectAtIndex:indexPath.row];
    
    return [BIFeedTableViewCell heightForContent:blink[@"content"]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 34;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *date = [_dateArray objectAtIndex:section];

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,34)];
    headerView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    headerView.layer.borderColor = [UIColor whiteColor].CGColor;
    headerView.layer.borderWidth = 3.0;
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,0,300,34)];
    dateLabel.text = date;
    dateLabel.font = [UIFont boldSystemFontOfSize:15];
    dateLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    [headerView addSubview:dateLabel];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *blinksOnDate = [_blinksArray objectAtIndex:indexPath.section];
    PFObject *blink = [blinksOnDate objectAtIndex:indexPath.row];
    
    BIFeedTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BIFeedTableViewCell reuseIdentifier]];
    
    cell.blink = blink;
    
    return cell;
}

#pragma mark - button actions

- (void)tappedFriends:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard mainStoryboard];
    UINavigationController *nav = [mainStoryboard instantiateViewControllerWithIdentifier:@"BIFollowNavigationController"];
    
    [self presentViewController:nav animated:YES completion:nil];
}


@end
