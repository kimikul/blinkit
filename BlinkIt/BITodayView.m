//
//  BITodayView.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/12/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BITodayView.h"

const CGFloat CONDENSED_HEIGHT = 57;

@interface BITodayView()
@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;
@property (nonatomic, strong) IBOutlet UILabel *remainingCharactersLabel;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
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
    
    _contentTextView.layer.cornerRadius = 5.0;
    _contentTextView.clipsToBounds = YES;
    _editButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;

    _dateLabel.text = [NSDate spelledOutTodaysDate];
}

#pragma mark - setter/getter

- (void)setBlink:(PFObject *)blink {
    _blink = blink;
    _contentTextView.text = blink[@"content"];
    
    [self updateForCondensedView];
}

- (void)setIsExpanded:(BOOL)isExpanded {
    _isExpanded = isExpanded;
    
    if (!isExpanded) {
        [self updateForCondensedView];
    } else {
        [self updateForExpandedView];
    }
    
    CGFloat newHeight = isExpanded ? 150 : CONDENSED_HEIGHT;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.frameHeight = newHeight;
        self.separatorView.frameY = newHeight;
    }];
}

#pragma mark - helper

- (BOOL)contentTextFieldHasContent {
    NSString *content = [_contentTextView.text stringByTrimmingWhiteSpace];
    return content.length > 0;
}

- (void)updateRemainingCharLabel {
    NSInteger remainingCharacterCount = 200 - _contentTextView.text.length;
    NSString *remainingCharactersLabel = [NSString stringWithFormat:@"%ld", remainingCharacterCount];
    
    self.remainingCharactersLabel.text = remainingCharactersLabel;
}

#pragma mark - expand / condense helpers

- (void)updateForExpandedView {
    _editButton.hidden = NO;
    [_editButton setTitle:@"Cancel" forState:UIControlStateNormal];
    
    _placeholderLabel.hidden = YES;
    _contentTextView.editable = YES;
    _submitButton.hidden = NO;
    _remainingCharactersLabel.hidden = NO;
    
    if ([self contentTextFieldHasContent]) {
        _submitButton.enabled = YES;
    } else {
        _submitButton.enabled = NO;
    }
    
    [_contentTextView becomeFirstResponder];
}

- (void)updateForCondensedView {
    _remainingCharactersLabel.hidden = YES;
    _submitButton.hidden = YES;
    
    if (_blink) {
        _editButton.hidden = NO;
        [_editButton setTitle:@"Edit" forState:UIControlStateNormal];
        _contentTextView.editable = NO;
        _placeholderLabel.hidden = YES;
    } else {
        _editButton.hidden = YES;
        _contentTextView.editable = YES;
        _placeholderLabel.hidden = NO;
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
    NSString *content = [_contentTextView.text stringByTrimmingWhiteSpace];
    
    if (!_blink) {
        PFObject *newBlink = [PFObject objectWithClassName:@"Blink"];
        newBlink[@"content"] = content;
        newBlink[@"date"] = [NSDate date];
        
        PFRelation *relation = [newBlink relationForKey:@"user"];
        [relation addObject:[PFUser currentUser]];
        [newBlink saveInBackground];
        
        [self.delegate todayView:self didSubmitBlink:newBlink];
    } else {
        PFObject *existingBlink = _blink;
        existingBlink[@"content"] = content;
        [existingBlink saveInBackground];
        
        [self.delegate todayView:self didSubmitBlink:existingBlink];
    }
}

- (IBAction)editTapped:(id)sender {
    if (_isExpanded) {
        _contentTextView.text = _blink[@"content"];
        [self.delegate todayView:self didTapCancelEditExistingBlink:_blink];
    } else {
        [self.delegate todayView:self didTapEditExistingBlink:_blink];
    }
}

@end
