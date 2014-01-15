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
#import "BITodayView.h"

@interface BIHomeViewController () <UITextViewDelegate, BITodayViewDelegate>
@property (nonatomic, strong) NSArray *blinksArray;
@property (nonatomic, strong) BITodayView *todayView;
@property (strong, nonatomic) IBOutlet UIView *fadeLayer;
@end

@implementation BIHomeViewController

#pragma mark - init

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.useEmptyTableFooter = YES;
        self.useRefreshTableHeaderView = YES;
    }
    
    return self;
}

#pragma mark - lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupButtons];
    [self setupNav];
    [self setupTodayView];
}

- (void)setupButtons {
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(logout:)];
    self.navigationItem.leftBarButtonItem = logoutButton;
}

- (void)setupNav {
    self.navigationController.navigationBar.barTintColor = [UIColor mintGreen];
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    logoImageView.frame = CGRectMake(0, 0, 160, 24);
    logoImageView.autoresizingMask = self.navigationItem.titleView.autoresizingMask;
    self.navigationItem.titleView = logoImageView;
}

- (void)setupTodayView {
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"BITodayView" owner:self options:nil];
    BITodayView *todayView = [nibs objectAtIndex:0];
    todayView.frameY = 64;
    todayView.delegate = self;
    _todayView = todayView;
    _todayView.contentTextView.delegate = self;

    [self.view addSubview:todayView];

    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedFadeLayer:)];
    [_fadeLayer addGestureRecognizer:tapGR];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self fetchBlinks];
}

#pragma mark - requests

- (void)fetchBlinks {
    self.loading = YES;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Blink"];
    [query orderByDescending:@"date"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.loading = NO;
        
        NSMutableArray *blinks = [objects mutableCopy];
        
        for (PFObject *blink in objects) {
            NSDate *date = blink[@"date"];
            if ([self isDateToday:date]) {
                [blinks removeObject:blink];
                _todayView.blink = blink;
                break;
            }
        }
        
        _blinksArray = blinks;
        [self reloadTableData];
    }];
}

- (BOOL)isDateToday:(NSDate*)date {
    NSDateComponents *otherDay = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
    if([today day] == [otherDay day] &&
       [today month] == [otherDay month] &&
       [today year] == [otherDay year]) {
        return YES;
    }
    
    return NO;
}

- (void)refreshTableHeaderDidTriggerRefresh {
    [self fetchBlinks];
}

#pragma mark - scrollview

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_todayView.contentTextView resignFirstResponder];
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


#pragma mark - uitextviewdelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (!_todayView.isExpanded) {
        _todayView.isExpanded = YES;
        [_fadeLayer fadeInToOpacity:0.7 duration:0.5 completion:nil];
    }
    
    [_todayView updateRemainingCharLabel];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (textView.text.length < 200 || text.length == 0) {
        return YES;
    }
    
    return NO;
}

- (void)textViewDidChange:(UITextView *)textView {
    // update remaining char count label
    [_todayView updateRemainingCharLabel];
    
    // enable / disable submit button
    _todayView.submitButton.enabled = ([_todayView contentTextFieldHasContent]) ? YES : NO;
}

#pragma mark - BITodayViewDelegate

- (void)todayView:(BITodayView *)todayView didSubmitBlink:(PFObject *)blink {
    [self unfocusTodayView];
    _todayView.blink = blink;
}

- (void)todayView:(BITodayView *)todayView didTapEditExistingBlink:(PFObject*)blink {
    [self textViewDidBeginEditing:todayView.contentTextView];
}

- (void)todayView:(BITodayView *)todayView didTapCancelEditExistingBlink:(PFObject*)blink {
    [self unfocusTodayView];
}

#pragma mark - ibactions

- (void)tappedFadeLayer:(UITapGestureRecognizer*)tapGR {
    [self unfocusTodayView];
}

- (void)unfocusTodayView {
    _todayView.isExpanded = NO;
    _todayView.contentTextView.text = _todayView.blink[@"content"];
    [_fadeLayer fadeOutWithDuration:0.5 completion:nil];
}

- (IBAction)logout:(id)sender {
    [PFUser logOut];
    
    UIStoryboard *mainStoryboard = [UIStoryboard mainStoryboard];
    BISplashViewController *splashVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"BISplashViewController"];
    
    BIAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                            
    [appDelegate setRootViewController:splashVC];
}



@end
