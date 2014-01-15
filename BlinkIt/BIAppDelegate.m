//
//  BIAppDelegate.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/8/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIAppDelegate.h"
#import "BISplashViewController.h"
#import "BIHomeViewController.h"

@implementation BIAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self startParseWithLaunchOptions:launchOptions];
    [self setupUI];
    [self presentCorrectRootController];
    
    return YES;
}

- (void)startParseWithLaunchOptions:(NSDictionary*)launchOptions {
    [Parse setApplicationId:@"QXBNXOh5TYU1oUc6rYMPqG5XNct5zZdjhlbQLrhQ"
                  clientKey:@"wytpn1ob1jPfhbQKaa1RUw1CUrynyVnTWfg8RaDE"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
}

- (void)setupUI {
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)presentCorrectRootController {
    UIStoryboard *mainStoryboard = [UIStoryboard mainStoryboard];
    UIViewController *vc;
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"BIHomeNavigationController"];
    } else {
        vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"BISplashViewController"];
    }
    
    [self setRootViewController:vc];
}

- (void)setRootViewController:(UIViewController*)vc {
    [UIView transitionWithView:self.window duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.window.rootViewController = vc;
                    } completion:nil];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end