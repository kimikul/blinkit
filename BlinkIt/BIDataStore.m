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

@end
