//
//  BINotificationFollowRequestCell.h
//  BlinkIt
//
//  Created by Kimberly Hsiao on 2/12/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BINotificationFollowRequestCell;

@protocol BINotificationFollowRequestCellDelegate <NSObject>
- (void)notificationCell:(BINotificationFollowRequestCell*)cell tappedAcceptRequestForActivity:(PFObject*)activity error:(NSError*)error;
@end

@interface BINotificationFollowRequestCell : UITableViewCell

@property (nonatomic, strong) PFObject *activity;
@property (nonatomic, weak) id <BINotificationFollowRequestCellDelegate> delegate;

+ (CGFloat)cellHeight;
+ (NSString*)reuseIdentifier;

@end
