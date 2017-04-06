//
//  UIColor+Utility.m
//  Overshare
//
//  Created by Jared Sinclair on 10/24/13.
//  Copyright (c) 2013 Overshare Kit. All rights reserved.
//
//
//  Based on UIColor+Extended by Erica Sadun
//

#import "UIColor+Utility.h"

@implementation UIColor (Utility)

// Report model
- (CGColorSpaceModel)cp_colorSpaceModel {
    return CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
}

// Supports either RGB or W
- (BOOL)cp_canProvideRGBComponents {
    switch (self.cp_colorSpaceModel) {
        case kCGColorSpaceModelRGB:
        case kCGColorSpaceModelMonochrome:
            return YES;
        default:
            return NO;
    }
}

- (CGFloat)cp_luminance {
    NSAssert(self.cp_canProvideRGBComponents, @"Must be a RGB color to use -luminance");
    
    CGFloat r, g, b;
    if (![self getRed: &r green: &g blue: &b alpha:NULL])
        return 0.0f;
    
    // http://en.wikipedia.org/wiki/Luma_(video)
    // Y = 0.2126 R + 0.7152 G + 0.0722 B
    return r * 0.2126f + g * 0.7152f + b * 0.0722f;
}

// Andrew Wooster https://github.com/wooster
- (UIColor *)cp_colorByInterpolatingToColor:(UIColor *)color byFraction:(CGFloat)fraction {
    NSAssert(self.cp_canProvideRGBComponents, @"Self must be a RGB color to use arithmatic operations");
    NSAssert(color.cp_canProvideRGBComponents, @"Color must be a RGB color to use arithmatic operations");
    
    CGFloat r, g, b, a;
    if (![self getRed:&r green:&g blue:&b alpha:&a]) return nil;
    
    CGFloat r2,g2,b2,a2;
    if (![color getRed:&r2 green:&g2 blue:&b2 alpha:&a2]) return nil;
    
    CGFloat red = r + (fraction * (r2 - r));
    CGFloat green = g + (fraction * (g2 - g));
    CGFloat blue = b + (fraction * (b2 - b));
    CGFloat alpha = a + (fraction * (a2 - a));
    
    UIColor *new = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    return new;
}

// Pick a color that is likely to contrast well with this color
- (UIColor *)cp_contrastingColor {
    return (self.cp_luminance > 0.5f) ? [UIColor colorWithRed:0 green:0 blue:0 alpha:1] : [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
}


+ (UIColor*)cp_colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue
{
    return [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0
                           green:((float)((hexValue & 0xFF00) >> 8))/255.0
                            blue:((float)(hexValue & 0xFF))/255.0 alpha:alphaValue];
}

+ (UIColor*)cp_colorWithHex:(NSInteger)hexValue
{
    return [UIColor cp_colorWithHex:hexValue alpha:1.0];
}

@end





