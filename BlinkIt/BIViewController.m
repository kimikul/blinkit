//
//  BIViewController.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/15/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIViewController.h"

@interface BIViewController ()

@end

@implementation BIViewController

- (void)configureProgressHUD {
    if(!_progressHUD) {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
        self.progressHUD   = hud;
        
        [hud hide:NO];
        
        [self.view addSubview:hud];
        [self.view bringSubviewToFront:hud];
    }
}

-(BOOL)isShowingProgressHUD {
    return (_progressHUD && _progressHUD.alpha == 1.0f);
}

- (void)showProgressHUD {
    [self showProgressHUDWithBlock:nil];
}


- (void)hideProgressHUD {
    [self hideProgressHUDWithBlock:nil];
}

- (void)showProgressHUDWithBlock:(dispatch_block_t)block {
    // create progress HUD if necessary
    if(!_progressHUD) {
        [self configureProgressHUD];
    }
    
    __block MBProgressHUD *hud = [self progressHUD];
    [self performAnimationBlock:^{
        [hud show:YES];
    } withCompletionBlock:block];
}

- (void)hideProgressHUDWithBlock:(dispatch_block_t)block {
    [self performAnimationBlock:^{
        [self.progressHUD hide:YES];
    } withCompletionBlock:block];
}

- (void)performAnimationBlock:(dispatch_block_t)animationBlock
          withCompletionBlock:(dispatch_block_t)completionBlock {
    if(!animationBlock) return;
    
    if(completionBlock) {
        [CATransaction begin];
        [CATransaction setCompletionBlock:completionBlock];
    }
    
    animationBlock();
    
    if(completionBlock) {
        [CATransaction commit];
    }
}

- (void)showProgressHUDForDuration:(NSTimeInterval)duration {
    [self showProgressHUD];
    [self.progressHUD hide:YES afterDelay:duration];
}

@end
