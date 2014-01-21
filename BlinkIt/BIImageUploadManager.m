//
//  BIImageUploadManager.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/15/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIImageUploadManager.h"

@implementation BIImageUploadManager

- (void)uploadImage:(UIImage*)image forBlink:(PFObject*)blink {
    NSData *imageData = UIImageJPEGRepresentation(image, 0.7);
    
    PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:imageData];
    
    // Save PFFile
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [blink setObject:imageFile forKey:@"imageFile"];
            [blink saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [self.delegate imageUploadManager:self didUploadImage:image forBlink:blink withError:error];
            }];
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error uploading your photo. Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
    } progressBlock:^(int percentDone) {
        self.delegate.progressHUD.progress = (float)percentDone/100;
    }];

}

@end
