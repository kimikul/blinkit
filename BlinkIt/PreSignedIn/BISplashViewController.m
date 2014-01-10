//
//  BISplashViewController.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/8/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BISplashViewController.h"
#import <Parse/Parse.h>

@interface BISplashViewController ()
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@end

@implementation BISplashViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _loginButton.layer.cornerRadius = 3.0;
    _loginButton.clipsToBounds = YES;
    
    _signupButton.layer.cornerRadius = 3.0;
    _signupButton.clipsToBounds = YES;
    
    PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
    [testObject setObject:@"bar" forKey:@"foo"];
    [testObject save];
}

@end
