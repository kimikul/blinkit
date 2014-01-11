//
//  BISignUpViewController.h
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/8/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BISignUpViewController;

@protocol BISignUpViewControllerDelegate <NSObject>
- (void)signUpViewController:(BISignUpViewController*)signupVC didSignUp:(PFUser*)user;
@end

@interface BISignUpViewController : UIViewController

@property (nonatomic, weak) id <BISignUpViewControllerDelegate> delegate;

@end
