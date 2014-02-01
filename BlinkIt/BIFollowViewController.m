//
//  BIFollowViewController.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/31/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIFollowViewController.h"
#import "BIFollowersViewController.h"
#import "BIFollowingViewController.h"
#import "BIFacebookUserManager.h"

#define kSEGMENT_FOLLOWING    0
#define kSEGMENT_FOLLOWERS    1

@interface BIFollowViewController () <BIFacebookUserManagerDelegate>

@property (nonatomic, strong) BIFacebookUserManager *facebookUserManager;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UIViewController *activeViewController;
@property (nonatomic, strong) NSArray *segmentedViewControllers;

@end

@implementation BIFollowViewController

#pragma mark - getter/setter

- (BIFacebookUserManager*)facebookUserManager {
    if (!_facebookUserManager) {
        _facebookUserManager = [BIFacebookUserManager new];
        _facebookUserManager.delegate = self;
    }
    
    return _facebookUserManager;
}

#pragma mark - lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    
    [self setupButtons];
    [self setupViewControllers];
    [self.facebookUserManager fetchAndSaveFriends];
}

- (void)setupButtons {
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelTapped:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
}

- (void)setupViewControllers {
    UIStoryboard *mainStoryboard = [UIStoryboard mainStoryboard];
    
    BIFollowingViewController *followingVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"BIFollowingViewController"];
    BIFollowersViewController *followersVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"BIFollowersViewController"];
    
    _segmentedViewControllers = [NSArray arrayWithObjects:followingVC, followersVC, nil];
    [self cycleFromViewController:_activeViewController toViewController:followingVC];
}

#pragma mark - ibactions

- (void)cancelTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)segmentedControlChanged:(UISegmentedControl*)segmentedControl {
    NSInteger index = segmentedControl.selectedSegmentIndex;
    UIViewController *incomingViewController = [self.segmentedViewControllers objectAtIndex:index];
    [self cycleFromViewController:_activeViewController toViewController:incomingViewController];
}

- (void)cycleFromViewController:(UIViewController*)oldVC toViewController:(UIViewController*)newVC {
    
    if (newVC == oldVC) return;
    
    if (newVC) {
        if (oldVC) {
            // remove old vc and add new one
            [oldVC willMoveToParentViewController:nil];
            [self addChildViewController:newVC];
            
            // transition view from old vc to new one
            [self transitionFromViewController:oldVC
                              toViewController:newVC
                                      duration:0.25
                                       options:UIViewAnimationOptionLayoutSubviews
                                    animations:^{
                                    }
                                    completion:^(BOOL finished) {
                                        [oldVC removeFromParentViewController];
                                        [newVC didMoveToParentViewController:self];
                                        _activeViewController = newVC;
                                    }];
            
        } else {
            // add new child vc
            [self addChildViewController:newVC];
            [self.view addSubview:newVC.view];
            [newVC didMoveToParentViewController:self];
            _activeViewController = newVC;
        }
    }
}

#pragma mark - BIFacebookUserManagerDelegate

- (void)facebookManager:(BIFacebookUserManager*)facebookManager didRefreshFriendsList:(NSDictionary*)friendsList withError:(NSError*)error {
    NSLog(@"refreshed friends list %@",friendsList);

    BIFollowingViewController *vc = [_segmentedViewControllers objectAtIndex:kSEGMENT_FOLLOWING];
    [vc fetchFriends];
}

@end
