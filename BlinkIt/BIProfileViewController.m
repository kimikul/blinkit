//
//  BIProfileViewController.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 2/18/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIProfileViewController.h"
#import "BIHomePhotoTableViewCell.h"
#import "BINoFollowResultsTableViewCell.h"
#import "BIPaginationTableViewCell.h"

#define kNumBlinksPerPage 15

@interface BIProfileViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numBlinksLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateJoinedLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicImageView;
@property (nonatomic, strong) NSMutableArray *allBlinksArray;
@property (nonatomic, assign) BOOL canPaginate;
@end

@implementation BIProfileViewController

#pragma mark - init

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.useEmptyTableFooter = YES;
        self.useRefreshTableHeaderView = YES;
    }
    
    return self;
}

#pragma mark - setter/getter

- (NSMutableArray*)allBlinksArray {
    if (!_allBlinksArray) {
        _allBlinksArray = [NSMutableArray new];
    }
    
    return _allBlinksArray;
}

#pragma mark - lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupHeader];
    [self setupTableView];
    [self setupButtons];
    [self fetchCount];
    [self fetchUsersBlinksForPagination:NO];
}

- (void)setupHeader {
    self.title = _user[@"name"];
    _nameLabel.text = _user[@"name"];
    _dateJoinedLabel.text = [NSString stringWithFormat:@"Joined %@",[NSDate spelledOutDateNoDay:_user.createdAt]];
    
    _profilePicImageView.layer.cornerRadius = 3.0;
    _profilePicImageView.clipsToBounds = YES;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    
    dispatch_async(queue, ^{
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_user[@"photoURL"]]]];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            _profilePicImageView.image = image;
        });
    });
}

- (void)setupTableView {
    [self.tableView registerNib:[UINib nibWithNibName:[BIHomePhotoTableViewCell reuseIdentifier] bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[BIHomePhotoTableViewCell reuseIdentifier]];
    [self.tableView registerNib:[UINib nibWithNibName:[BIHomeTableViewCell reuseIdentifier] bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[BIHomeTableViewCell reuseIdentifier]];
}

- (void)setupButtons {
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneTapped:)];
    self.navigationItem.rightBarButtonItem = doneButton;
}

#pragma mark - requests

- (void)fetchCount {
    PFQuery *query = [PFQuery queryWithClassName:@"Blink"];
    [query whereKey:@"user" equalTo:_user];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        
        NSString *modifier = (number == 1) ? @"" : @"s";
        NSString *numBlinksString = [NSString stringWithFormat:@"%d blink%@",number,modifier];
        
        NSInteger numDaysSinceJoined = [NSDate numDaysSinceDate:_user.createdAt];
        NSString *daysModifier = (numDaysSinceJoined == 1) ? @"" : @"s";
        
        NSString *numDaysString = [NSString stringWithFormat:@"%d day%@",numDaysSinceJoined,daysModifier];
        
        NSString *label = [NSString stringWithFormat:@"%@ / %@",numBlinksString, numDaysString];
        
        _numBlinksLabel.text = label;
        [_numBlinksLabel fadeTransitionWithDuration:0.2];
    }];
}

- (void)fetchUsersBlinksForPagination:(BOOL)pagination {
    self.loading = YES;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Blink"];
    query.limit = kNumBlinksPerPage;
    query.skip = pagination ? self.allBlinksArray.count : 0;
    [query orderByDescending:@"date"];
    [query whereKey:@"private" equalTo:@NO];
    [query whereKey:@"user" equalTo:_user];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.loading = NO;
        
        if (!error) {
            self.canPaginate = objects.count > 0 && (objects.count % kNumBlinksPerPage == 0);
            
            NSMutableArray *blinks = pagination ? [[self.allBlinksArray arrayByAddingObjectsFromArray:objects] mutableCopy] : [objects mutableCopy];
            self.allBlinksArray = [blinks mutableCopy];
            [self reloadTableData];
        }
    }];

}

#pragma mark - refresh and pagination

- (void)refreshTableHeaderDidTriggerRefresh {
    [self fetchUsersBlinksForPagination:NO];
}

- (void)performPaginationRequestIfNecessary {
    if([self hasReachedTableEnd:self.tableView] && self.canPaginate) {
        [self fetchUsersBlinksForPagination:YES];
    }
}

#pragma mark - UITableViewDelegate / UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // no results row
    if (self.allBlinksArray.count == 0 && !self.isLoading) {
        return 1;
    }
    
    return self.allBlinksArray.count + self.canPaginate;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // no results row
    if (self.allBlinksArray.count == 0 && !self.isLoading) {
        return [BINoFollowResultsTableViewCell cellHeight];
    }
    
    // pagination row
    if (indexPath.row == self.allBlinksArray.count) {
        return [BIPaginationTableViewCell cellHeight];
    }
    
    // regular row
    CGFloat height = 0;
    PFObject *blink = [self.allBlinksArray objectAtIndex:indexPath.row];
    NSString *content = blink[@"content"];
    PFFile *imageFile = blink[@"imageFile"];
    
    if (imageFile) {
        height = [BIHomePhotoTableViewCell heightForContent:content];
    } else {
        height = [BIHomeTableViewCell heightForContent:content];
    }
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;

    // no results row
    if (self.allBlinksArray.count == 0 && !self.isLoading) {
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        BINoFollowResultsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BINoFollowResultsTableViewCell reuseIdentifier]];
        return cell;
    }
    
    // pagination row
    if (indexPath.row == self.allBlinksArray.count) {
        BIPaginationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BIPaginationTableViewCell reuseIdentifier]];
        [cell.aiv startAnimating];
        return cell;
    }
    
    // regular row
    PFObject *blink = [self.allBlinksArray objectAtIndex:indexPath.row];
    BIHomeTableViewCell *cell;
    
    if (blink[@"imageFile"]) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:[BIHomePhotoTableViewCell reuseIdentifier]];
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:[BIHomeTableViewCell reuseIdentifier]];
    }
    
    cell.blink = blink;
    cell.privacyButton.hidden = YES;
    
    return cell;
}

#pragma mark -ibactions

- (void)doneTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
