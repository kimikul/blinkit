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

@end

@implementation BIComposeBlinkViewController

#pragma mark - class methods

+ (UIFont*)fontForContent {
    return [UIFont systemFontOfSize:14];
}

#pragma mark - lifeyccle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupButtons];
    [self setupObservers];
    [self initializeView];
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
    [self updateViewForBlink:_blink];
    
    _dateLabel.text = [NSDate spelledOutTodaysDate];
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
    _buttonContainerView.frameY = keyboardOrigin.y - 44;
    _contentTextView.frameHeight = _buttonContainerView.frameY - _contentTextView.frameY - 5;
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
    NSString *content = [_contentTextView.text stringByTrimmingWhiteSpace];
    
    PFObject *theBlink;
    
    if (!_blink) {
        theBlink = [PFObject objectWithClassName:@"Blink"];
        theBlink[@"date"] = [NSDate date];
        theBlink[@"private"] = [NSNumber numberWithBool:_privateButton.selected];
    } else {
        theBlink = _blink;
        theBlink[@"date"] = [NSDate date];
    }
    
    theBlink[@"content"] = content;
    theBlink[@"user"] = [PFUser currentUser];

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

- (IBAction)privateButtonTapped:(id)sender {
    if (_privateButton.selected) {
        [self unselectPrivateButton];
    } else {
        [self selectPrivateButton];
    }
}

- (void)unselectPrivateButton {
    UIImage *publicImage = [[UIImage imageNamed:@"private"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    [_privateButton setImage:publicImage forState:UIControlStateNormal];
    _privateButton.tintColor = [UIColor darkGrayColor];
    _privateButton.selected = NO;
    
    _privateLabel.text = @"Public";
    _privateLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    
    _blink[@"private"] = @NO;
}

- (void)selectPrivateButton {
    UIImage *publicImage = [[UIImage imageNamed:@"private"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    [_privateButton setImage:publicImage forState:UIControlStateNormal];
    _privateButton.tintColor = [UIColor blueColor];
    _privateButton.selected = YES;
    
    _privateLabel.text = @"Private";
    _privateLabel.textColor = [UIColor blueColor];
    
    _blink[@"private"] = @YES;
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
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
    
    self.selectedImage = image;
    self.imageUploadManager.sourceType = picker.sourceType;
    
    [self dismissViewControllerAnimated:YES completion:^{
        [_contentTextView becomeFirstResponder];
        
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
    }
}

- (void)finishSuccessfulBlinkUpdate:(PFObject*)blink {
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

    if (textView.text.length < 200 || text.length == 0) {
        return YES;
    }
    
    return NO;
}

- (void)textViewDidChange:(UITextView *)textView {
    // update remaining char count label
    [self updateRemainingCharLabel];
    
    // enable / disable submit button
    self.navigationItem.rightBarButtonItem.enabled = ([self contentTextFieldHasContent] || _selectedImage) ? YES : NO;
    
    [textView scrollRangeToVisible:NSMakeRange(textView.text.length + 10, 0)];
}

@end
