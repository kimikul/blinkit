//
//  BIFeedPhotoTableViewCell.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 2/7/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIFeedPhotoTableViewCell.h"

@interface BIFeedPhotoTableViewCell ()
@property (weak, nonatomic) IBOutlet PFImageView *attachedImageView;
@end


@implementation BIFeedPhotoTableViewCell

+ (NSString*)reuseIdentifier {
    return @"BIFeedPhotoTableViewCell";
}

+ (CGFloat)heightForContent:(NSString*)content {
    CGFloat baseHeight = [super heightForContent:content];
    CGFloat photoHeight = 315;
    
    return baseHeight + photoHeight;
}

#pragma mark - lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UITapGestureRecognizer *tapImageGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapImage:)];
    [self addGestureRecognizer:tapImageGR];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _attachedImageView.image = nil;
}

#pragma mark - getter/setter

- (void)setBlink:(PFObject *)blink {
    [super setBlink:blink];
    
    PFFile *imageFile = blink[@"imageFile"];
    if (imageFile) {
        self.attachedImageView.file = imageFile;
        [self.attachedImageView loadInBackground:^(UIImage *image, NSError *error) {
            NSLog(@"downloaded image");
        }];
    }
}

#pragma mark - ibactions

- (void)didTapImage:(id)sender {
    [self.delegate feedCell:self didTapImageView:_attachedImageView];
}

@end
