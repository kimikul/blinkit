//
//  UIColor+BlinkIt.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 1/11/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "UIColor+BlinkIt.h"

@implementation UIColor (BlinkIt)

+ (UIColor*)mintGreen {
    return [UIColor colorWithRed:170/255.0 green:235/255.0 blue:207/255.0 alpha:1.0];
}

+ (UIColor*)coral {
    return [UIColor colorWithRed:254/255.0 green:128/255.0 blue:128/255.0 alpha:1.0];
}

+ (UIColor*)acceptGreen {
    return [UIColor colorWithRed:33/255.0 green:158/255.0 blue:29/255.0 alpha:1.0];
}

+ (UIColor*)highlightAcceptGreen {
    return [UIColor colorWithRed:21/255.0 green:103/255.0 blue:18/255.0 alpha:1.0];
}

+ (UIColor*)followBlue {
    return [UIColor colorWithRed:69/255.0 green:54/255.0 blue:242/255.0 alpha:1.0];
}

+ (UIColor*)highlightFollowBlue {
    return [UIColor colorWithRed:50/255.0 green:39/255.0 blue:178/255.0 alpha:1.0];
}

+ (UIColor*)requestedOrange {
    return [UIColor orangeColor];
}

+ (UIColor*)highlightRequestedOrange {
    return [UIColor colorWithRed:192/255.0 green:71/255.0 blue:14/255.0 alpha:1.0];
}

@end
