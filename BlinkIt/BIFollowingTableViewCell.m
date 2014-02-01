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
    return 40;
}

#pragma mark - getter/setter

- (void)setUser:(PFUser *)user {
    _user = user;
    _nameLabel.text = user[@"name"];
}

#pragma mark - lifecycle

@end
