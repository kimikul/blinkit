//
//  BITodayView.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/12/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BITodayView.h"

const CGFloat CONDENSED_HEIGHT = 57;
const CGFloat EXPANDED_HEIGHT = 170;

@interface BITodayView()
@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;
@property (nonatomic, strong) IBOutlet UILabel *remainingCharactersLabel;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;

@end

@implementation BITodayView

#pragma mark - class methods

+ (UIFont*)fontForContent {
    return [UIFont systemFontOfSize:14];
}

#pragma mark - init

- (void)awakeFromNib {
    self.clipsToBounds = YES;
    self.frameHeight = CONDENSED_HEIGHT;
    
    _contentTextView.scrollsToTop = NO;
    _contentTextView.layer.cornerRadius = 5.0;
    _contentTextView.clipsToBounds = YES;
    _editButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;

    _dateLabel.text = [NSDate spelledOutTodaysDate];
}

#pragma mark - setter/getter

- (void)setBlink:(PFObject *)blink {
    _blink = blink;
    
    if (blink) {
        _placeholderLabel.text = blink[@"content"];
        
        PFFile *imageFile = blink[@"imageFile"];
        if (imageFile) {
            NSData *imageData = [imageFile getData];
            UIImage *image = [UIImage imageWithData:imageData];
            self.selectedImage = image;
        } else {
            self.selectedImage = nil;
        }
        
        [self updateForCondensedView];
    } else {
        _placeholderLabel.text = @"Click to edit today's blink";
        self.selectedImage = nil;
    }
    
    _dateLabel.text = [NSDate spelledOutTodaysDate];
}

- (void)setIsExpanded:(BOOL)isExpanded {
    _isExpanded = isExpanded;
    
    if (!isExpanded) {
        [self updateForCondensedView];
    } else {
        [self updateForExpandedView];
    }
    
    CGFloat newHeight = isExpanded ? EXPANDED_HEIGHT : CONDENSED_HEIGHT;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.frameHeight = newHeight;
        self.separatorView.frameY = newHeight;
    }];
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
    
    [_cameraButton setBackgroundImage:cameraImage forState:UIControlStateNormal];
}

#pragma mark - helper

- (BOOL)contentTextFieldHasContent {
    NSString *content = [_contentTextView.text stringByTrimmingWhiteSpace];
    return content.length > 0;
}

- (void)updateRemainingCharLabel {
    NSInteger remainingCharacterCount = 200 - _contentTextView.text.length;
    NSString *remainingCharactersLabel = [NSString stringWithFormat:@"%ld", (long)remainingCharacterCount];
    
    self.remainingCharactersLabel.text = remainingCharactersLabel;
}

#pragma mark - expand / condense helpers

- (void)updateForExpandedView {
    [_editButton setTitle:@"Cancel" forState:UIControlStateNormal];
    _editButton.hidden = NO;
    
    _placeholderLabel.hidden = YES;
    _contentTextView.editable = YES;
    _submitButton.hidden = NO;
    _cameraButton.hidden = NO;
    _remainingCharactersLabel.hidden = NO;
    
    // update textview and trash button based on whether there is an existing entry
    if (_blink) {
        _contentTextView.text = _blink[@"content"];
        _deleteButton.hidden = NO;
    } else {
        _deleteButton.hidden = YES;
    }
    
    // enable submit button or not
    _submitButton.enabled = [self contentTextFieldHasContent] ? YES : NO;
    
    [_contentTextView becomeFirstResponder];
}

- (void)updateForCondensedView {
    _remainingCharactersLabel.hidden = YES;
    _submitButton.hidden = YES;
    _cameraButton.hidden = YES;
    _deleteButton.hidden = YES;
    _contentTextView.text = @"";
    _placeholderLabel.hidden = NO;

    if (_blink) {
        [_editButton setTitle:@"Edit" forState:UIControlStateNormal];
        _editButton.hidden = NO;
        _contentTextView.editable = NO;
    } else {
        _editButton.hidden = YES;
        _contentTextView.editable = YES;
    }
    
    [_contentTextView resignFirstResponder];
}

#pragma mark - height helpers

- (CGFloat)heightForBlinkContent {
    CGFloat textViewHeight = [self heightForTextViewWithContent:_blink[@"content"]];
    
    return textViewHeight + 46;
}

- (CGFloat)heightForTextViewWithContent:(NSString*)content {
    UIFont *font = [BITodayView fontForContent];
    CGSize maxSize = CGSizeMake(300,1000);
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                font, NSFontAttributeName,
                                nil];
    
    CGRect rect = [content boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    
    return rect.size.height;
}

#pragma mark - button actions

- (IBAction)submitTapped:(id)sender {
    [self.delegate todayView:self didSubmitBlink:_blink];
}

- (IBAction)editTapped:(id)sender {
    if (_isExpanded) {
        _contentTextView.text = _blink[@"content"];
        [self.delegate todayView:self didTapCancelEditExistingBlink:_blink];
    } else {
        [self.delegate todayView:self didTapEditExistingBlink:_blink];
    }
}

- (IBAction)deleteTapped:(id)sender {
    [self.delegate todayView:self didTapDeleteExistingBlink:_blink];
}

- (IBAction)cameraTapped:(id)sender {
    if (!_selectedImage) {
        [self.delegate todayView:self addPhotoToBlink:_blink];
    } else {
        [self.delegate todayView:self showExistingPhotoForBlink:_blink];
    }
}

@end
