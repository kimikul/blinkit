//
//  BIFollowManager.h
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/31/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BIFollowManager : NSObject

// request to follow
+ (void)refreshRequestToFollowList;
+ (void)requestToFollowUserEventually:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)cancelRequestToFollowUserEventually:(PFUser *)user block:(void (^)(NSError *error))completionBlock;


// follow
+ (void)refreshFollowingList;
+ (void)followUserEventually:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)unfollowUserEventually:(PFUser *)user block:(void (^)(NSError *error))completionBlock;

@end
