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

@property (nonatomic, strong) NSMutableDictionary *fbFriends;

@end
