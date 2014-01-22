//
//  BIPaginationTableViewCell.h
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/21/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BIPaginationTableViewCell : UITableViewCell

+ (NSString*)reuseIdentifier;
+ (CGFloat)cellHeight;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *aiv;

@end
