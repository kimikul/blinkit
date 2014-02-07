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
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (nonatomic, strong) PFUser *user;
@end

@implementation BIFeedTableViewCell

+ (NSString*)reuseIdentifier {
    return @"BIFeedTableViewCell";
}

+ (UIFont*)fontForContent {
    return [UIFont systemFontOfSize:14];
}

+ (CGFloat)heightForContent:(NSString*)content {
    CGFloat staticHeight = 50;
    UIFont *font = [BIFeedTableViewCell fontForContent];
    CGSize maxSize = CGSizeMake(300,1000);
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                font, NSFontAttributeName,
                                nil];
    
    CGRect rect = [content boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    
    return rect.size.height + staticHeight;
}

- (void)setBlink:(PFObject *)blink {
    _blink = blink;
    
    _user = blink[@"user"];
    _contentLabel.text = blink[@"content"];
    _userNameLabel.text = _user[@"name"];
    
    _userPicImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_user[@"photoURL"]]]];
}

@end
