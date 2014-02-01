//
//  BIDataStore.h
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/31/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BIDataStore : NSObject

+ (BIDataStore*)shared;

- (void)setFacebookFriends:(NSDictionary *)friends;  // dict of facebookID => PFUser
- (NSDictionary *)facebookFriends;

- (void)setFollowedFriends:(NSArray*)followedFriends;   // array of facebookIDs
- (NSArray*)followedFriends;
- (void)addFollowedFriend:(PFUser*)user;
- (void)removeFollowedFriend:(PFUser*)user;

@end
