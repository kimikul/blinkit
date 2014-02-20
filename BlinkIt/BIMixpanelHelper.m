//
//  BIMixpanelHelper.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 2/10/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIMixpanelHelper.h"

@implementation BIMixpanelHelper

+ (BOOL)shouldDisableTracking {
#ifdef DEBUG
    return YES;
#endif
    return NO;
}

+ (void)setupSuperPropertiesForUser:(PFUser*)user {
    if (!user) return;
    if ([self shouldDisableTracking]) return;
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    NSString *email = user[@"email"] ? user[@"email"] : @"";
    NSString *gender = user[@"gender"] ? user[@"gender"] : @"";
    NSString *name = user[@"name"] ? user[@"name"] : @"";
    
    NSDictionary *propDict = @{
                               @"userID" : [user objectId],
                               @"name" : name,
                               @"email" : email,
                               @"gender" : gender,
                               };
    
    [mixpanel registerSuperProperties:propDict];
}

+ (void)sendMixpanelEvent:(NSString*)eventName withProperties:(NSDictionary*)propDict {
    if ([self shouldDisableTracking]) return;

    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:eventName properties:propDict];
}

@end
