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

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@property (weak, nonatomic) IBOutlet UIView *separatorView;
@end

@implementation BITodayView

#pragma mark - class methods

+ (UIFont*)fontForContent {
    return [UIFont systemFontOfSize:14];
}

#pragma mark - init

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    self.clipsToBounds = YES;
    self.frameHeight = CONDENSED_HEIGHT;
    
    _contentTextView.layer.cornerRadius = 5.0;
    _contentTextView.clipsToBounds = YES;
//    _contentTextView.placeholder = @"What do you want to remember about today?";
//    _contentTextView.placeholderColor = [UIColor lightGrayColor];
    

    _dateLabel.text = [NSDate spelledOutTodaysDate];
}

#pragma mark - setter/getter

- (void)setBlink:(PFObject *)blink {
    _blink = blink;
    _contentTextView.text = blink[@"content"];
    _remainingCharactersLabel.hidden = YES;
    _submitButton.hidden = YES;
    _contentTextView.editable = NO;
    
//    [self updateHeightForBlinkContent];
    CGFloat newHeight = [self heightForBlinkContent];
    self.frameHeight = newHeight;
    self.separatorView.frameY = newHeight;
}

- (void)setIsExpanded:(BOOL)isExpanded {
    _isExpanded = isExpanded;
    
    if (!isExpanded) {
        [_contentTextView resignFirstResponder];
        
        if (_contentTextView.text.length == 0) {
            _placeholderLabel.hidden = NO;
        }
    }
    
    CGFloat newHeight;
    if (isExpanded) {
        if (_blink) {
            newHeight = [self heightForBlinkContent];
        } else {
            newHeight = 150;
        }
    } else {
        newHeight = CONDENSED_HEIGHT;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        self.frameHeight = newHeight;
        self.separatorView.frameY = newHeight;
    }];
}

#pragma mark - helper

- (CGFloat)heightForBlinkContent {
    CGFloat textViewHeight = [self heightForTextViewWithContent:_blink[@"content"]];
//    _contentTextView.frameHeight = textViewHeight;
    
    return textViewHeight + 50;
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

- (IBAction)submitTapped:(id)sender {
    PFObject *newBlink = [PFObject objectWithClassName:@"Blink"];
    newBlink[@"content"] = [_contentTextView.text stringByTrimmingWhiteSpace];
    newBlink[@"date"] = [NSDate date];
    
    PFRelation *relation = [newBlink relationForKey:@"user"];
    [relation addObject:[PFUser currentUser]];
    [newBlink saveInBackground];
}

@end
