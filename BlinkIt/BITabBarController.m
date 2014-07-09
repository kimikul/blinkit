//
//  BITabBarController.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 2/11/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BITabBarController.h"
#import "BIHomeViewController.h"

#define kTABBAR_FEED 0
#define kTABBAR_FLASHBACK 1
#define kTABBAR_TODAYSBLINK 2
#define kTABBAR_NOTIFICATIONS 3
#define kTABBAR_ME 4

@interface BITabBarController ()
@end

@implementation BITabBarController

#pragma mark - lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tabBar.barTintColor = [UIColor colorWithWhite:0.95 alpha:1];
    
    [self setupCustomButton];
}

- (void)setupCustomButton {
    UIImage *buttonImage = [UIImage imageNamed:@"blink"];
    UIImage *highlightImage = [buttonImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0, 0.0,64,49);
    button.tintColor = [UIColor coral];
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 12, 16, 12);
    
    [button setImage:highlightImage forState:UIControlStateHighlighted];
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(presentTodaysBlinkVC:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(highlightButton:) forControlEvents:UIControlEventTouchDown];

    [button addTarget:self action:@selector(unhighlightButton:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(unhighlightButton:) forControlEvents:UIControlEventTouchDragOutside];


    button.center = self.tabBar.center;
    
    [self.view addSubview:button];
}

#pragma mark - ibaction

- (void)presentTodaysBlinkVC:(UIButton*)sender {
    UINavigationController *nav = [self.viewControllers objectAtIndex:kTABBAR_ME];
    BIHomeViewController *homeVC = (BIHomeViewController*)nav.topViewController;
    [homeVC presentTodaysBlinkVC];
}

- (void)highlightButton:(UIButton*)todaysBlinkButton {
    todaysBlinkButton.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
}

- (void)unhighlightButton:(UIButton*)todaysBlinkButton {
    todaysBlinkButton.backgroundColor = [UIColor clearColor];
}

@end
