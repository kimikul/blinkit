//
//  BINotificationFollowRequestCell.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 2/12/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BINotificationFollowRequestCell.h"

@interface BINotificationFollowRequestCell ()
@property (weak, nonatomic) IBOutlet UIImageView *profilePic;
@property (weak, nonatomic) IBOutlet UILabel *notificationLabel;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@end

@implementation BINotificationFollowRequestCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _acceptButton.layer.cornerRadius = 2.0;
    _acceptButton.clipsToBounds = YES;
    
    _profilePic.layer.cornerRadius = 2.0;
    _profilePic.clipsToBounds = YES;
}

- (void)setNotification:(PFObject *)notification {
    _notification = notification;
    
    PFUser *user = notification[@"fromUser"];
    
    _notificationLabel.text = [NSString stringWithFormat:@"%@ has requested to follow you",user[@"name"]];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);

    dispatch_async(queue, ^{
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:user[@"photoURL"]]]];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            _profilePic.image = image;
        });
    });
}

@end
