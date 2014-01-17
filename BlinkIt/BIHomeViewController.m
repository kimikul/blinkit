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
#import "BITodayView.h"
#import "BIImageUploadManager.h"
#import "BIPhotoViewController.h"

#define kAttachPhotoActionSheet 0
#define kDeleteBlinkActionSheet 1
#define kActionSheetPhotoLibrary 0
#define kActionSheetTakePhoto 1

@interface BIHomeViewController () <UITextViewDelegate, BITodayViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, BIImageUploadManagerDelegate, BIPhotoViewControllerDelegate>

@property (nonatomic, strong) NSArray *blinksArray;
@property (nonatomic, strong) BITodayView *todayView;
@property (nonatomic, strong) IBOutlet UIView *fadeLayer;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) BIImageUploadManager *imageUploadManager;
@property (nonatomic, assign) BOOL isPresentingOtherVC;
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

#pragma mark - setter/getter

- (UIImagePickerController*)imagePickerController {
    if (!_imagePickerController) {
        _imagePickerController = [UIImagePickerController new];
        _imagePickerController.delegate = self;
    }
    
    return _imagePickerController;
}

- (BIImageUploadManager*)imageUploadManager {
    if (!_imageUploadManager) {
        _imageUploadManager = [BIImageUploadManager new];
        _imageUploadManager.delegate = self;
    }
    
    return _imageUploadManager;
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
    
    if (!_isPresentingOtherVC) {
        [self fetchBlinks];
    } else {
        _isPresentingOtherVC = NO;
    }
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
        BOOL isBlinkToday = NO;
        
        for (PFObject *blink in objects) {
            NSDate *date = blink[@"date"];
            if ([self isDateToday:date]) {
                [blinks removeObject:blink];
                _todayView.blink = blink;
                isBlinkToday = YES;
                break;
            }
        }
        
        if (!isBlinkToday) {
            _todayView.blink = nil;
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

- (void)finishSuccessfulBlinkUpdate:(PFObject*)blink {
    self.progressHUD.mode = MBProgressHUDModeText;
    self.progressHUD.labelText = @"Saved!";
    [self showProgressHUDForDuration:0.8];
    
    [self unfocusTodayView];
    _todayView.blink = blink;
}

- (void)todayView:(BITodayView *)todayView didSubmitBlink:(PFObject *)blink {
    
    [self showProgressHUD];

    NSString *content = [_todayView.contentTextView.text stringByTrimmingWhiteSpace];
    
    PFObject *theBlink;
    
    if (!blink) {
        theBlink = [PFObject objectWithClassName:@"Blink"];
        theBlink[@"date"] = [NSDate date];
        theBlink[@"user"] = [PFUser currentUser];
    } else {
        theBlink = blink;
    }

    theBlink[@"content"] = content;
    
    UIImage *image = _todayView.selectedImage;
    if (image) {
        [self.imageUploadManager uploadImage:image forBlink:theBlink];
    } else {
        [theBlink removeObjectForKey:@"imageFile"];
        [theBlink saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self finishSuccessfulBlinkUpdate:theBlink];
        }];
    }
}

- (void)todayView:(BITodayView *)todayView didTapEditExistingBlink:(PFObject*)blink {
    [self textViewDidBeginEditing:todayView.contentTextView];
}

- (void)todayView:(BITodayView *)todayView didTapCancelEditExistingBlink:(PFObject*)blink {
    [self unfocusTodayView];
}

- (void)todayView:(BITodayView *)todayView didTapDeleteExistingBlink:(PFObject*)blink {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"This will clear your entry for today. Are you sure?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Continue" otherButtonTitles:nil];
    actionSheet.tag = kDeleteBlinkActionSheet;
    [actionSheet showInView:self.view];
}

- (void)todayView:(BITodayView *)todayView addPhotoToBlink:(PFObject*)blink {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"From Photo Library", @"Take New Photo", nil];
    actionSheet.tag = kAttachPhotoActionSheet;
    [actionSheet showInView:self.view];
}

- (void)todayView:(BITodayView *)todayView showExistingPhotoForBlink:(PFObject*)blink {
    BIPhotoViewController *photoVC = [BIPhotoViewController new];
    photoVC.attachedImage = todayView.selectedImage;
    photoVC.blink = blink;
    photoVC.delegate = self;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:photoVC];
    _isPresentingOtherVC = YES;
    
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == kDeleteBlinkActionSheet) {
        if (buttonIndex == actionSheet.destructiveButtonIndex) {
            PFObject *existingBlink = _todayView.blink;
            if (existingBlink) {
                [existingBlink deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        _todayView.blink = nil;
                        [self unfocusTodayView];
                    }
                }];
            }
        }
    } else if (actionSheet.tag == kAttachPhotoActionSheet) {
        if (buttonIndex == kActionSheetPhotoLibrary) {
            [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        } else if (buttonIndex == kActionSheetTakePhoto) {
            [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType {
    if(![UIImagePickerController isSourceTypeAvailable:sourceType]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device does not support this type of functionality" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    self.imagePickerController.sourceType = sourceType;
    self.imagePickerController.allowsEditing = YES;

    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        self.imagePickerController.showsCameraControls = NO;
    }
    
    _isPresentingOtherVC = YES;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}


// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    _todayView.selectedImage = image;
    
    [self dismissViewControllerAnimated:YES completion:^{
        [_todayView.contentTextView becomeFirstResponder];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - BIImageUploadManagerDelegate

- (void)imageUploadManager:(BIImageUploadManager*)imageUploadManager didUploadImage:(UIImage*)image forBlink:(PFObject*)blink withError:(NSError*)error {
    if (!error) {
        [self finishSuccessfulBlinkUpdate:blink];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error uploading your entry. Please try again!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - BIPhotoViewControllerDelegate

- (void)photoViewController:(BIPhotoViewController*)photoViewController didRemovePhotoFromBlink:(PFObject*)blink {
    [blink removeObjectForKey:@"imageFile"];
    _todayView.selectedImage = nil;
}

#pragma mark - ibactions

- (void)tappedFadeLayer:(UITapGestureRecognizer*)tapGR {
    [self unfocusTodayView];
}

- (void)unfocusTodayView {
    _todayView.isExpanded = NO;
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
