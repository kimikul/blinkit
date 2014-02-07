//
//  BINoFollowResultsTableViewCell.h
//  BlinkIt
//
//  Created by Kimberly Hsiao on 2/6/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kLABEL_NOFRIENDS @"None of your friends are on BlinkIt yet.\nHelp spread the word! :)"
#define kLABEL_NOFOLLOWERS @"You have no followers yet :("
#define kLABEL_NOFRIENDPOSTS @"The friends you are following have not shared any blinks yet :("

@interface BINoFollowResultsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *noResultsLabel;

+ (CGFloat)cellHeight;
+ (NSString*)reuseIdentifier;

@end
