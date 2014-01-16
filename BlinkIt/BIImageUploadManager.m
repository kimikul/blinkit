//
//  BIImageUploadManager.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/15/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIImageUploadManager.h"

@implementation BIImageUploadManager

- (void)uploadImage:(UIImage*)image {
    NSData *imageData = UIImageJPEGRepresentation(image, 0.05f);
    
    PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:imageData];
    
    [self.delegate showProgressHUD];
    
    // Save PFFile
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [self.delegate hideProgressHUD];
            
            PFObject *userPhoto = [PFObject objectWithClassName:@"UserPhoto"];
            [userPhoto setObject:imageFile forKey:@"imageFile"];
            
            userPhoto.ACL = [PFACL ACLWithUser:[PFUser currentUser]];
            
            PFUser *user = [PFUser currentUser];
            [userPhoto setObject:user forKey:@"user"];
            
            [userPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [self.delegate imageUploadManager:self didUploadImageWithError:error];
            }];
        }
        else{
            [self.delegate hideProgressHUD];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error uploading your photo. Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
    } progressBlock:^(int percentDone) {
        self.delegate.progressHUD.progress = (float)percentDone/100;
    }];

}

@end
