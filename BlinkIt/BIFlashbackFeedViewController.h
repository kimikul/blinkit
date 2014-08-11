//
//  BIFlashbackFeedViewController.h
//  BlinkIt
//
//  Created by Kimberly Hsiao on 8/10/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIFeedBaseViewController.h"

@interface BIFlashbackFeedViewController : BIFeedBaseViewController

@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) NSArray *flashbackDates;

- (void)fetchFlashbackFeed;
- (void)segmentedControlChanged:(UISegmentedControl*)segmentedControl;

@end
