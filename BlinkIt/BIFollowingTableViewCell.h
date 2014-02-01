//
//  BIFollowingTableViewCell.h
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/31/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BIFollowingTableViewCell : UITableViewCell

+ (NSString*)reuseIdentifier;
+ (CGFloat)cellHeight;

@property (nonatomic, strong) PFUser *user;

@end
