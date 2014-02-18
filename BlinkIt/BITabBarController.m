//
//  BITabBarController.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 2/11/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BITabBarController.h"
#import "BIComposeBlinkViewController.h"

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
    [button addTarget:self action:@selector(composeBlink:) forControlEvents:UIControlEventTouchUpInside];
    
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

- (void)composeBlink:(UIButton*)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard mainStoryboard];
    UINavigationController *nav = [mainStoryboard instantiateViewControllerWithIdentifier:@"BIComposeBlinkNavigationController"];
    [self presentViewController:nav animated:YES completion:nil];
    
    [BIMixpanelHelper sendMixpanelEvent:@"TODAY_composeBlink" withProperties:nil];
}

@end
