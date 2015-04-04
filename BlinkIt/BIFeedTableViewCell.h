//
//  BIFeedTableViewCell.h
//  BlinkIt
//
//  Created by Kimberly Hsiao on 2/6/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BIFeedTableViewCell;

@protocol BIFeedTableViewCellDelegate <NSObject>
- (void)feedCell:(BIFeedTableViewCell*)feedCell didTapUserProfile:(PFUser*)user;
- (void)feedCell:(BIFeedTableViewCell *)feedCell didTapImageView:(UIImageView*)imageView;
@end

@interface BIFeedTableViewCell : UITableViewCell

+ (NSString*)reuseIdentifier;
+ (CGFloat)heightForContent:(NSString*)content;

@property (nonatomic, strong) PFObject *blink;
@property (nonatomic, weak) id <BIFeedTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;

@end
