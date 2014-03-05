//
//  BIHomeHeaderView.h
//  BlinkIt
//
//  Created by Kimberly Hsiao on 2/26/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BIHomeHeaderView;

@protocol BIHomeHeaderViewDelegate <NSObject>

- (void)headerView:(BIHomeHeaderView*)headerView didTapFollowersButton:(UIButton*)button;
- (void)headerView:(BIHomeHeaderView*)headerView didTapFollowingButton:(UIButton*)button;

@end


@interface BIHomeHeaderView : UIView

@property (nonatomic, weak) id <BIHomeHeaderViewDelegate> delegate;
@property (nonatomic, strong) PFUser *user;

- (void)updateBlinkCountWithIncrement:(BOOL)shouldIncrement;
- (void)refreshNumbers;

@end
