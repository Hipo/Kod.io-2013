//
//  UIView+CircularMask.m
//  kod.io-2013
//
//  Created by Cemal Eker on 25.9.13.
//  Copyright (c) 2013 kod.io. All rights reserved.
//

#import "UIView+CircularMask.h"

@implementation UIView (CircularMask)

- (void)applyCircularMask {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithOvalInRect:self.bounds];

    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    [maskLayer setFillColor:[[UIColor whiteColor] CGColor]];
    [maskLayer setBackgroundColor:[[UIColor clearColor] CGColor]];
    [maskLayer setPath:maskPath.CGPath];

    [self.layer setMask:maskLayer];
}

@end
