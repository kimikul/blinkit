//
//  BIFollowViewController.h
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/31/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BITableViewController.h"

#define kSEGMENT_FOLLOWING    0
#define kSEGMENT_FOLLOWERS    1

@interface BIFollowViewController : BITableViewController

@property (nonatomic, assign) NSInteger selectedSegment;

@end
