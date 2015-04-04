//
//  BIComposeBlinkViewController.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 2/17/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIComposeBlinkViewController.h"
#import "BIPhotoViewController.h"
#import "BIImageUploadManager.h"

#define kAttachPhotoActionSheet 0
#define kDeleteBlinkActionSheet 1
#define kActionSheetTakePhoto 0
#define kActionSheetPhotoLibrary 1

@interface BIComposeBlinkViewController () <UIActionSheetDelegate, BIPhotoViewControllerDelegate, UIImagePickerControllerDelegate, BIImageUploadManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;
@property (nonatomic, strong) IBOutlet UILabel *remainingCharactersLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UILabel *privateLabel;
@property (weak, nonatomic) IBOutlet UIView *buttonContainerView;

@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) BIImageUploadManager *imageUploadManager;
@property (nonatomic, strong) UIImageView *thumbnailPreviewImageView;
@property (nonatomic, strong) NSDate *openDate;
@end

@implementation BIComposeBlinkViewController

#pragma mark - class methods

+ (UIFont*)fontForContent {
    return [UIFont systemFontOfSize:14];
}

#pragma mark - lifeyccle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Today's Blink";
    
    [self setupButtons];
    [self setupObservers];
    [self initializeView];
    [self setupThumbailPreviewImageView];
    
    _openDate = [NSDate date];
}

- (void)setupButtons {
    // cancel
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(tappedCancel:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    // blink
    UIBarButtonItem *blinkButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(tappedSave:)];
    self.navigationItem.rightBarButtonItem = blinkButton;
}

- (void)setupObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)initializeView {
    // if the existing blink is not from today, clear it out!
    if (_blink) {
        BOOL isBlinkFromToday = [NSDate isToday:_blink[@"date"]];
        if (!isBlinkFromToday) {
            _blink = nil;
        }
    }

    // show existing blink if there is one
    [self updateViewForBlink:_blink];
    
    _dateLabel.text = [NSDate spelledOutTodaysDate];
}

- (void)setupThumbailPreviewImageView {
    UIImageView *photoPreviewImage = [[UIImageView alloc] initWithFrame:CGRectMake(5,0,60,60)];
    photoPreviewImage.contentMode = UIViewContentModeScaleAspectFit;
    photoPreviewImage.backgroundColor = [UIColor blackColor];
    photoPreviewImage.layer.borderColor = [UIColor lightGrayColor].CGColor;
    photoPreviewImage.layer.borderWidth = 1.0;
    photoPreviewImage.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedThumbnailPreview:)];
    [photoPreviewImage addGestureRecognizer:tapGR];
    
    _thumbnailPreviewImageView = photoPreviewImage;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_contentTextView becomeFirstResponder];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (void)setSelectedImage:(UIImage *)selectedImage {
    _selectedImage = selectedImage;
    
    if (selectedImage) {
        _thumbnailPreviewImageView.image = selectedImage;
        _thumbnailPreviewImageView.frameMaxY = _buttonContainerView.frameY - 10;

        [self.view addSubview:_thumbnailPreviewImageView];
        [_thumbnailPreviewImageView fadeInWithDuration:0.3 completion:nil];
        
        _contentTextView.frameHeight = _contentTextView.frameHeight - _thumbnailPreviewImageView.frameHeight - 10;
    } else {
        [_thumbnailPreviewImageView fadeOutWithDuration:0.3 completion:^{
            _thumbnailPreviewImageView.image = nil;
            [_thumbnailPreviewImageView removeFromSuperview];
            self.navigationItem.rightBarButtonItem.enabled = ([self contentTextFieldHasContent] || _selectedImage) ? YES : NO;
        }];
        
        _contentTextView.frameHeight = _contentTextView.frameHeight + _thumbnailPreviewImageView.frameHeight + 10;
    }
    
    [self toggleCameraIconForSelectedImage:selectedImage];
}

