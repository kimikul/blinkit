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
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
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
    CGFloat staticHeight = 60;
    UIFont *font = [BIFeedTableViewCell fontForContent];
    CGSize maxSize = CGSizeMake(300,1000);
    
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
    _contentLabel.text = blink[@"content"];
    _userNameLabel.text = _user[@"name"];
    _timeLabel.text = [NSDate formattedTime:blink[@"date"]];
    
    if ([[BIDataStore shared] isCachedProfilePicForUser:_user]) {
        _userPicImageView.image = [[BIDataStore shared] profilePicForUser:_user];
    } else {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        
        dispatch_async(queue, ^{
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_user[@"photoURL"]]]];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                _userPicImageView.image = image;
                [_userPicImageView fadeInWithDuration:0.2 completion:nil];
                [[BIDataStore shared] addProfilePic:image ForUser:_user];
            });
        });
    }
}

#pragma mark - ibactions

- (void)didTapProfile:(id)sender {
    [self.delegate feedCell:self didTapUserProfile:_user];
}

@end
