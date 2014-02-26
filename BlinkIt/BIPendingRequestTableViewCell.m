//
//  BIPendingRequestTableViewCell.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 2/9/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIPendingRequestTableViewCell.h"

@interface BIPendingRequestTableViewCell ()
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profilePic;
@end

@implementation BIPendingRequestTableViewCell

#pragma mark - class methods

+ (CGFloat)cellHeight {
    return 44;
}

+ (NSString*)reuseIdentifier {
    return @"BIPendingRequestTableViewCell";
}

#pragma mark - lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _actionButton.layer.cornerRadius = 2.0;
    _actionButton.clipsToBounds = YES;
    
    _profilePic.layer.cornerRadius = 2.0;
    _profilePic.clipsToBounds = YES;
}

#pragma mark - setter/getter

- (void)setActivity:(PFObject *)activity {
    _activity = activity;
    
    PFUser *user = activity[@"fromUser"];
    
    _nameLabel.text = user[@"name"];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    
    dispatch_async(queue, ^{
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:user[@"photoURL"]]]];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            _profilePic.image = image;
        });
    });
}

#pragma mark - actions

- (IBAction)tappedAccept:(id)sender {
    _actionButton.enabled = NO;
    _activity[@"type"] = @"follow";
    
    [_activity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self.delegate pendingRequestCell:self tappedAcceptRequestForUser:_activity[@"fromUser"] error:error];
    }];
    
    _actionButton.backgroundColor = [UIColor acceptGreen];
}

- (IBAction)highlightAcceptButton:(id)sender {
    _actionButton.backgroundColor = [UIColor highlightAcceptGreen];
}

- (IBAction)dragOutsideAcceptButton:(id)sender {
    _actionButton.backgroundColor = [UIColor acceptGreen];
}

@end
