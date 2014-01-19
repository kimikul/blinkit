//
//  BIHomePhotoTableViewCell.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/17/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIHomePhotoTableViewCell.h"

@interface BIHomePhotoTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *attachedImageView;
@end


@implementation BIHomePhotoTableViewCell

+ (NSString*)reuseIdentifier {
    return @"BIHomePhotoTableViewCell";
}

+ (CGFloat)heightForContent:(NSString*)content {
    CGFloat baseHeight = [super heightForContent:content];
    CGFloat photoHeight = 315;
    
    return baseHeight + photoHeight;
}

- (void)setBlink:(PFObject *)blink {
    [super setBlink:blink];
    
    PFFile *imageFile = blink[@"imageFile"];
    if (imageFile) {
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            UIImage *image = [UIImage imageWithData:data];
            _attachedImageView.image = image;
        }];
    }
}

@end
