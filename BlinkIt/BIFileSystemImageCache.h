//
//  BIFileSystemImageCache.h
//  BlinkIt
//
//  Created by Kimberly Hsiao on 2/25/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BIFileSystemImageCache : NSObject

+ (BIFileSystemImageCache *)shared;
- (id)objectForKey:(id)aKey;
- (void)setObject:(id)object forKey:(id)cachedKey;

@end
