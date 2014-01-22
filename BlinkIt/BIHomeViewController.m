//
//  BIHomeViewController.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/10/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIHomeViewController.h"
#import "BIHomeTableViewCell.h"
#import "BITodayView.h"
#import "BIImageUploadManager.h"
#import "BIPhotoViewController.h"
#import "BIHomePhotoTableViewCell.h"
#import "BISettingsViewController.h"
#import "BIPaginationTableViewCell.h"

#define kAttachPhotoActionSheet 0
#define kDeleteBlinkActionSheet 1
#define kActionSheetPhotoLibrary 0
#define kActionSheetTakePhoto 1
#define kNumBlinksPerPage 15

@interface BIHomeViewController () <UITextViewDelegate, BITodayViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, BIImageUploadManagerDelegate, BIPhotoViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *allBlinksArray;
@property (nonatomic, strong) NSArray *blinksArray;
@property (nonatomic, strong) BITodayView *todayView;
@property (nonatomic, strong) IBOutlet UIView *fadeLayer;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) BIImageUploadManager *imageUploadManager;
@property (nonatomic, assign) BOOL isPresentingOtherVC;
@property (weak, nonatomic) IBOutlet UIView *errorView;
@property (nonatomic, assign) BOOL canPaginate;
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

- (NSMutableArray*)allBlinksArray {
    if (!_allBlinksArray) {
        _allBlinksArray = [NSMutableArray new];
    }
    
    return _allBlinksArray;
}

#pragma mark - lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupButtons];
    [self setupNav];
    [self setupTodayView];
    [self setupErrorView];
}

- (void)setupButtons {
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    settingsButton.frame = CGRectMake(0,0,24,24);
    
    UIImage *settingsImage = [[UIImage imageNamed:@"settings"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [settingsButton setImage:settingsImage forState:UIControlStateNormal];
    [settingsButton addTarget:self action:@selector(tappedSettings:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *settingsBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:settingsButton];
    settingsBarButtonItem.customView.hidden = YES;
    self.navigationItem.leftBarButtonItem = settingsBarButtonItem;
}

- (void)setupNav {
    self.navigationController.navigationBar.barTintColor = [UIColor mintGreen];
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    logoImageView.frame = CGRectMake(0, 0, 160, 24);
    logoImageView.autoresizingMask = self.navigationItem.titleView.autoresizingMask;
    logoImageView.hidden = YES;
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

- (void)setupErrorView {
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fetchBlinks)];
    [_errorView addGestureRecognizer:tapGR];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!_isPresentingOtherVC) {
        [self fetchBlinksForPagination:NO];
    } else {
        _isPresentingOtherVC = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.navigationItem.titleView.hidden) {
        [self.navigationItem.titleView fadeInWithDuration:0.5 completion:nil];
        [self.navigationItem.leftBarButtonItem.customView fadeInWithDuration:0.5 completion:nil];
    }
}

#pragma mark - requests

- (void)fetchBlinksForPagination:(BOOL)pagination {
    self.loading = YES;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Blink"];
    query.limit = kNumBlinksPerPage;
    query.skip = pagination ? self.allBlinksArray.count : 0;
    [query orderByDescending:@"date"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.loading = NO;
        self.canPaginate = objects.count > 0 && (objects.count % kNumBlinksPerPage == 0);
        
        if (!error) {
            if (!_errorView.hidden) {
                [_errorView fadeOutWithDuration:0.4 completion:nil];
            }
            
            NSMutableArray *blinks = pagination ? [[self.allBlinksArray arrayByAddingObjectsFromArray:objects] mutableCopy] : [objects mutableCopy];
            self.allBlinksArray = [blinks copy];
            
            BOOL isBlinkToday = NO;
            for (PFObject *blink in blinks) {
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
            
            // append or replace existing data source
            _blinksArray = blinks;
            
            [self reloadTableData];
        } else {
            [_errorView fadeInWithDuration:0.4 completion:nil];
        }
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
    [self fetchBlinksForPagination:NO];
}

- (void)performPaginationRequestIfNecessary {
    if([self hasReachedTableEnd:self.tableView] && self.canPaginate) {
        [self fetchBlinksForPagination:YES];
    }
}

#pragma mark - UITableViewDelegate / UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _blinksArray.count + self.canPaginate;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // pagination row
    if (indexPath.row == _blinksArray.count) {
        return [BIPaginationTableViewCell cellHeight];
    }
    
    // regular row
    CGFloat height = 0;
    PFObject *blink = [_blinksArray objectAtIndex:indexPath.row];
    NSString *content = blink[@"content"];
    PFFile *imageFile = blink[@"imageFile"];
    
    if (imageFile) {
        height = [BIHomePhotoTableViewCell heightForContent:content];
    } else {
        height = [BIHomeTableViewCell heightForContent:content];
    }
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // pagination row
    if (indexPath.row == _blinksArray.count) {
        BIPaginationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BIPaginationTableViewCell reuseIdentifier]];
        [cell.aiv startAnimating];
        return cell;
    }
    
    // regular row
    PFObject *blink = [_blinksArray objectAtIndex:indexPath.row];
    BIHomeTableViewCell *cell;
    
    if (blink[@"imageFile"]) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:[BIHomePhotoTableViewCell reuseIdentifier]];
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:[BIHomeTableViewCell reuseIdentifier]];
    }
    
    cell.blink = blink;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - uitextviewdelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (!_todayView.isExpanded) {
        self.progressHUD.mode = MBProgressHUDModeIndeterminate;
        self.progressHUD.labelText = nil;
        
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
    _todayView.submitButton.enabled = ([_todayView contentTextFieldHasContent] || _todayView.selectedImage) ? YES : NO;
    
    [textView scrollRangeToVisible:NSMakeRange(textView.text.length + 10, 0)];
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
            if (!error) {
                [self finishSuccessfulBlinkUpdate:theBlink];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error saving your entry. Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
        }];
    }
}

