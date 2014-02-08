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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateButtonForUser:) name:@"BITappedFollowButtonNotification" object:_user];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - getter/setter

- (void)setUser:(PFUser *)user {
    _user = user;
    _nameLabel.text = user[@"name"];
    _profilePic.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:user[@"photoURL"]]]];
    if ([[BIDataStore shared] isFollowingUser:user]) {
        [self setButtonToSelected];
    } else {
        [self setButtonToUnselected];
    }
}

#pragma mark - actions

- (IBAction)tappedFollowButton:(id)sender {
    PFUser *user = _user;

    // update database with new follow state
    if (_followButton.isSelected) {
        [BIFollowManager unfollowUserEventually:user block:^(NSError *error) {
            if (!error) {
                [[BIDataStore shared] removeFollowedFriend:user];
            }
        }];
    } else {
        [BIFollowManager followUserEventually:user block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [[BIDataStore shared] addFollowedFriend:user];
            }
        }];
    }
    
    // notify all affected cells to update UI
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BITappedFollowButtonNotification" object:_user];
}

- (void)updateButtonForUser:(NSNotification*)note {
    PFUser *user = _user;
    PFUser *tappedUser = note.object;
    NSString *userID = [user objectId];
    NSString *tappedUserID = [tappedUser objectId];

    if ([tappedUserID isEqual:userID]) {
        if (_followButton.isSelected) {
            [self setButtonToUnselected];
        } else {
            [self setButtonToSelected];
        }
    }
}

#pragma mark - follow button state change

- (void)setButtonToSelected {
    _followButton.selected = YES;
    _followButton.backgroundColor = [UIColor lightGrayColor];
    [_followButton setTitle:@"Following" forState:UIControlStateNormal];
}

- (void)setButtonToUnselected {
    _followButton.selected = NO;
    _followButton.backgroundColor = [UIColor blueColor];
    [_followButton setTitle:@"Follow" forState:UIControlStateNormal];
}

@end
