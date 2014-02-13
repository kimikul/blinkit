//
//  BIFollowingTableViewCell.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/31/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIFollowingTableViewCell.h"

@interface BIFollowingTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profilePic;
@property (nonatomic, assign) BIFollowingState followingState;
@end

@implementation BIFollowingTableViewCell

#pragma mark - class methods

+ (NSString*)reuseIdentifier {
    return @"BIFollowingTableViewCell";
}

+ (CGFloat)cellHeight {
    return 45;
}

#pragma mark - lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _followButton.layer.cornerRadius = 3.0;
    _followButton.clipsToBounds = YES;

    _profilePic.layer.cornerRadius = 2.0;
    _profilePic.clipsToBounds = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateButtonForUser:) name:kBITappedFollowButtonNotification object:_user];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - getter/setter

- (void)setUser:(PFUser *)user {
    _user = user;
    _nameLabel.text = user[@"name"];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    
    dispatch_async(queue, ^{
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:user[@"photoURL"]]]];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            _profilePic.image = image;
        });
    });
    
    if ([[BIDataStore shared] isFollowingUser:user]) {
        [self setButtonToShowFollowing];
    } else if ([[BIDataStore shared] hasRequestedUser:user]) {
        [self setButtonToShowRequested];
    } else {
        [self setButtonToShowNoFollowStatus];
    }
}

#pragma mark - actions

- (IBAction)tappedFollowButton:(id)sender {
    _followButton.backgroundColor = [UIColor greenColor];
    
    PFUser *user = _user;

    // update database with new follow state
    
    if (_followingState == BIFollowingStateFollowing) {
        [BIFollowManager unfollowUserEventually:user block:^(NSError *error) {
            if (!error) {
                [[BIDataStore shared] removeFollowedFriend:user];
            }
        }];
        
        [BIMixpanelHelper sendMixpanelEvent:@"FOLLOW_unfollowUser" withProperties:nil];
    } else if (_followingState == BIFollowingStateRequested) {
        [BIFollowManager cancelRequestToFollowUserEventually:user block:^(NSError *error) {
            if (!error) {
                [[BIDataStore shared] removeRequestedFriend:user];
            }
        }];
        
        [BIMixpanelHelper sendMixpanelEvent:@"FOLLOW_unrequestFollowRequest" withProperties:nil];
    } else if (_followingState == BIFollowingStateNone) {
        [BIFollowManager requestToFollowUserEventually:user block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [[BIDataStore shared] addRequestedFriend:user];
                [BINotificationHelper sendPushNotificationToUser:user];
            }
        }];
        
        [BIMixpanelHelper sendMixpanelEvent:@"FOLLOW_requestToFollowUser" withProperties:nil];
    }
    
    // notify all affected cells to update UI
    [[NSNotificationCenter defaultCenter] postNotificationName:kBITappedFollowButtonNotification object:_user];
}

- (void)updateButtonForUser:(NSNotification*)note {
    PFUser *user = _user;
    PFUser *tappedUser = note.object;
    NSString *userID = [user objectId];
    NSString *tappedUserID = [tappedUser objectId];

    if ([tappedUserID isEqual:userID]) {
        [self updateFollowButtonState];
    }
}

#pragma mark - follow button state change

- (void)updateFollowButtonState {
    
    BIFollowingState currentFollowingStatus = _followingState;
    
    if (currentFollowingStatus == BIFollowingStateNone) {
        [self setButtonToShowRequested];
    } else if (currentFollowingStatus == BIFollowingStateRequested) {
        [self setButtonToShowNoFollowStatus];
    } else if (currentFollowingStatus == BIFollowingStateFollowing) {
        [self setButtonToShowNoFollowStatus];
    }
}

- (void)setButtonToShowFollowing {
    _followingState = BIFollowingStateFollowing;
    _followButton.backgroundColor = [UIColor lightGrayColor];
    [_followButton setTitle:@"Following" forState:UIControlStateNormal];
}

- (void)setButtonToShowRequested {
    _followingState = BIFollowingStateRequested;
    _followButton.backgroundColor = [UIColor orangeColor];
    [_followButton setTitle:@"Requested" forState:UIControlStateNormal];
}

- (void)setButtonToShowNoFollowStatus {
    _followingState = BIFollowingStateNone;
    _followButton.backgroundColor = [UIColor blueColor];
    [_followButton setTitle:@"Follow" forState:UIControlStateNormal];
}

@end
