//
//  BIFollowerTableViewCell.h
//  BlinkIt
//
//  Created by Kimberly Hsiao on 3/10/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BIFollowerTableViewCell : UITableViewCell

+ (NSString*)reuseIdentifier;
+ (CGFloat)cellHeight;
@property (nonatomic, strong) PFObject *activity;

@end
