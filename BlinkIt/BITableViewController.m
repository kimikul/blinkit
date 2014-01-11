//
//  BITableViewController.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/10/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BITableViewController.h"

@interface BITableViewController ()

@end

@implementation BITableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.tableFooterView = _useEmptyTableFooter ? [[UIView alloc] initWithFrame:CGRectZero] : _footerView;
}

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
