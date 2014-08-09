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
@property (weak, nonatomic) IBOutlet UILabel *noBlinksLabel;

@end

@implementation BIProfileViewController

//#pragma mark - init
//
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.useRefreshTableHeaderView = YES;
    }
    
    return self;
}

#pragma mark - lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupHeader];
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
    
    NSString *photoURL = _user[@"photoURL"];
    UIImage *profPic = [[BIFileSystemImageCache shared] objectForKey:photoURL];
    if (profPic) {
        _profilePicImageView.image = profPic;
    } else if (photoURL.hasContent){
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        
        dispatch_async(queue, ^{
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photoURL]]];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                _profilePicImageView.image = image;
                [_profilePicImageView fadeInWithDuration:0.2 completion:nil];
                [[BIFileSystemImageCache shared] setObject:image forKey:photoURL];
            });
        });
    }
}

- (void)setupButtons {
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneTapped:)];
    self.navigationItem.rightBarButtonItem = doneButton;
}

#pragma mark - requests

- (BOOL)hasAccessToUser {
    PFUser *currentUser = [PFUser currentUser];
    BOOL hasAccess = [[BIDataStore shared] isFollowingUser:_user] || [currentUser.objectId isEqualToString:_user.objectId];
    
    self.noBlinksLabel.text = hasAccess ? @"This user has no public posts" : @"You can only view blinks of friends you are following";
    self.noBlinksView.hidden = hasAccess;

    return hasAccess;
}

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
    if (![self hasAccessToUser]) {
        
        return;
    }
    
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[BIHomeTableViewCell class]]) {
        BIHomeTableViewCell *homeCell = (BIHomeTableViewCell*)cell;
        homeCell.privacyButton.hidden = YES;
        return homeCell;
    }
    
    return cell;
}

#pragma mark -ibactions

- (void)doneTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
