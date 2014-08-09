//
//  BIFeedBaseViewController.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 8/8/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIFeedBaseViewController.h"
#import "BIPaginationTableViewCell.h"
#import "BINoFollowResultsTableViewCell.h"
#import "BIFeedPhotoTableViewCell.h"
#import "BIFeedTableViewCell.h"

@implementation BIFeedBaseViewController

#pragma mark - getter/setter

- (NSMutableArray*)allBlinksArray {
    if (!_allBlinksArray) {
        _allBlinksArray = [NSMutableArray new];
    }
    
    return _allBlinksArray;
}

- (NSMutableArray*)blinksArray {
    if (!_blinksArray) {
        _blinksArray = [NSMutableArray new];
    }
    
    return _blinksArray;
}

- (NSMutableArray*)dateArray {
    if (!_dateArray) {
        _dateArray = [NSMutableArray new];
    }
    
    return _dateArray;
}

#pragma mark - lifecycle

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.useEmptyTableFooter = YES;
        self.useRefreshTableHeaderView = NO;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTableViewDefaults];
}

- (void)setupTableViewDefaults {
    [self.tableView registerNib:[UINib nibWithNibName:[BIFeedPhotoTableViewCell reuseIdentifier] bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[BIFeedPhotoTableViewCell reuseIdentifier]];
    [self.tableView registerNib:[UINib nibWithNibName:[BIFeedTableViewCell reuseIdentifier] bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[BIFeedTableViewCell reuseIdentifier]];
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
    
    _dateArray = [dateArray mutableCopy];
    _blinksArray = blinkArray;
    
    [self reloadTableData];
}

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
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
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
    cell.delegate = self;
    
    return cell;
}

#pragma mark - BIFeedTableViewCellDelegate

- (void)feedCell:(BIFeedTableViewCell*)feedCell didTapUserProfile:(PFUser*)user {
    UIStoryboard *mainStoryboard = [UIStoryboard mainStoryboard];
    
    UINavigationController *profileNav = [mainStoryboard instantiateViewControllerWithIdentifier:@"BIProfileNavigationController"];
    BIProfileViewController *profileVC = (BIProfileViewController*)profileNav.topViewController;
    profileVC.user = user;
    [self presentViewController:profileNav animated:YES completion:nil];
}

- (void)feedCell:(BIFeedTableViewCell *)feedCell didTapImageView:(UIImageView*)imageView {
    BIExpandImageHelper *expandImageHelper = [BIExpandImageHelper new];
    expandImageHelper.delegate = self;
    [expandImageHelper animateImageView:imageView];
}

@end
