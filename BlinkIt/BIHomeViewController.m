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

@interface BIHomeViewController () <UITextViewDelegate>
@property (nonatomic, strong) NSArray *blinksArray;
@property (nonatomic, strong) BITodayView *todayView;
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
//    UIBarButtonItem *composeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addBlink:)];
//    self.navigationItem.rightBarButtonItem = composeButton;
    
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
    _todayView = todayView;
    
    _todayView.contentTextView.delegate = self;
    
//    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedTodayView:)];
//    [_todayView addGestureRecognizer:tapGR];
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return _todayView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return _todayView.frameHeight;
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
    }
    
    _todayView.placeholderLabel.hidden = YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (textView.text.length < 200 || text.length == 0) {
        return YES;
    }
    
    return NO;
}

- (void)textViewDidChange:(UITextView *)textView {
    NSInteger remainingCharacterCount = 200 - textView.text.length;
    
    NSString *remainingCharactersLabel = [NSString stringWithFormat:@"%d", remainingCharacterCount];
    
    _todayView.remainingCharactersLabel.text = remainingCharactersLabel;
}

#pragma mark - ibactions

//- (void)tappedTodayView:(UITapGestureRecognizer*)tapGR {
//    _todayView.isExpanded = !_todayView.isExpanded;
//}

//- (void)addBlink:(id)sender {
//    UIStoryboard *mainStoryboard = [UIStoryboard mainStoryboard];
//
//    BIComposeBlinkViewController *composeVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"BIComposeBlinkNavigationController"];
//    [self presentViewController:composeVC animated:YES completion:nil];
//}

- (IBAction)logout:(id)sender {
    [PFUser logOut];
    
    UIStoryboard *mainStoryboard = [UIStoryboard mainStoryboard];
    BISplashViewController *splashVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"BISplashViewController"];
    
    BIAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                            
    [appDelegate setRootViewController:splashVC];
}



@end
