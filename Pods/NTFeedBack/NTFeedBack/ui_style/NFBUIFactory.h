//
//  FBUIFactory.h
//  NTFeedBack
//
//  Created by  龙会湖 on 14-7-21.
//  Copyright (c) 2014年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NFBUIFactory : NSObject

+ (UILabel *)labelForNavTitle:(NSString *)title;
+ (UIBarButtonItem *)navigationBarItemWithTitle:(NSString*)title image:(UIImage *)image target:(id)target action:(SEL)selector;

@end
