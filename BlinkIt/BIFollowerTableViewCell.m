//
//  BIFollowerTableViewCell.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 3/10/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIFollowerTableViewCell.h"

@interface BIFollowerTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *profilePic;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *removeButton;
@end

@implementation BIFollowerTableViewCell

#pragma mark - class methods

+ (NSString*)reuseIdentifier {
    return @"BIFollowerTableViewCell";
}

+ (CGFloat)cellHeight {
    return 45;
}

#pragma mark - lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _removeButton.layer.cornerRadius = 3.0;
    
    _profilePic.layer.cornerRadius = 2.0;
    _profilePic.clipsToBounds = YES;
}

#pragma mark - setter/getter

- (void)setActivity:(PFObject *)activity {
    _activity = activity;
    
    PFUser *user = activity[@"fromUser"];
    _nameLabel.text = user[@"name"];
    
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

@end
