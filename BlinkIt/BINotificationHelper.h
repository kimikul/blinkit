//
//  BINotificationHelper.h
//  BlinkIt
//
//  Created by Kimberly Hsiao on 2/12/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BINotificationHelper : NSObject

+ (void)refreshNotificationsWithCompletion:(void (^)(NSArray*notifications, NSError* error))completion;
+ (void)addNotificationFromUser:(PFUser*)fromUser toUser:(PFUser*)toUser type:(NSString*)type;

@end
