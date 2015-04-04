//
//  BIFeedTableViewCell.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 2/6/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIFeedTableViewCell.h"

@interface BIFeedTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *userPicImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) PFUser *user;
@property (weak, nonatomic) IBOutlet UIView *viewProfileTapView;
@end

@implementation BIFeedTableViewCell

#pragma mark - class methods

+ (NSString*)reuseIdentifier {
    return @"BIFeedTableViewCell";
}

+ (UIFont*)fontForContent {
    return [UIFont systemFontOfSize:14];
}

+ (CGFloat)heightForContent:(NSString*)content {
    CGFloat staticHeight = 58;
    
    UIFont *font = [BIFeedTableViewCell fontForContent];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGSize maxSize = CGSizeMake(screenWidth-20,1000);
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                font, NSFontAttributeName,
                                nil];
    
    CGRect rect = [content boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    
    return rect.size.height + staticHeight;
}

#pragma mark - lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _userPicImageView.layer.cornerRadius = 2.0;
    _userPicImageView.clipsToBounds = YES;
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapProfile:)];
    [_viewProfileTapView addGestureRecognizer:tapGR];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _userPicImageView.image = nil;
}

#pragma mark - setter/getter

- (void)setBlink:(PFObject *)blink {
    _blink = blink;
    
    _user = blink[@"user"];
    _userNameLabel.text = _user[@"name"];
    _timeLabel.text = [NSDate formattedTime:blink[@"date"]];
    _contentTextView.text = nil;    // workaround for repeating links
    [self highlightHashtags];
    
    NSString *photoURL = _user[@"photoURL"];
    UIImage *profPic = [[BIFileSystemImageCache shared] objectForKey:photoURL];
    if (profPic) {
        _userPicImageView.image = profPic;
    } else if (photoURL.hasContent){
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        
        dispatch_async(queue, ^{
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_user[@"photoURL"]]]];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                _userPicImageView.image = image;
                [_userPicImageView fadeInWithDuration:0.2 completion:nil];
                [[BIFileSystemImageCache shared] setObject:image forKey:photoURL];
            });
        });
    }
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

#pragma mark - ibactions

- (void)didTapProfile:(id)sender {
    [self.delegate feedCell:self didTapUserProfile:_user];
}

@end
