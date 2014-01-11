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

@interface BIHomeViewController ()

@end

@implementation BIHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logout:(id)sender {
    [PFUser logOut];
    
    UIStoryboard *mainStoryboard = [UIStoryboard mainStoryboard];
    BISplashViewController *splashVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"BISplashViewController"];
    
    BIAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                            
    [appDelegate setRootViewController:splashVC];
}

@end
