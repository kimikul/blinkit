//
//  BIHomePhotoTableViewCell.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/17/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIHomePhotoTableViewCell.h"

@interface BIHomePhotoTableViewCell ()
@property (weak, nonatomic) IBOutlet PFImageView *attachedImageView;
@property (weak, nonatomic) IBOutlet UIView *imageViewTapView;
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

#pragma mark - lifeyccle

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UITapGestureRecognizer *tapImageGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapImage:)];
    [self.imageViewTapView addGestureRecognizer:tapImageGR];
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
    [self.delegate homeCell:self didTapImageView:_attachedImageView];
}

@end
