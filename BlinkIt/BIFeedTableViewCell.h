//
//  BIFeedTableViewCell.h
//  BlinkIt
//
//  Created by Kimberly Hsiao on 2/6/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BIFeedTableViewCell : UITableViewCell

+ (NSString*)reuseIdentifier;
+ (CGFloat)heightForContent:(NSString*)content;

@property (nonatomic, strong) PFObject *blink;

@end
