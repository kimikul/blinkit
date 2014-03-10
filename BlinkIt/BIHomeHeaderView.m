//
//  BIHomeHeaderView.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 2/26/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIHomeHeaderView.h"

@interface BIHomeHeaderView ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicImageView;
@property (weak, nonatomic) IBOutlet UILabel *followersCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *blinksCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *followersButton;
@property (weak, nonatomic) IBOutlet UIButton *followingButton;
@property (weak, nonatomic) IBOutlet UIButton *blinksButton;
@end

@implementation BIHomeHeaderView

- (void)awakeFromNib {
    [super awakeFromNib];
 
    _profilePicImageView.layer.cornerRadius = 3.0;
    _profilePicImageView.clipsToBounds = YES;
    
    _followersButton.layer.cornerRadius = 2.0;
    _followingButton.layer.cornerRadius = 2.0;
    _blinksButton.layer.cornerRadius = 2.0;
    
}

- (void)setUser:(PFUser *)user {
    _user = user;
    
    _nameLabel.text = user[@"name"];

    NSString *photoURL = user[@"photoURL"];
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
    
    [self fetchBlinksCount];
    [self fetchFollowersCount];
}

#pragma mark - requests

- (void)refreshNumbers {
    [self fetchBlinksCount];
    [self fetchFollowersCount];
}

- (void)fetchBlinksCount {
    PFQuery *query = [PFQuery queryWithClassName:@"Blink"];
    [query whereKey:@"user" equalTo:_user];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        
        NSInteger numDaysSinceJoined = [NSDate numDaysSinceDate:_user.createdAt];
        
        NSString *label = [NSString stringWithFormat:@"%d / %d",number, numDaysSinceJoined];
        
        _blinksCountLabel.text = label;
        [_blinksCountLabel fadeTransitionWithDuration:0.2];
    }];
}

- (void)fetchFollowersCount {
    PFQuery *followersQuery = [PFQuery queryWithClassName:@"Activity"];
    [followersQuery whereKey:@"toUser" equalTo:[PFUser currentUser]];
    [followersQuery whereKey:@"type" equalTo:@"follow"];
    [followersQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        NSString *followersCount = [NSString stringWithFormat:@"%d",number];
        
        _followersCountLabel.text = followersCount;
        [_followersCountLabel fadeTransitionWithDuration:0.2];
        [self fetchFollowingCount];
    }];
}

- (void)fetchFollowingCount {
    NSInteger followingCount = [[[BIDataStore shared] followedFriends] count];
    _followingCountLabel.text = [NSString stringWithFormat:@"%d",followingCount];
    [_followingCountLabel fadeTransitionWithDuration:0.2];
}

#pragma mark - helpers

- (void)updateBlinkCountWithIncrement:(BOOL)shouldIncrement {
    NSString *currentLabel = _blinksCountLabel.text;
    NSArray *components = [currentLabel componentsSeparatedByString:@" / "];
    NSInteger numBlinks = [[components safeObjectAtIndex:0] integerValue];
    NSInteger numDays = [[components safeObjectAtIndex:1] integerValue];
    
    if (shouldIncrement) {
        numBlinks += 1;
    } else {
        numBlinks -= 1;
        numBlinks = MAX(0,numBlinks);
    }
    
    _blinksCountLabel.text = [NSString stringWithFormat:@"%d / %d",numBlinks, numDays];
}

#pragma mark - ibactions

- (IBAction)tapFollowing:(id)sender {
    [self.delegate headerView:self didTapFollowingButton:sender];
}

- (IBAction)tapFollowers:(id)sender {
    [self.delegate headerView:self didTapFollowersButton:sender];
}

@end
