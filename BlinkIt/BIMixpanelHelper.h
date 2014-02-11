//
//  BIMixpanelHelper.h
//  BlinkIt
//
//  Created by Kimberly Hsiao on 2/10/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BIMixpanelHelper : NSObject

+ (void)setupSuperPropertiesForUser:(PFUser*)user;
+ (void)sendMixpanelEvent:(NSString*)eventName withProperties:(NSDictionary*)propDict;

@end
