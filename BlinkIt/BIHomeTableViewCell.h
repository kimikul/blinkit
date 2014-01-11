//
//  BIHomeTableViewCell.h
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/10/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BIHomeTableViewCell : UITableViewCell

+ (NSString*)reuseIdentifier;
+ (CGFloat)heightForContent:(NSString*)content;

@property (nonatomic, strong) PFObject *blink;

@end
