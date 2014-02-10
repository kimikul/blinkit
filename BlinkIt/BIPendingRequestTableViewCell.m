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
    _profilePic.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:user[@"photoURL"]]]];
    
}

#pragma mark - actions

- (IBAction)tappedAccept:(id)sender {
    _activity[@"type"] = @"follow";
    
    [_activity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self.delegate pendingRequestCell:self tappedAcceptRequestForUser:_activity[@"fromUser"] error:error];
    }];
}

@end
