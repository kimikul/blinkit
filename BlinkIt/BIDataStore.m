//
//  BIDataStore.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/31/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIDataStore.h"

@interface BIDataStore ()
@property (nonatomic, strong) NSCache *cache;
@end

@implementation BIDataStore

static BIDataStore *shared = nil;

+ (BIDataStore*)shared {
    @synchronized (self) {
        if (!shared) {
            shared = [[BIDataStore alloc] init];
        }
    }
    
    return shared;
}

#pragma mark - lifecycle

- (id)init {
    self = [super init];
    if (self) {
        self.cache = [[NSCache alloc] init];
    }
    return self;
}

- (void) reset {
    [self.cache removeAllObjects];
}

#pragma mark - facebook friends

- (void)setFacebookFriends:(NSDictionary *)friends {
    NSString *key = kBIUserDefaultsFacebookFriendsKey;
    [self.cache setObject:friends forKey:key];
    [[NSUserDefaults standardUserDefaults] setObject:friends forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDictionary *)facebookFriends {
    NSString *key = kBIUserDefaultsFacebookFriendsKey;
    if ([self.cache objectForKey:key]) {
        return [self.cache objectForKey:key];
    }
    
    NSDictionary *friends = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    if (friends) {
        [self.cache setObject:friends forKey:key];
    }
    
    return friends;
}

#pragma mark - followed friends

- (NSArray*)followedFriends {
    NSString *key = kBIUserDefaultsFollowedFriendsKey;
    if ([self.cache objectForKey:key]) {
        return [self.cache objectForKey:key];
    }
    
    NSArray *followedFriends = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (followedFriends) {
        [self.cache setObject:followedFriends forKey:key];
    } else {
        followedFriends = [NSArray new];
    }
    
    return followedFriends;
}

- (void)setFollowedFriends:(NSArray*)followedFriends {
    NSString *key = kBIUserDefaultsFollowedFriendsKey;
    [self.cache setObject:followedFriends forKey:key];
    [[NSUserDefaults standardUserDefaults] setObject:followedFriends forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)addFollowedFriend:(PFUser*)user {
    NSMutableArray *followedFriends = [[self followedFriends] mutableCopy];
    if (![followedFriends containsObject:user[@"facebookID"]]) {
        [followedFriends addObject:user[@"facebookID"]];
    }
    
    [self setFollowedFriends:[followedFriends copy]];
}

- (void)removeFollowedFriend:(PFUser*)user {
    NSMutableArray *followedFriends = [[self followedFriends] mutableCopy];
    [followedFriends removeObject:user[@"facebookID"]];
    [self setFollowedFriends:[followedFriends copy]];
}

- (BOOL)isFollowingUser:(PFUser*)user {
    NSArray *followedFriends = [self followedFriends];
    return [followedFriends containsObject:user[@"facebookID"]];
}

#pragma mark - requested friends

- (NSArray*)requestedFriends {
    NSString *key = kBIUserDefaultsRequestedFriendsKey;
    if ([self.cache objectForKey:key]) {
        return [self.cache objectForKey:key];
    }
    
    NSArray *requestedFriends = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (requestedFriends) {
        [self.cache setObject:requestedFriends forKey:key];
    } else {
        requestedFriends = [NSArray new];
    }
    
    return requestedFriends;
}

- (void)setRequestedFriends:(NSArray *)requestedFriends {
    NSString *key = kBIUserDefaultsRequestedFriendsKey;
    [self.cache setObject:requestedFriends forKey:key];
    [[NSUserDefaults standardUserDefaults] setObject:requestedFriends forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)addRequestedFriend:(PFUser*)user {
    NSMutableArray *requestedFriends = [[self requestedFriends] mutableCopy];
    if (![requestedFriends containsObject:user[@"facebookID"]]) {
        [requestedFriends addObject:user[@"facebookID"]];
    }
    
    [self setRequestedFriends:[requestedFriends copy]];
}

- (void)removeRequestedFriend:(PFUser*)user {
    NSMutableArray *requestedFriends = [[self requestedFriends] mutableCopy];
    [requestedFriends removeObject:user[@"facebookID"]];
    [self setRequestedFriends:[requestedFriends copy]];
}

- (BOOL)hasRequestedUser:(PFUser*)user {
    NSArray *requestedFriends = [self requestedFriends];
    return [requestedFriends containsObject:user[@"facebookID"]];
}


#pragma mark - profile pics

- (NSMutableDictionary*)cachedProfilePics {
    NSString *key = kBICachedProfilePicsKey;
    if ([self.cache objectForKey:key]) {
        return [self.cache objectForKey:key];
    }
    
    return [NSMutableDictionary new];
}

- (void)setCachedProfilePics:(NSDictionary*)profilePics {
    NSString *key = kBICachedProfilePicsKey;
    [self.cache setObject:profilePics forKey:key];
}

- (void)addProfilePic:(UIImage*)image ForUser:(PFUser*)user {
    NSString *photoURL = user[@"photoURL"];
    
    if (image && photoURL.hasContent) {
        NSMutableDictionary *profilePicDict = [self cachedProfilePics];
        [profilePicDict setObject:image forKey:user[@"photoURL"]];
        [self setCachedProfilePics:profilePicDict];
    }
}

- (UIImage*)profilePicForUser:(PFUser*)user {
    NSMutableDictionary *profilePicDict = [self cachedProfilePics];
    return [profilePicDict objectForKey:user[@"photoURL"]];
}

- (BOOL)isCachedProfilePicForUser:(PFUser*)user {
    NSMutableDictionary *profilePicDict = [self cachedProfilePics];
    NSArray *allPhotoURLs = [profilePicDict allKeys];
    return [allPhotoURLs containsObject:user[@"photoURL"]];
}

@end
