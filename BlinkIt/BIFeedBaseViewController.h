//
//  BIFeedBaseViewController.h
//  BlinkIt
//
//  Created by Kimberly Hsiao on 8/8/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BITableViewController.h"

@interface BIFeedBaseViewController : BITableViewController

@property (nonatomic, assign) BOOL canPaginate;
@property (nonatomic, strong) NSMutableArray *allBlinksArray; // total list of blinks displayed
@property (nonatomic, strong) NSMutableArray *dateArray;       // array of dates with 1+ associated blinks
@property (nonatomic, strong) NSMutableArray *blinksArray;     // array of array of blinks associated with the date

- (void)sectionalizeBlinks:(NSArray*)blinks pagination:(BOOL)pagination;

@end
