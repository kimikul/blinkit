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
// nothing yet
@end

@interface BIFollowingTableViewCell : UITableViewCell

+ (NSString*)reuseIdentifier;
+ (CGFloat)cellHeight;
- (void)setButtonToSelected;
- (void)setButtonToUnselected;

@property (nonatomic, strong) PFUser *user;
@property (weak, nonatomic) IBOutlet UIButton *followButton;

@end
