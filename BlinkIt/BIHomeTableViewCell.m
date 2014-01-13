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

+ (UIFont*)fontForContent {
    return [UIFont systemFontOfSize:14];
}

+ (CGFloat)heightForContent:(NSString*)content {
    CGFloat staticHeight = 46;
    UIFont *font = [BIHomeTableViewCell fontForContent];
    CGSize maxSize = CGSizeMake(300,1000);
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                font, NSFontAttributeName,
                                nil];
    
    CGRect rect = [content boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    
    return rect.size.height + staticHeight;
}

- (void)setBlink:(PFObject *)blink {
    _blink = blink;
    
    _contentLabel.text = blink[@"content"];
    _dateLabel.text = [self formattedDateLabel];
}

- (NSString*)formattedDateLabel {
    NSDate *date = _blink[@"date"];
    return [NSDate spelledOutDate:date];
}

@end
