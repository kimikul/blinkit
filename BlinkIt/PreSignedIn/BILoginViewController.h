//
//  BILoginViewController.h
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/8/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BILoginViewController;

@protocol BILoginViewControllerDelegate <NSObject>
- (void)loginViewController:(BILoginViewController*)loginVC didLoginUser:(PFUser*)user;
@end

@interface BILoginViewController : UIViewController

@property (nonatomic, weak) id <BILoginViewControllerDelegate> delegate;

@end
