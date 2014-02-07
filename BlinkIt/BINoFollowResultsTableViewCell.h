//
//  BINoFollowResultsTableViewCell.h
//  BlinkIt
//
//  Created by Kimberly Hsiao on 2/6/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BINoFollowResultsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *noResultsLabel;

+ (CGFloat)cellHeight;
+ (NSString*)reuseIdentifier;

@end
