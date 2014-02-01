//
//  BIFeedViewController.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/31/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIFeedViewController.h"
#import "BIFollowViewController.h"

@interface BIFeedViewController ()

@end

@implementation BIFeedViewController

#pragma mark - lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.useEmptyTableFooter = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupButtons];
}

- (void)setupButtons {
    UIImage *friendsImage = [[UIImage imageNamed:@"Tab-friends"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIBarButtonItem *friendsButton = [[UIBarButtonItem alloc] initWithImage:friendsImage style:UIBarButtonItemStylePlain target:self action:@selector(tappedFriends:)];
    self.navigationItem.rightBarButtonItem = friendsButton;
}

#pragma mark - button actions

- (void)tappedFriends:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard mainStoryboard];
    UINavigationController *nav = [mainStoryboard instantiateViewControllerWithIdentifier:@"BIFollowNavigationController"];
    
    [self presentViewController:nav animated:YES completion:nil];
}


@end
