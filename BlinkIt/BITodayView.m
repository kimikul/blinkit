//
//  BITodayView.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/12/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BITodayView.h"

@interface BITodayView()

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@end

@implementation BITodayView

+ (UIFont*)fontForContent {
    return [UIFont systemFontOfSize:14];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    _contentTextView.layer.cornerRadius = 5.0;
    _contentTextView.clipsToBounds = YES;
    _contentTextView.placeholder = @"What do you want to remember about today?";
    _contentTextView.placeholderColor = [UIColor lightGrayColor];
    

//    _dateLabel.text = [NSDate spelledOutTodaysDate];
}

#pragma mark - setter/getter

- (void)setBlink:(PFObject *)blink {
    _blink = blink;
    _contentTextView.text = blink[@"content"];
    _remainingCharactersLabel.hidden = YES;
    _submitButton.hidden = YES;
    
    CGFloat textViewHeight = [self heightForTextViewWithContent:blink[@"content"]];
    _contentTextView.frameHeight = textViewHeight;
    _contentTextView.editable = NO;
    
    self.frameHeight = textViewHeight + 50;
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
