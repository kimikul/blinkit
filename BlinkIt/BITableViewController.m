//
//  BITableViewController.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/10/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BITableViewController.h"

@interface BITableViewController ()
@property (nonatomic, strong) UITableViewController *tableViewController;
@end

@implementation BITableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.tableHeaderView = _headerView;
    self.tableView.tableFooterView = _useEmptyTableFooter ? [[UIView alloc] initWithFrame:CGRectZero] : _footerView;
    
    [self setupRefresh];
}

#pragma mark - refresh

- (void)setupRefresh {
    if(_useRefreshTableHeaderView) {
        
        _refreshTableHeaderView = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frameWidth, 60)];
        [_refreshTableHeaderView addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
        
        self.tableViewController = [UITableViewController new];
        [self addChildViewController:self.tableViewController];
        self.tableViewController.tableView = self.tableView;
        self.tableViewController.refreshControl = _refreshTableHeaderView;
        self.tableViewController.refreshControl.layer.zPosition = self.tableView.backgroundView.layer.zPosition + 1;
    }
}

- (void)handleRefresh:(UIRefreshControl *)refreshControl {
    [self.refreshTableHeaderView beginRefreshing];
    if(![self.tableView isDragging])
        [self refreshTableHeaderDidTriggerRefresh];
}

- (void)refreshTableHeaderDidTriggerRefresh {
    // Do nothing here.  Subclasses that want to have pull down refresh should override this.
}

-(void)setLoading:(BOOL)loading {
    if(_loading != loading) {
        if(!loading && _useRefreshTableHeaderView) {
            _lastRefreshDate = [NSDate date];
            [_refreshTableHeaderView endRefreshing];
        }
        
        _loading = loading;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if([self.refreshTableHeaderView isRefreshing])
        [self refreshTableHeaderDidTriggerRefresh];
}

- (BOOL)hasReachedTableEnd:(UITableView*)tableView {
    static NSInteger offset = 10;
    return tableView.contentOffset.y + tableView.frameHeight >= tableView.contentSize.height - offset;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self performPaginationRequestIfNecessary];
}

- (void)performPaginationRequestIfNecessary {
    // override
}

#pragma mark - helper

- (void)reloadTableData {
    [self.tableView reloadData];
    
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionFade;
    transition.duration = 0.2f;
    
    CALayer *viewLayer = self.tableView.layer;
    [viewLayer removeAnimationForKey:@"fadeTransition"];
    [viewLayer addAnimation:transition forKey:@"fadeTransition"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

@end
