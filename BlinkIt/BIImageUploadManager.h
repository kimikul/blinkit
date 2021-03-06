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
- (void)imageUploadManager:(BIImageUploadManager*)imageUploadManager didUploadImage:(UIImage*)image forBlink:(PFObject*)blink withError:(NSError*)error;
- (void)imageUploadManager:(BIImageUploadManager *)imageUploadManager didFailWithError:(NSError*)error;

@end

@interface BIImageUploadManager : NSObject

@property (nonatomic, assign) UIImagePickerControllerSourceType sourceType; // to determine if pic should be saved to camera roll
@property (nonatomic, weak) BIViewController <BIImageUploadManagerDelegate> * delegate;

- (void)uploadImage:(UIImage*)image forBlink:(PFObject*)blink;

@end
