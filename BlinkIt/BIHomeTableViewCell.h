//
//  BIHomeTableViewCell.h
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/10/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BIHomeTableViewCell;

@protocol BIHomeTableViewCellDelegate <NSObject>
- (void)homeCell:(BIHomeTableViewCell *)homeCell didTapImageView:(UIImageView*)imageView;
- (void)homeCell:(BIHomeTableViewCell*)homeCell togglePrivacyTo:(BOOL)private;
@end

@interface BIHomeTableViewCell : UITableViewCell

+ (NSString*)reuseIdentifier;
+ (CGFloat)heightForContent:(NSString*)content;
- (void)updatePrivacyButtonTo:(BOOL)isPrivate;

@property (nonatomic, weak) id <BIHomeTableViewCellDelegate> delegate;
@property (nonatomic, strong) PFObject *blink;
@property (weak, nonatomic) IBOutlet UIButton *privacyButton;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;

@end
