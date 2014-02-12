//
//  BICrashlyticsHelper.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 2/11/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BICrashlyticsHelper.h"
#import <Crashlytics/Crashlytics.h>

@implementation BICrashlyticsHelper

+ (void)setupCrashlyticsProperties {
    PFUser *user = [PFUser currentUser];
    
    if (user) {
        NSString *name = user[@"name"] ? user[@"name"] : @"";
        NSString *email = user[@"email"] ? user[@"email"] : @"";
        
        [Crashlytics setUserIdentifier:[user objectId]];
        [Crashlytics setUserName:name];
        [Crashlytics setUserEmail:email];
    }
}

@end
