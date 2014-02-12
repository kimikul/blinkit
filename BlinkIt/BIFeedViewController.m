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
#import "BIFeedPhotoTableViewCell.h"

#define kNumFeedEntriesPerPage 15

@interface BIFeedViewController ()
@property (nonatomic, strong) NSMutableArray *allBlinksArray; // total list of blinks displayed

@property (nonatomic, strong) NSArray *dateArray;       // array of dates with 1+ associated blinks
@property (nonatomic, strong) NSArray *blinksArray;     // array of array of blinks associated with the date

@property (nonatomic, assign) BOOL canPaginate;
@property (nonatomic, assign) BOOL isPresentingOtherVC;
@end

@implementation BIFeedViewController

#pragma mark - getter/setter

- (NSMutableArray*)allBlinksArray {
    if (!_allBlinksArray) {
        _allBlinksArray = [NSMutableArray new];
    }
    
    return _allBlinksArray;
}

#pragma mark - lifecycle

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.useEmptyTableFooter = YES;
        self.useRefreshTableHeaderView = YES;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupButtons];
    [self setupTableView];
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

- (void)setupTableView {
    [self.tableView registerNib:[UINib nibWithNibName:[BIFeedPhotoTableViewCell reuseIdentifier] bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[BIFeedPhotoTableViewCell reuseIdentifier]];
    [self.tableView registerNib:[UINib nibWithNibName:[BIFeedTableViewCell reuseIdentifier] bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[BIFeedTableViewCell reuseIdentifier]];
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
    
    // ppl i'm following
    PFQuery *followedUsers = [PFUser query];
    [followedUsers whereKey:@"facebookID" containedIn:[BIDataStore shared].followedFriends];
    
    // their public blinks
    PFQuery *blinksFromFollowed = [PFQuery queryWithClassName:@"Blink"];
    blinksFromFollowed.limit = kNumFeedEntriesPerPage;
    blinksFromFollowed.skip = pagination ? self.allBlinksArray.count : 0;
    [blinksFromFollowed whereKey:@"user" matchesQuery:followedUsers];
    [blinksFromFollowed includeKey:@"user"];
    [blinksFromFollowed whereKey:@"private" equalTo:@NO];
    [blinksFromFollowed orderByDescending:@"date"];
    
    [blinksFromFollowed findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.canPaginate = objects.count > 0 && (objects.count % kNumFeedEntriesPerPage == 0);

            NSMutableArray *blinks = pagination ? [[self.allBlinksArray arrayByAddingObjectsFromArray:objects] mutableCopy] : [objects mutableCopy];
            self.allBlinksArray = [blinks copy];
            
            [self sectionalizeBlinks:objects pagination:pagination];
        }
        
        self.loading = NO;
    }];
    
    if (pagination) {
        [BIMixpanelHelper sendMixpanelEvent:@"FEED_paginateFeed" withProperties:nil];
    }
}

- (void)sectionalizeBlinks:(NSArray*)blinks pagination:(BOOL)pagination {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMMM dd, YYYY"];
    
    NSMutableArray *dateArray = pagination ? [_dateArray mutableCopy] :[NSMutableArray new];
    NSMutableArray *blinkArray = pagination ? [_blinksArray mutableCopy] : [NSMutableArray new];
    NSMutableArray *innerBlinkArray = pagination ? [[_blinksArray lastObject] mutableCopy] : [NSMutableArray new];
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_dateArray.count == 0) {
        return 1;
    }
    
    return _dateArray.count + self.canPaginate;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_dateArray.count == 0) {
        return 1;
    }
    
    if (self.canPaginate && (section == _dateArray.count)) {
        return 1;
    }
    
    NSArray *blinksOnDate = [_blinksArray objectAtIndex:section];
    return blinksOnDate.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (self.isLoading && _dateArray.count == 0) {
        return [BIPaginationTableViewCell cellHeight];
    } else if (_dateArray.count == 0) {
        return [BINoFollowResultsTableViewCell cellHeight];
    } else if (self.canPaginate && (indexPath.section == _dateArray.count)) {
        return [BIPaginationTableViewCell cellHeight];
    }

    NSArray *blinksOnDate = [_blinksArray objectAtIndex:indexPath.section];
    PFObject *blink = [blinksOnDate objectAtIndex:indexPath.row];
    
    CGFloat height = 0;
    NSString *content = blink[@"content"];
    PFFile *imageFile = blink[@"imageFile"];
    
    if (imageFile) {
        height = [BIFeedPhotoTableViewCell heightForContent:content];
    } else {
        height = [BIFeedTableViewCell heightForContent:content];
    }
    
    return height;
    
    return [BIFeedTableViewCell heightForContent:blink[@"content"]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (_dateArray.count == 0) {
        return 0;
    } else if (self.canPaginate && (section == _dateArray.count)) {
        return 0;
    }
    
    return 34;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (_dateArray.count == 0) {
        return [[UIView alloc] initWithFrame:CGRectZero];
    } else if (self.canPaginate && (section == _dateArray.count)) {
        return [[UIView alloc] initWithFrame:CGRectZero];
    }
    
    NSString *date = [_dateArray objectAtIndex:section];

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,34)];
    headerView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    headerView.layer.borderColor = [UIColor whiteColor].CGColor;
    headerView.layer.borderWidth = 3.0;
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,0,300,34)];
    dateLabel.text = date;
    dateLabel.font = [UIFont fontWithName:@"Thonburi" size:17.0];
    
    dateLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    [headerView addSubview:dateLabel];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isLoading && _dateArray.count == 0) {
        BIPaginationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BIPaginationTableViewCell reuseIdentifier]];
        [cell.aiv startAnimating];
        return cell;
    } else if (_dateArray.count == 0) {
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        BINoFollowResultsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BINoFollowResultsTableViewCell reuseIdentifier]];
        return cell;
    } else if (self.canPaginate && (indexPath.section == _dateArray.count)) {
        BIPaginationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BIPaginationTableViewCell reuseIdentifier]];
        [cell.aiv startAnimating];
        return cell;
    }
    
    NSArray *blinksOnDate = [_blinksArray objectAtIndex:indexPath.section];
    PFObject *blink = [blinksOnDate objectAtIndex:indexPath.row];
    
    BIFeedTableViewCell *cell;
    if (blink[@"imageFile"]) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:[BIFeedPhotoTableViewCell reuseIdentifier]];
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:[BIFeedTableViewCell reuseIdentifier]];
    }
    
    cell.blink = blink;
    
    return cell;
}

#pragma mark - button actions

- (void)tappedFriends:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard mainStoryboard];
    UINavigationController *nav = [mainStoryboard instantiateViewControllerWithIdentifier:@"BIFollowNavigationController"];
    
    _isPresentingOtherVC = YES;
    
    [self presentViewController:nav animated:YES completion:nil];
    
    [BIMixpanelHelper sendMixpanelEvent:@"FOLLOW_tappedFriendsButton" withProperties:nil];
}


@end
