//
//  BIFacebookUserManager.h
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/30/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BIFacebookUserManager;

@protocol BIFacebookUserManagerDelegate <NSObject>
- (void)facebookManager:(BIFacebookUserManager*)facebookManager didSaveUser:(PFUser*)user withError:(NSError*)error;
@end

@interface BIFacebookUserManager : NSObject

@property (nonatomic, weak) id <BIFacebookUserManagerDelegate> delegate;

- (void)fetchAndSaveBasicUserInfo;

@end
