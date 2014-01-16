//
//  BIImageUploadManager.h
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/15/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BIViewController.h"

@class BIImageUploadManager;

@protocol BIImageUploadManagerDelegate <NSObject>
- (void)imageUploadManager:(BIImageUploadManager*)imageUploadManager didUploadImageWithError:(NSError*)error;
@end

@interface BIImageUploadManager : NSObject

@property (nonatomic, weak) BIViewController <BIImageUploadManagerDelegate> * delegate;

@end
