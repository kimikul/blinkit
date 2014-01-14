//
//  UIView+BlinkIt.h
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/10/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (BlinkIt)

@property (nonatomic) CGPoint frameOrigin;
@property (nonatomic) CGSize frameSize;
@property (nonatomic) CGFloat frameX;
@property (nonatomic) CGFloat frameY;
@property (nonatomic) CGFloat frameWidth;
@property (nonatomic) CGFloat frameHeight;
@property (nonatomic) CGFloat frameMinX;
@property (nonatomic) CGFloat frameMidX;
@property (nonatomic) CGFloat frameMaxX;
@property (nonatomic) CGFloat frameMinY;
@property (nonatomic) CGFloat frameMidY;
@property (nonatomic) CGFloat frameMaxY;
@property (nonatomic) CGPoint frameTopLeftPoint;
@property (nonatomic) CGPoint frameTopMiddlePoint;
@property (nonatomic) CGPoint frameTopRightPoint;
@property (nonatomic) CGPoint frameMiddleRightPoint;
@property (nonatomic) CGPoint frameBottomRightPoint;
@property (nonatomic) CGPoint frameBottomMiddlePoint;
@property (nonatomic) CGPoint frameBottomLeftPoint;
@property (nonatomic) CGPoint frameMiddleLeftPoint;
@property (nonatomic) CGPoint boundsOrigin;
@property (nonatomic) CGSize boundsSize;
@property (nonatomic) CGFloat boundsX;
@property (nonatomic) CGFloat boundsY;
@property (nonatomic) CGFloat boundsWidth;
@property (nonatomic) CGFloat boundsHeight;
@property (nonatomic) CGFloat boundsMinX;
@property (nonatomic) CGFloat boundsMidX;
@property (nonatomic) CGFloat boundsMaxX;
@property (nonatomic) CGFloat boundsMinY;
@property (nonatomic) CGFloat boundsMidY;
@property (nonatomic) CGFloat boundsMaxY;
@property (nonatomic) CGPoint boundsTopLeftPoint;
@property (nonatomic) CGPoint boundsTopMiddlePoint;
@property (nonatomic) CGPoint boundsTopRightPoint;
@property (nonatomic) CGPoint boundsMiddleRightPoint;
@property (nonatomic) CGPoint boundsBottomRightPoint;
@property (nonatomic) CGPoint boundsBottomMiddlePoint;
@property (nonatomic) CGPoint boundsBottomLeftPoint;
@property (nonatomic) CGPoint boundsMiddleLeftPoint;

- (void)fadeInToOpacity:(CGFloat)opacity
               duration:(NSTimeInterval)duration
             completion:(dispatch_block_t)block;

- (void)fadeOutToOpacity:(CGFloat)opacity
                duration:(NSTimeInterval)duration
              completion:(dispatch_block_t)block;

- (void)fadeInWithDuration:(NSTimeInterval)duration
                completion:(dispatch_block_t)block;

- (void)fadeOutWithDuration:(NSTimeInterval)duration
                 completion:(dispatch_block_t)block;

- (void)fadeToggleWithDuration:(NSTimeInterval)duration
                    completion:(dispatch_block_t)block;

- (void)fadeTransitionWithDuration:(NSTimeInterval)duration;

@end
