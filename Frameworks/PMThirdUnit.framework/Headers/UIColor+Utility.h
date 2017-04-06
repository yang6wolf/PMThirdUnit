//
//  UIColor+Utility.h
//  Overshare
//
//  Created by Jared Sinclair on 10/24/13.
//  Copyright (c) 2013 Overshare Kit. All rights reserved.
//
//
//  Based on UIColor+Extended by Erica Sadun
//

#import <UIKit/UIKit.h>

@interface UIColor (Utility)

- (CGColorSpaceModel)cp_colorSpaceModel;
- (BOOL)cp_canProvideRGBComponents;
- (CGFloat)cp_luminance;
- (UIColor *)cp_colorByInterpolatingToColor:(UIColor *)color byFraction:(CGFloat)fraction;
- (UIColor *)cp_contrastingColor;

+ (UIColor*)cp_colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue;
+ (UIColor*)cp_colorWithHex:(NSInteger)hexValue;

@end
