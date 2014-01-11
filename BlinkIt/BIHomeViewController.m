//
//  BIHomeViewController.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/10/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIHomeViewController.h"
#import "BIAppDelegate.h"
#import "BISplashViewController.h"
#import "BIHomeTableViewCell.h"
#import "BIComposeBlinkViewController.h"

@interface BIHomeViewController ()
@property (nonatomic, strong) NSArray *blinksArray;
@end

@implementation BIHomeViewController

#pragma mark - init

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.useEmptyTableFooter = YES;
    }
    
    return self;
}

#pragma mark - lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupButtons];
    [self setupTableView];
    [self fetchBlinks];
}

- (void)setupButtons {
    UIBarButtonItem *composeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addBlink:)];
    self.navigationItem.rightBarButtonItem = composeButton;
}

- (void)setupTableView {
}


#pragma mark - requests

- (void)fetchBlinks {
    PFQuery *query = [PFQuery queryWithClassName:@"Blink"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        _blinksArray = objects;
        [self reloadTableData];
    }];
}

#pragma mark - UITableViewDelegate / UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _blinksArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *blink = [_blinksArray objectAtIndex:indexPath.row];
    
    return [BIHomeTableViewCell heightForContent:blink[@"content"]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BIHomeTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BIHomeTableViewCell reuseIdentifier]];
    
    PFObject *blink = [_blinksArray objectAtIndex:indexPath.row];
    cell.blink = blink;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}



#pragma mark - ibactions

- (void)addBlink:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard mainStoryboard];

    BIComposeBlinkViewController *composeVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"BIComposeBlinkNavigationController"];
    [self presentViewController:composeVC animated:YES completion:nil];
}

- (IBAction)logout:(id)sender {
    [PFUser logOut];
    
    UIStoryboard *mainStoryboard = [UIStoryboard mainStoryboard];
    BISplashViewController *splashVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"BISplashViewController"];
    
    BIAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                            
    [appDelegate setRootViewController:splashVC];
}

@end
