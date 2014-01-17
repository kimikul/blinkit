//
//  BIPhotoViewController.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/16/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIPhotoViewController.h"

@interface BIPhotoViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *attachedImageView;
@end

@implementation BIPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNav];
    
    self.attachedImageView.image = self.attachedImage;
}

- (void)setupNav {
    self.title = @"Attached Photo";

    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(okTapped:)];
    self.navigationItem.rightBarButtonItem = rightButton;
}

#pragma mark - button actions

- (void)okTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
