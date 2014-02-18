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
#define kTABBAR_FEED 1

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
    UIImage *buttonImage = [UIImage imageNamed:@"Notification-icon"];
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(presentTodaysBlinkVC:) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat heightDifference = buttonImage.size.height - self.tabBar.frame.size.height;
    if (heightDifference < 0)
        button.center = self.tabBar.center;
    else {
        CGPoint center = self.tabBar.center;
        center.y = center.y - heightDifference/2.0;
        button.center = center;
    }
    
    [self.view addSubview:button];
}

#pragma mark - tabbardelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item  {
    NSInteger selectedIndex = self.selectedIndex;
    if (selectedIndex == kTABBAR_ME) {
        [BIMixpanelHelper sendMixpanelEvent:@"TABBAR_tappedTab" withProperties:@{@"tappedOn":@"feed"}];
    } else if (selectedIndex == kTABBAR_FEED) {
        [BIMixpanelHelper sendMixpanelEvent:@"TABBAR_tappedTab" withProperties:@{@"tappedOn":@"me"}];
    }
}

#pragma mark - ibaction

- (void)presentTodaysBlinkVC:(UIButton*)sender {
    UINavigationController *nav = [self.viewControllers objectAtIndex:0];
    BIHomeViewController *homeVC = (BIHomeViewController*)nav.topViewController;
    [homeVC presentTodaysBlinkVC];
}

@end
