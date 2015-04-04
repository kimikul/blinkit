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
//@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@end

@implementation BIHomeTableViewCell

+ (NSString*)reuseIdentifier {
    return @"BIHomeTableViewCell";
}

+ (UIFont*)fontForContent {
    return [UIFont systemFontOfSize:14];
}

+ (CGFloat)heightForContent:(NSString*)content {
    CGFloat staticHeight = 58;
    UIFont *font = [BIHomeTableViewCell fontForContent];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGSize maxSize = CGSizeMake(screenWidth-20,1000);
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                font, NSFontAttributeName,
                                nil];
    
    CGRect rect = [content boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    
    return rect.size.height + staticHeight;
}

#pragma mark - setter/getter

- (void)setBlink:(PFObject *)blink {
    _blink = blink;
    
    NSDate *date = _blink[@"date"];
    _timeLabel.text = [NSDate formattedTime:date];
    _dateLabel.text = [NSDate isToday:date] ? @"Today" : [NSDate spelledOutDate:date];
    _contentTextView.attributedText = nil;    // workaround for repeating links
    [self highlightHashtags];
    
    BOOL isPrivate = [_blink[@"private"] boolValue];
    [self updatePrivacyButtonTo:isPrivate];
    
}

#pragma mark - hashtags

- (void)highlightHashtags {
    NSString *text = self.blink[@"content"];
    NSArray *words = [text componentsSeparatedByString:@" "];
    
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc]initWithString:text];
    [string addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.0] range:NSMakeRange(0, text.length)];
    
    for (NSString *word in words) {
        if ([word hasPrefix:@"#"]) {
            NSRange range = [text rangeOfString:word];
            [string addAttribute:NSForegroundColorAttributeName value:[UIColor coral] range:range];
            [string addAttribute:NSLinkAttributeName value:word range:range];
        }
    }
    
    _contentTextView.attributedText = string;
}

#pragma mark - privacy button

- (void)updatePrivacyButtonTo:(BOOL)isPrivate {    
    NSString *imageString = isPrivate ? @"private" : @"Tab-friends";
    _privacyButton.imageEdgeInsets = isPrivate ? UIEdgeInsetsMake(8, 24, 12, 10) : UIEdgeInsetsMake(7, 20, 11, 8);
    
    UIImage *privacyImage = [[UIImage imageNamed:imageString] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    _privacyButton.tintColor = isPrivate ? [UIColor blueColor] : [UIColor colorWithWhite:0.8 alpha:1.0];
    _privacyButton.selected = isPrivate ? YES : NO;
    
    [_privacyButton setImage:privacyImage forState:UIControlStateNormal];
}

- (IBAction)tappedPrivacyButton:(UIButton*)sender {
    [self.delegate homeCell:self togglePrivacyTo:!_privacyButton.selected];
}

@end
