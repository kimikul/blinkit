//
//  BIFollowingTableViewCell.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/31/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIFollowingTableViewCell.h"
#import "BIFollowManager.h"

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
    
    if (_followButton.isSelected) {
        [self setButtonToUnselected];
        [BIFollowManager unfollowUserEventually:user block:^(NSError *error) {
            if (!error) {
                [[BIDataStore shared] removeFollowedFriend:user];
            }
        }];
    } else {
        [self setButtonToSelected];
        [BIFollowManager followUserEventually:user block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [[BIDataStore shared] addFollowedFriend:user];
            }
        }];
    }
}

#pragma mark - follow button state change

- (void)setButtonToSelected {
    _followButton.selected = YES;
    _followButton.backgroundColor = [UIColor lightGrayColor];
}

- (void)setButtonToUnselected {
    _followButton.selected = NO;
    _followButton.backgroundColor = [UIColor blueColor];
}

@end
