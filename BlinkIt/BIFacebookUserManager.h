//
//  BIFacebookUserManager.h
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/30/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BIFacebookUserManager : NSObject

+ (BIFacebookUserManager*)shared;
- (void)fetchAndSaveBasicUserInfoWithBlock:(void (^)(BOOL succeeded, NSError *error))completionBlock;
- (void)refreshCurrentUserFacebookFriends;

@end
