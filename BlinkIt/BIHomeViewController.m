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
#import "BINoFollowResultsTableViewCell.h"

#define kAttachPhotoActionSheet 0
#define kDeleteBlinkActionSheet 1
#define kDeletePreviousBlinkActionSheet 2
#define kActionSheetTakePhoto 0
#define kActionSheetPhotoLibrary 1
#define kNumBlinksPerPage 15

@interface BIHomeViewController () <UITextViewDelegate, BITodayViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, BIImageUploadManagerDelegate, BIPhotoViewControllerDelegate, BIHomeTableViewCellDelegate>

@property (nonatomic, strong) NSMutableArray *allBlinksArray;
@property (nonatomic, strong) NSMutableArray *blinksArray;
@property (nonatomic, strong) BITodayView *todayView;
@property (nonatomic, strong) IBOutlet UIView *fadeLayer;
@property (weak, nonatomic) IBOutlet UIView *errorView;

@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) BIImageUploadManager *imageUploadManager;

@property (nonatomic, strong) BIHomeTableViewCell *togglePrivacyCell;

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
    [self setupTableView];
    [self setupTodayView];
    [self setupErrorView];
    [self setupObservers];
    [self fetchBlinksForPagination:NO];
}

- (void)setupButtons {
    //settings
    BIButton *settingsButton = [BIButton buttonWithType:UIButtonTypeCustom];
    settingsButton.barButtonSide = BIBarButtonTypeLeft;
    settingsButton.frame = CGRectMake(0,0,30,30);
    
    UIImage *settingsImage = [[UIImage imageNamed:@"settings"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [settingsButton setBackgroundImage:settingsImage forState:UIControlStateNormal];
    [settingsButton addTarget:self action:@selector(tappedSettings:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *settingsBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:settingsButton];
    settingsBarButtonItem.customView.hidden = YES;
    self.navigationItem.leftBarButtonItem = settingsBarButtonItem;
    
    // notifications
    BIButton *notificationButton = [BIButton buttonWithType:UIButtonTypeCustom];
    notificationButton.barButtonSide = BIBarButtonTypeRight;
    notificationButton.frame = CGRectMake(0,0,35,30);
    notificationButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    notificationButton.titleEdgeInsets = UIEdgeInsetsMake(0, 9, 2, 0);
    
    UIImage *notificationImage = [[UIImage imageNamed:@"Notification-icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [notificationButton setBackgroundImage:notificationImage forState:UIControlStateNormal];
    [notificationButton addTarget:self action:@selector(tappedNotifications:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *notificationBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:notificationButton];
    notificationBarButtonItem.customView.hidden = YES;
    self.navigationItem.rightBarButtonItem = notificationBarButtonItem;
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

- (void)setupTableView {
    self.tableView.scrollsToTop = YES;
    
    [self.tableView registerNib:[UINib nibWithNibName:[BIHomePhotoTableViewCell reuseIdentifier] bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[BIHomePhotoTableViewCell reuseIdentifier]];
    [self.tableView registerNib:[UINib nibWithNibName:[BIHomeTableViewCell reuseIdentifier] bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[BIHomeTableViewCell reuseIdentifier]];
}

- (void)setupTodayView {
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"BITodayView" owner:nil options:nil];
    BITodayView *todayView = [nibs objectAtIndex:0];
    todayView.frameY = 64;
    todayView.delegate = self;
    
    UIView *view = [[UIView alloc] initWithFrame:todayView.frame];
    view.backgroundColor = [UIColor redColor];
    
    _todayView = todayView;
    _todayView.contentTextView.delegate = self;

    [self.view addSubview:_todayView];

    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedFadeLayer:)];
    [_fadeLayer addGestureRecognizer:tapGR];
}

- (void)setupErrorView {
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fetchBlinks)];
    [_errorView addGestureRecognizer:tapGR];
}

- (void)setupObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHome) name:kBIRefreshHomeAndFeedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateHomeBadgeCount:) name:kBIUpdateHomeNotificationBadgeNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.navigationItem.titleView.hidden) {
        [self.navigationItem.titleView fadeInWithDuration:0.5 completion:nil];
        [self.navigationItem.leftBarButtonItem.customView fadeInWithDuration:0.5 completion:nil];
        [self.navigationItem.rightBarButtonItem.customView fadeInWithDuration:0.5 completion:nil];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - requests

- (void)fetchBlinks {
    [self fetchBlinksForPagination:NO];
}

- (void)fetchBlinksForPagination:(BOOL)pagination {
    if (self.isLoading) return;
    self.loading = YES;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Blink"];
    query.limit = kNumBlinksPerPage;
    query.skip = pagination ? self.allBlinksArray.count : 0;
    [query orderByDescending:@"date"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.canPaginate = objects.count > 0 && (objects.count % kNumBlinksPerPage == 0);

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
        
        self.loading = NO;
    }];
    
    if (pagination) {
        [BIMixpanelHelper sendMixpanelEvent:@"HOME_paginateHome" withProperties:nil];
    }
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

- (void)refreshHome {
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    [self fetchBlinksForPagination:NO];
}

#pragma mark - refresh and pagination

- (void)refreshTableHeaderDidTriggerRefresh {
    [self fetchBlinksForPagination:NO];
}

- (void)performPaginationRequestIfNecessary {
    if([self hasReachedTableEnd:self.tableView] && self.canPaginate) {
        [self fetchBlinksForPagination:YES];
    }
}

#pragma mark - notifications

- (void)updateHomeBadgeCount:(NSNotification*)note {
    NSNumber *count = note.object;
    
    UIImage *notificationImage;
    NSString *buttonText = @"";
    
    if ([count integerValue] > 0) {
        notificationImage = [[UIImage imageNamed:@"Notification-icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        buttonText = [NSString stringWithFormat:@"%@",count];
    } else {
        notificationImage = [[UIImage imageNamed:@"Notification-icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
    UIButton *notieButton = (UIButton*)self.navigationItem.rightBarButtonItem.customView;
    [notieButton setTitle:buttonText forState:UIControlStateNormal];
    [notieButton setBackgroundImage:notificationImage forState:UIControlStateNormal];
}

#pragma mark - UITableViewDelegate / UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // no results row
    if (_blinksArray.count == 0 && !self.isLoading) {
        return 1;
    }
    
    return _blinksArray.count + self.canPaginate;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // no results row
    if (_blinksArray.count == 0 && !self.isLoading) {
        return [BINoFollowResultsTableViewCell cellHeight];
    }
    
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
    
    // no results row
    if (_blinksArray.count == 0 && !self.isLoading) {
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

        BINoFollowResultsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BINoFollowResultsTableViewCell reuseIdentifier]];
        return cell;
    }
    
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
    cell.delegate = self;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIActionSheet *deleteActionSheet = [[UIActionSheet alloc] initWithTitle:@"This will permanently delete your entry. Are you sure?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
        deleteActionSheet.tag = kDeletePreviousBlinkActionSheet;
        deleteActionSheet.accessibilityLabel = [NSString stringWithFormat:@"%d",indexPath.row];
        [deleteActionSheet showFromTabBar:self.tabBarController.tabBar];
    }
}

- (void)deleteBlinkAtIndex:(NSInteger)row {
    PFObject *blinkToDelete = [_blinksArray objectAtIndex:row];

    [blinkToDelete deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [_blinksArray removeObjectAtIndex:row];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationLeft];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error deleting your entry. Please try again!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }];
}

#pragma mark - uitextviewdelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (!_todayView.isExpanded) {
        self.progressHUD.mode = MBProgressHUDModeIndeterminate;
        self.progressHUD.labelText = nil;
        
        _todayView.isExpanded = YES;
        [_fadeLayer fadeInToOpacity:0.7 duration:0.5 completion:nil];
        
        [BIMixpanelHelper sendMixpanelEvent:@"TODAY_tappedToEditTodaysBlink" withProperties:@{@"source":@"first entry"}];
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
        theBlink[@"private"] = [NSNumber numberWithBool:_todayView.privateButton.selected];
    } else {
        theBlink = blink;
        theBlink[@"date"] = [NSDate date];
    }

    theBlink[@"content"] = content;
    
    UIImage *image = _todayView.selectedImage;
    BOOL hasImage = NO;
    if (image) {
        [self.imageUploadManager uploadImage:image forBlink:theBlink];
        hasImage = YES;
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
    
    [self sendMixpanelForSubmittingBlink:theBlink hasImage:hasImage];
}

- (void)sendMixpanelForSubmittingBlink:(PFObject*)blink hasImage:(BOOL)hasImage {
    NSMutableDictionary *propDict = [@{@"private" : blink[@"private"],
                                       @"contentLength" : @([blink[@"content"] length])
                                       } mutableCopy];
    
    if (hasImage) {
        propDict[@"hasPhoto"] = @(1);
    } else {
        propDict[@"hasPhoto"] = @(0);
    }
    
    [BIMixpanelHelper sendMixpanelEvent:@"TODAY_updatedTodaysBlink" withProperties:propDict];
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
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)todayView:(BITodayView *)todayView addPhotoToBlink:(PFObject*)blink {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take New Photo", @"Choose Existing Photo", nil];
    actionSheet.tag = kAttachPhotoActionSheet;
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)todayView:(BITodayView *)todayView showExistingPhotoForBlink:(PFObject*)blink {
    BIPhotoViewController *photoVC = [BIPhotoViewController new];
    photoVC.attachedImage = todayView.selectedImage;
    photoVC.blink = blink;
    photoVC.delegate = self;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:photoVC];
    
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
            
            [BIMixpanelHelper sendMixpanelEvent:@"TODAY_deleteTodaysBlink" withProperties:nil];
        }
    } else if (actionSheet.tag == kAttachPhotoActionSheet) {
        if (buttonIndex == kActionSheetPhotoLibrary) {
            [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            [BIMixpanelHelper sendMixpanelEvent:@"PHOTO_chooseExisting" withProperties:nil];
        } else if (buttonIndex == kActionSheetTakePhoto) {
            [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
            [BIMixpanelHelper sendMixpanelEvent:@"PHOTO_takeNewPhoto" withProperties:nil];
        }
    } else if (actionSheet.tag == kDeletePreviousBlinkActionSheet) {
        if (buttonIndex == actionSheet.destructiveButtonIndex) {
            NSInteger indexOfDeletedBlink = [actionSheet.accessibilityLabel integerValue];
            [self deleteBlinkAtIndex:indexOfDeletedBlink];
            
            [BIMixpanelHelper sendMixpanelEvent:@"MYBLINKS_deletedPreviousBlink" withProperties:nil];
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
    
    [self.navigationController presentViewController:self.imagePickerController animated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }];
}


// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
    
    _todayView.selectedImage = image;
    self.imageUploadManager.sourceType = picker.sourceType;
    
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
        if (imageUploadManager.sourceType == UIImagePickerControllerSourceTypeCamera) {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        }
        
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

#pragma mark - BIHomeTableViewCellDelegate

- (void)homeCell:(BIHomeTableViewCell*)homeCell togglePrivacyTo:(BOOL)private {
    _togglePrivacyCell = homeCell;
    
    NSString *msg = private ? @"Are you sure you want to make this blink private?" : @"Are you sure you want to make this blink public to your followers?";

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Toggle Privacy Setting" message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue",nil];
    alertView.tag = private;
    [alertView show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    // remember to reset toggle properties after its over
    if (buttonIndex != alertView.cancelButtonIndex) {
        BOOL newPrivacySetting = alertView.tag;
        
        PFObject *blink = _togglePrivacyCell.blink;
        blink[@"private"] = [NSNumber numberWithBool:newPrivacySetting];
    
        [blink saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [_togglePrivacyCell updatePrivacyButtonTo:newPrivacySetting];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Privacy setting was not updated. Please try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
            
            _togglePrivacyCell = nil;
        }];
        
        [BIMixpanelHelper sendMixpanelEvent:@"MYBLINKS_updatePrivacyOfPreviousBlink" withProperties:@{@"changeToPrivate":@(newPrivacySetting)}];
    }
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

- (void)tappedNotifications:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard mainStoryboard];
    
    UINavigationController *notificationsNav = [mainStoryboard instantiateViewControllerWithIdentifier:@"BINotificationsNavigationController"];
    [self presentViewController:notificationsNav animated:YES completion:nil];
}



@end
