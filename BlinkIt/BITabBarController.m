//
//  BITabBarController.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 2/11/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BITabBarController.h"

#define kTABBAR_ME 0
#define kTABBAR_FEED 1

@interface BITabBarController ()

@end

@implementation BITabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tabBar.barTintColor = [UIColor colorWithWhite:0.95 alpha:1];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item  {
    NSInteger selectedIndex = self.selectedIndex;
    if (selectedIndex == kTABBAR_ME) {
        [BIMixpanelHelper sendMixpanelEvent:@"TABBAR_tappedTab" withProperties:@{@"tappedOn":@"feed"}];
    } else if (selectedIndex == kTABBAR_FEED) {
        [BIMixpanelHelper sendMixpanelEvent:@"TABBAR_tappedTab" withProperties:@{@"tappedOn":@"me"}];
    }
}

@end
