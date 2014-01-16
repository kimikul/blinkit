//
//  BIViewController.h
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/15/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BIViewController : UIViewController

@property (nonatomic, strong) MBProgressHUD *progressHUD;

- (void)configureProgressHUD;
- (void)showProgressHUD;
- (void)hideProgressHUD;
- (void)showProgressHUDForDuration:(NSTimeInterval)duration;

@end
