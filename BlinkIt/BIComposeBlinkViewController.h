//
//  BIComposeBlinkViewController.h
//  BlinkIt
//
//  Created by Kimberly Hsiao on 2/17/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIViewController.h"
#import "BIPlaceholderTextView.h"

@interface BIComposeBlinkViewController : BIViewController

@property (nonatomic, strong) PFObject *blink;
@property (weak, nonatomic) IBOutlet UIButton *privateButton;
@property (nonatomic, strong) UIImage *selectedImage; // keeps track of if there is an image in editing mode. not saved mode
@property (weak, nonatomic) IBOutlet BIPlaceholderTextView *contentTextView;

@end