- (void)todayView:(BITodayView *)todayView didTapEditExistingBlink:(PFObject*)blink {
    [self textViewDidBeginEditing:todayView.contentTextView];
}

- (void)todayView:(BITodayView *)todayView didTapCancelEditExistingBlink:(PFObject*)blink {
    [self unfocusTodayView];
    _todayView.blink = _todayView.blink;
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
        CGRect frame = self.imagePickerController.view.bounds;
        frame.size.height -= self.imagePickerController.navigationBar.bounds.size.height; // subtract 44
        CGFloat barHeight = (frame.size.height - frame.size.width) / 2; // 102
        
        UIGraphicsBeginImageContext(frame.size);
        [[UIColor blackColor] set];
        UIRectFillUsingBlendMode(CGRectMake(0, 30, frame.size.width, barHeight-35), kCGBlendModeNormal);
        UIRectFillUsingBlendMode(CGRectMake(0, frame.size.height - barHeight, frame.size.width, barHeight-26), kCGBlendModeNormal);
        UIImage *overlayImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIImageView *overlayIV = [[UIImageView alloc] initWithFrame:frame];
        overlayIV.userInteractionEnabled = NO;
        overlayIV.image = overlayImage;
        self.imagePickerController.cameraOverlayView = overlayIV;
    }
    
    _isPresentingOtherVC = YES;
    
    [self.navigationController presentViewController:self.imagePickerController animated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }];
}


// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
    
    _todayView.selectedImage = image;
    
    [self dismissViewControllerAnimated:YES completion:^{
        [_todayView.contentTextView becomeFirstResponder];
        
        _todayView.submitButton.enabled = ([_todayView contentTextFieldHasContent] || _todayView.selectedImage) ? YES : NO;
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
    _todayView.selectedImage = nil;
}

#pragma mark - ibactions

- (void)tappedFadeLayer:(UITapGestureRecognizer*)tapGR {
    [self unfocusTodayView];
    _todayView.blink = _todayView.blink;
}

- (void)unfocusTodayView {
    _todayView.isExpanded = NO;
    [_fadeLayer fadeOutWithDuration:0.5 completion:nil];
}

- (void)tappedSettings:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard mainStoryboard];
    
    UINavigationController *settingsNav = [mainStoryboard instantiateViewControllerWithIdentifier:@"BISettingsNavigationController"];
    [self presentViewController:settingsNav animated:YES completion:nil];
}



@end