- (void)toggleCameraIconForSelectedImage:(UIImage*)image {
    UIImage *cameraImage = [UIImage imageNamed:@"camera"];
    
    if (image) {
        cameraImage = [cameraImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
    [_cameraButton setImage:cameraImage forState:UIControlStateNormal];
}

#pragma mark - set blink and update ui

- (void)updateViewForBlink:(PFObject*)blink {
    if (blink) {
        _contentTextView.text = _blink[@"content"];
        _deleteButton.hidden = NO;
        _placeholderLabel.hidden = YES;

        // set image
        PFFile *imageFile = blink[@"imageFile"];
        if (imageFile) {
            [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                UIImage *image = [UIImage imageWithData:data];
                self.selectedImage = image;
            }];
        } else {
            self.selectedImage = nil;
        }
        
        // set privacy setting
        [self updatePrivateButtonForBlink:blink];
    } else {
        // set privacy setting
        BOOL private = [[NSUserDefaults standardUserDefaults] boolForKey:BIPrivacyDefaultSettings];
        if (private) {
            [self selectPrivateButton];
        } else {
            [self unselectPrivateButton];
        }
        
        // reset label and image
        _placeholderLabel.hidden = NO;
        _placeholderLabel.text = @"What do you want to remember about today?";
        _deleteButton.hidden = YES;
        self.selectedImage = nil;
    }
    
    _dateLabel.text = [NSDate spelledOutTodaysDate];
}

#pragma mark - notifications 

- (void)keyboardWillShow:(NSNotification*)note {
    CGPoint keyboardOrigin = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin;
    _buttonContainerView.frameY = keyboardOrigin.y - 45;
    _contentTextView.frameHeight = _buttonContainerView.frameY - _contentTextView.frameY - 5;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

#pragma mark - helper

- (BOOL)contentTextFieldHasContent {
    NSString *content = [_contentTextView.text stringByTrimmingWhiteSpace];
    return content.length > 0;
}

- (void)updateRemainingCharLabel {
    NSInteger remainingCharacterCount = 200 - _contentTextView.text.length;
    NSString *remainingCharactersLabel = [NSString stringWithFormat:@"%ld", (long)remainingCharacterCount];
    
    _remainingCharactersLabel.textColor = remainingCharacterCount <= 20 ? [UIColor redColor] : [UIColor darkGrayColor];

    self.remainingCharactersLabel.text = remainingCharactersLabel;
}

- (void)updatePrivateButtonForBlink:(PFObject*)blink {
    NSNumber *private = blink[@"private"];
    
    if ([private boolValue]) {
        [self selectPrivateButton];
    } else {
        [self unselectPrivateButton];
    }
}

#pragma mark - button actions

- (void)tappedCancel:(id)sender {
    [_contentTextView resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tappedSave:(id)sender {
//    [self showProgressHUD];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    NSString *content = [_contentTextView.text stringByTrimmingWhiteSpace];
    
    PFObject *theBlink;
    
    if (!_blink) {
        theBlink = [PFObject objectWithClassName:@"Blink"];
        theBlink[@"private"] = [NSNumber numberWithBool:_privateButton.selected];
    } else {
        theBlink = _blink;
    }
    
    theBlink[@"content"] = content;
    theBlink[@"user"] = [PFUser currentUser];
    theBlink[@"date"] = _openDate;

    UIImage *image = _selectedImage;
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
                
//                [self hideProgressHUD];
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

- (IBAction)deleteTapped:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"This will clear your entry for today. Are you sure?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Continue" otherButtonTitles:nil];
    actionSheet.tag = kDeleteBlinkActionSheet;
    [actionSheet showInView:self.view];
}

- (IBAction)cameraTapped:(id)sender {
    if (!_selectedImage) {
        [self promptToAttachImage];
    } else {
        [self showExistingPhotoForBlink:_blink];
    }
}

- (void)promptToAttachImage {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take New Photo", @"Choose Existing Photo", nil];
    actionSheet.tag = kAttachPhotoActionSheet;
    [actionSheet showInView:self.view];
}

- (void)showExistingPhotoForBlink:(PFObject*)blink {
    BIPhotoViewController *photoVC = [BIPhotoViewController new];
    photoVC.attachedImage = _selectedImage;
    photoVC.blink = blink;
    photoVC.delegate = self;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:photoVC];
    
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)tappedThumbnailPreview:(UITapGestureRecognizer*)tapGR {
    [self showExistingPhotoForBlink:_blink];
}

- (IBAction)privateButtonTapped:(id)sender {
    if (_privateButton.selected) {
        [self unselectPrivateButton];
    } else {
        [self selectPrivateButton];
    }
}

- (void)unselectPrivateButton {
    [_privateButton fadeTransitionWithDuration:0.2];
    [_privateLabel fadeTransitionWithDuration:0.2];
    
    _privateButton.imageEdgeInsets = UIEdgeInsetsMake(11, 0, 12, 65);

    UIImage *publicImage = [[UIImage imageNamed:@"Tab-friends"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    [_privateButton setImage:publicImage forState:UIControlStateNormal];
    _privateButton.tintColor = [UIColor darkGrayColor];
    _privateButton.selected = NO;

    _privateLabel.text = @"Followers";
    _privateLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    
    _blink[@"private"] = @NO;
}

- (void)selectPrivateButton {
    _privateButton.imageEdgeInsets = UIEdgeInsetsMake(12, 0, 12, 70);

    [_privateButton fadeTransitionWithDuration:0.2];
    [_privateLabel fadeTransitionWithDuration:0.2];

    UIImage *publicImage = [[UIImage imageNamed:@"private"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    [_privateButton setImage:publicImage forState:UIControlStateNormal];
    _privateButton.tintColor = [UIColor blueColor];
    _privateButton.selected = YES;

    _privateLabel.text = @"Private";
    _privateLabel.textColor = [UIColor blueColor];
    
    _blink[@"private"] = @YES;
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == kDeleteBlinkActionSheet) {
        if (buttonIndex == actionSheet.destructiveButtonIndex) {
            if (_blink) {
                [BIDeleteBlinkHelper deleteBlink:_blink completion:^(NSError *error) {
                    [_contentTextView resignFirstResponder];
                    [self dismissViewControllerAnimated:YES completion:nil];
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
    }
}

#pragma mark - BIPhotoViewControllerDelegate

- (void)photoViewController:(BIPhotoViewController*)photoViewController didRemovePhotoFromBlink:(PFObject*)blink {
    self.selectedImage = nil;
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
        static int topPhotoOptionBarHeight = 44;
        static int bottomPhotoOptionBarHeight = 100;
        
        CGRect frame = self.imagePickerController.view.bounds;
        CGFloat overlayBarHeight = (frame.size.height - bottomPhotoOptionBarHeight - topPhotoOptionBarHeight - frame.size.width); // 102
        
        UIGraphicsBeginImageContext(frame.size);
        [[UIColor blackColor] set];
//        UIRectFillUsingBlendMode(CGRectMake(0, topPhotoOptionBarHeight, frame.size.width, overlayBarHeight - topPhotoOptionBarHeight), kCGBlendModeNormal);
        UIRectFillUsingBlendMode(CGRectMake(0, frame.size.height - overlayBarHeight - bottomPhotoOptionBarHeight, frame.size.width, overlayBarHeight), kCGBlendModeNormal);
        UIImage *overlayImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIImageView *overlayIV = [[UIImageView alloc] initWithFrame:frame];
        overlayIV.userInteractionEnabled = NO;
        overlayIV.image = overlayImage;
        self.imagePickerController.cameraOverlayView = overlayIV;
    }
    
    [self.navigationController presentViewController:self.imagePickerController animated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        
        // stop device from responding to orientation changes
        UIDevice *currentDevice = [UIDevice currentDevice];
        while ([currentDevice isGeneratingDeviceOrientationNotifications])
            [currentDevice endGeneratingDeviceOrientationNotifications];
    }];
}


// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
    
    self.selectedImage = image;
    self.imageUploadManager.sourceType = picker.sourceType;
    
    [self dismissViewControllerAnimated:YES completion:^{
        self.navigationItem.rightBarButtonItem.enabled = ([self contentTextFieldHasContent] || _selectedImage) ? YES : NO;
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
        
//        [self hideProgressHUD];
    }
}

- (void)imageUploadManager:(BIImageUploadManager *)imageUploadManager didFailWithError:(NSError*)error {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error uploading your photo. Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    
//    [self hideProgressHUD];
}

- (void)finishSuccessfulBlinkUpdate:(PFObject*)blink {
//    [self hideProgressHUD];
    [[NSNotificationCenter defaultCenter] postNotificationName:kBIUpdateSavedBlinkNotification object:blink];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - uitextviewdelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    _placeholderLabel.hidden = (textView.text.length < 1) ? NO : YES;

    [self updateRemainingCharLabel];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    _placeholderLabel.hidden = (text.length < 1 && textView.text.length < 2) ? NO : YES;

    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    // update remaining char count label
    [self updateRemainingCharLabel];
    
    // enable / disable submit button
    self.navigationItem.rightBarButtonItem.enabled = (textView.text.length <= 200 && ([self contentTextFieldHasContent] || _selectedImage)) ? YES : NO;
    
    [textView scrollRangeToVisible:NSMakeRange(textView.text.length + 10, 0)];
}

@end
