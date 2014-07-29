//
//  BIMyBlinksBaseViewController.h
//  BlinkIt
//
//  Created by Kimberly Hsiao on 7/28/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BITableViewController.h"

@interface BIMyBlinksBaseViewController : BITableViewController
@property (nonatomic, strong) NSMutableArray *allBlinksArray;
@property (nonatomic, assign) BOOL canPaginate;
@property (weak, nonatomic) IBOutlet UIView *noBlinksView;
@end
