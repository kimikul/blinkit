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
@property (weak, nonatomic) IBOutlet UIButton *ignoreButton;
@end

@implementation BINotificationFollowRequestCell

#pragma mark - class methods

+ (CGFloat)cellHeight {
    return 50;
}

+ (NSString*)reuseIdentifier {
    return @"BINotificationFollowRequestCell";
}

#pragma mark - lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _acceptButton.layer.cornerRadius = 2.0;
    _acceptButton.clipsToBounds = YES;
    
    _ignoreButton.layer.cornerRadius = 2.0;
    _ignoreButton.clipsToBounds = YES;
    
    _profilePic.layer.cornerRadius = 2.0;
    _profilePic.clipsToBounds = YES;
}

#pragma mark - setter/getter

- (void)setActivity:(PFObject *)activity {
    
    _activity = activity;
    _acceptButton.enabled = YES;
    _ignoreButton.enabled = YES;
    
    PFUser *user = activity[@"fromUser"];
    
    NSString *type = activity[@"type"];
    if ([type isEqualToString:@"request to follow"]) {
        _notificationLabel.text = [NSString stringWithFormat:@"%@ has requested to follow you",user[@"name"]];
        [self setupAcceptButton];
    } else if ([type isEqualToString:@"follow"]) {
        _notificationLabel.text = [NSString stringWithFormat:@"%@ is now following you",user[@"name"]];
        
        BOOL isFollowingUser = [[BIDataStore shared] isFollowingUser:user];
        BOOL hasRequestedUser = [[BIDataStore shared] hasRequestedUser:user];
        
        if (!isFollowingUser && !hasRequestedUser) {
            [self setupFollowBackButton];
        } else {
            _acceptButton.hidden = YES;
            _ignoreButton.hidden = YES;
        }
    }
    
    NSString *photoURL = user[@"photoURL"];
    UIImage *profPic = [[BIFileSystemImageCache shared] objectForKey:photoURL];
    if (profPic) {
        _profilePic.image = profPic;
    } else if (photoURL.hasContent){
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        
        dispatch_async(queue, ^{
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:user[@"photoURL"]]]];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                _profilePic.image = image;
                [_profilePic fadeInWithDuration:0.2 completion:nil];
                [[BIFileSystemImageCache shared] setObject:image forKey:photoURL];
            });
        });
    }
}

#pragma mark - setup buttons

- (void)setupAcceptButton {
    [_acceptButton setTitle:@"Accept" forState:UIControlStateNormal];
    _acceptButton.backgroundColor = [UIColor acceptGreen];
    
    [_acceptButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [_acceptButton addTarget:self action:@selector(tappedAccept:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupFollowBackButton {
    _acceptButton.frameWidth = 90;
    _ignoreButton.hidden = YES;
    
    [_acceptButton setTitle:@"Follow" forState:UIControlStateNormal];
    _acceptButton.backgroundColor = [UIColor requestedOrange];
    
    [_acceptButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [_acceptButton addTarget:self action:@selector(tappedFollowBack:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - actions

- (void)tappedAccept:(id)sender {
    _activity[@"type"] = @"follow";
    _ignoreButton.enabled = NO;
    _acceptButton.enabled = NO;
    
    [_activity saveEventually];

    [self.delegate notificationCell:self tappedAcceptRequestForActivity:_activity];
}

- (void)tappedFollowBack:(id)sender {
    _acceptButton.enabled = NO;
    UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    aiv.center = CGPointMake(_acceptButton.frameWidth/2, _acceptButton.frameHeight/2);
    [aiv startAnimating];
    [_acceptButton addSubview:aiv];
    
    [_acceptButton setTitle:@"" forState:UIControlStateNormal];
    
    [BIFollowManager requestToFollowUserEventually:_activity[@"fromUser"] block:^(BOOL succeeded, NSError *error) {
        
        // remove other views
        [aiv removeFromSuperview];
        [_ignoreButton fadeOutWithDuration:0.2 completion:nil];
        
        [self.delegate notificationCell:self tappedFollowBackForActivity:_activity error:error];
    }];
}

- (IBAction)tappedIgnore:(id)sender {
    [_activity deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self.delegate notificationCell:self tappedIgnoreForActivity:_activity error:error];
    }];
}

@end
