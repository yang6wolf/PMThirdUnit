//
//  FBUIFactory.m
//  NTFeedBack
//
//  Created by  龙会湖 on 14-7-21.
//  Copyright (c) 2014年 netease. All rights reserved.
//

#import "NFBUIFactory.h"
#import "NFBAppearanceProxy.h"
#import "NFBUtil.h"

@implementation NFBUIFactory

+ (UILabel *)labelForNavTitle:(NSString *)title {
    UILabel *label = [[UILabel alloc] init];
	[label setFont:[UIFont boldSystemFontOfSize:19]];
	[label setTextColor:[[NFBAppearanceProxy sharedAppearance] navigationTitleColor]];
	[label setText:title];
    [label sizeToFit];
	label.backgroundColor = [UIColor clearColor];
	label.textAlignment = NSTextAlignmentCenter;
	return label;
}

+ (UIBarButtonItem *)navigationBarItemWithTitle:(NSString*)title image:(UIImage *)image target:(id)target action:(SEL)selector {
    CGSize titleSize = [NFBUtil drawSizeOfString:title
                                        withFont:[[NFBAppearanceProxy sharedAppearance] navigationButtonTitleFont]
                               constrainedToSize:CGSizeMake(200, 29)];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[[NFBAppearanceProxy sharedAppearance] navigationButtonTitleColor] forState:UIControlStateNormal];
    button.titleLabel.font = [[NFBAppearanceProxy sharedAppearance] navigationButtonTitleFont];
    [button setImage:image forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, titleSize.width?:29, 29);
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

@end
