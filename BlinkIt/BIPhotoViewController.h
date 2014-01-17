//
//  BIPhotoViewController.h
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/16/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIViewController.h"

@class BIPhotoViewController;

@protocol BIPhotoViewControllerDelegate <NSObject>

- (void)photoViewController:(BIPhotoViewController*)photoViewController didRemovePhotoFromBlink:(PFObject*)blink;

@end

@interface BIPhotoViewController : BIViewController

@property (nonatomic, weak) id <BIPhotoViewControllerDelegate> delegate;
@property (nonatomic, strong) UIImage *attachedImage;
@property (nonatomic, strong) PFObject *blink;

@end
