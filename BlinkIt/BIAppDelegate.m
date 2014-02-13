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
#import "BIFacebookUserManager.h"
#import <Crashlytics/Crashlytics.h>

#define MIXPANEL_TOKEN @"3b0685b355f044f58e9ac31f6e733cf1"

@implementation BIAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // start 3rd party stuff
    [self startParseWithLaunchOptions:launchOptions];
    [PFFacebookUtils initializeFacebook];
    [self setupMixpanel];
    [self setupCrashlytics];
    
    // register for push notifications
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    
    // refresh stuff
    [self refreshFriendsAndFollows];
    [self refreshNotificationStuff];

    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];

    // continue
    [PFImageView class];
    [self presentCorrectRootController];
    
    [BIMixpanelHelper sendMixpanelEvent:@"APP_Open" withProperties:nil];
    
    return YES;
}

#pragma mark - parse init

- (void)startParseWithLaunchOptions:(NSDictionary*)launchOptions {
    [Parse setApplicationId:@"QXBNXOh5TYU1oUc6rYMPqG5XNct5zZdjhlbQLrhQ"
                  clientKey:@"wytpn1ob1jPfhbQKaa1RUw1CUrynyVnTWfg8RaDE"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
}

#pragma mark - setup Mixpanel

- (void)setupMixpanel {
    [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
    [BIMixpanelHelper setupSuperPropertiesForUser:[PFUser currentUser]];
}

#pragma mark - crashlytics

- (void)setupCrashlytics {
    [Crashlytics startWithAPIKey:@"639c04cf03ff76c8b837221e8d6882adef379e3e"];
    [BICrashlyticsHelper setupCrashlyticsProperties];
}

#pragma mark - friends and follows

- (void)refreshFriendsAndFollows {
    if ([PFUser currentUser]) {
        [[BIFacebookUserManager shared] refreshCurrentUserFacebookFriends];
        [BIFollowManager refreshFollowingList];
        [BIFollowManager refreshRequestToFollowList];
    }
}

#pragma mark - notifications

- (void)refreshNotificationStuff {
    [BINotificationHelper fetchAndUpdateBadgeCountWithCompletion:nil];
    [BINotificationHelper registerUserToInstallation];
}

#pragma mark - transition

- (void)presentCorrectRootController {
    UIStoryboard *mainStoryboard = [UIStoryboard mainStoryboard];
    UIViewController *vc;
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"BITabBarController"];
    } else {
        vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"BISplashViewController"];
    }
    
    [self setRootViewController:vc];
}

- (void)setRootViewController:(UIViewController*)vc {
    [UIView transitionWithView:self.window.rootViewController.view duration:0.3
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
    [self refreshFriendsAndFollows];
    [[NSNotificationCenter defaultCenter] postNotificationName:kBIRefreshHomeAndFeedNotification object:nil];
    
    [BIMixpanelHelper sendMixpanelEvent:@"APP_Open" withProperties:nil];
    [BINotificationHelper fetchAndUpdateBadgeCountWithCompletion:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
}

#pragma mark - background updates in ios7

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [BINotificationHelper fetchAndUpdateBadgeCountWithCompletion:completionHandler];
}

#pragma mark - push notifications

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
    [BINotificationHelper fetchAndUpdateBadgeCountWithCompletion:nil];
}

@end
