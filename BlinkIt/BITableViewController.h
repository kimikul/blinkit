//
//  BITableViewController.h
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/10/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BITableViewController : UITableViewController

@property (nonatomic, strong) IBOutlet UITableView          *tableView;
@property (nonatomic, strong) IBOutlet UIView               *footerView;
@property (nonatomic, strong) IBOutlet UIView               *headerView;

@property (nonatomic, assign) BOOL                          useEmptyTableFooter;
@property (nonatomic, assign) BOOL                          useRefreshTableHeaderView;
@property (nonatomic, assign, getter = isLoading) BOOL      loading;
@property (nonatomic, strong) NSDate                        *lastRefreshDate;

@property (nonatomic, strong) UIRefreshControl              *refreshTableHeaderView;

- (void)reloadTableData;

@end
