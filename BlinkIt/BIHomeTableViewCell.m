//
//  BIHomeTableViewCell.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/10/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIHomeTableViewCell.h"

@interface BIHomeTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@end

@implementation BIHomeTableViewCell

+ (NSString*)reuseIdentifier {
    return @"BIHomeTableViewCell";
}

+ (CGFloat)heightForContent:(NSString*)content {
    return 100;
}

- (void)setBlink:(PFObject *)blink {
    _blink = blink;
}

@end
