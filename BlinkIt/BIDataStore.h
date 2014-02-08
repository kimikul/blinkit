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

// facebook friends
- (void)setFacebookFriends:(NSDictionary *)friends;  // dict of facebookID => PFUser
- (NSDictionary *)facebookFriends;


// followed friends
- (void)setFollowedFriends:(NSArray*)followedFriends;   // array of facebookIDs
- (NSArray*)followedFriends;
- (void)addFollowedFriend:(PFUser*)user;
- (void)removeFollowedFriend:(PFUser*)user;
- (BOOL)isFollowingUser:(PFUser*)user;


// cached profile pics
- (void)addProfilePic:(UIImage*)image withURL:(NSString*)url;

@end
