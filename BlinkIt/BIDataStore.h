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
- (void)reset;

// facebook friends
- (void)setFacebookFriends:(NSDictionary *)friends;  // dict of facebookID => PFUser
- (NSDictionary *)facebookFriends;


// followed friends
- (void)setFollowedFriends:(NSArray*)followedFriends;   // array of facebookIDs
- (NSArray*)followedFriends;
- (void)addFollowedFriend:(PFUser*)user;
- (void)removeFollowedFriend:(PFUser*)user;
- (BOOL)isFollowingUser:(PFUser*)user;


// requested freinds
- (void)setRequestedFriends:(NSArray*)requestedFriends;   // array of facebookIDs
- (NSArray*)requestedFriends;
- (void)addRequestedFriend:(PFUser*)user;
- (void)removeRequestedFriend:(PFUser*)user;
- (BOOL)hasRequestedUser:(PFUser*)user;

@end
