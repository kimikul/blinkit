//
//  BIPendingRequestTableViewCell.h
//  BlinkIt
//
//  Created by Kimberly Hsiao on 2/9/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BIPendingRequestTableViewCell;

@protocol BIPendingRequestTableViewCellDelegate <NSObject>
- (void)pendingRequestCell:(BIPendingRequestTableViewCell*)cell tappedAcceptRequestForUser:(PFUser*)user error:(NSError*)error;
@end

@interface BIPendingRequestTableViewCell : UITableViewCell

+ (CGFloat)cellHeight;
+ (NSString*)reuseIdentifier;

@property (nonatomic, strong) PFObject *activity;
@property (nonatomic, weak) id <BIPendingRequestTableViewCellDelegate> delegate;

@end
