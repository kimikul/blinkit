//
//  BITabBarController.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 2/11/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BITabBarController.h"
#import "BIHomeViewController.h"

#define kTABBAR_ME 0
#define kTABBAR_TODAYSBLINK 1
#define kTABBAR_FEED 2

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
    button.frame = CGRectMake(0.0, 0.0,100,49);
    button.tintColor = [UIColor coral];
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 32, 16, 32);
    
    [button setImage:highlightImage forState:UIControlStateHighlighted];
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(presentTodaysBlinkVC:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(highlightButton:) forControlEvents:UIControlEventTouchDown];

    [button addTarget:self action:@selector(unhighlightButton:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(unhighlightButton:) forControlEvents:UIControlEventTouchDragOutside];


    button.center = self.tabBar.center;
    
    [self.view addSubview:button];
}

#pragma mark - tabbardelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item  {
    NSInteger selectedIndex = self.selectedIndex;
    if (selectedIndex == kTABBAR_ME) {
        [BIMixpanelHelper sendMixpanelEvent:@"TABBAR_tappedTab" withProperties:@{@"tappedOn":@"me"}];
    } else if (selectedIndex == kTABBAR_FEED) {
        [BIMixpanelHelper sendMixpanelEvent:@"TABBAR_tappedTab" withProperties:@{@"tappedOn":@"feed"}];
    }
}

#pragma mark - ibaction

- (void)presentTodaysBlinkVC:(UIButton*)sender {
    UINavigationController *nav = [self.viewControllers objectAtIndex:0];
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
