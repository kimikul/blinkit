//
//  BIFollowingTableViewCell.h
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/31/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BIFollowingTableViewCell;

@protocol BIFollowingTableViewCellDelegate <NSObject>

- (void)followingCell:(BIFollowingTableViewCell*)followingCell tappedFollowButton:(UIButton*)button;

@end

@interface BIFollowingTableViewCell : UITableViewCell

+ (NSString*)reuseIdentifier;
+ (CGFloat)cellHeight;

@property (nonatomic, weak) id <BIFollowingTableViewCellDelegate> delegate;
@property (nonatomic, strong) PFUser *user;
@property (weak, nonatomic) IBOutlet UIButton *followButton;

@end
