//
//  UIGestureRecognizer+NLDInternalMethodCall.m
//  Pods
//
//  Created by 高振伟 on 16/11/3.
//
//

#import "UIGestureRecognizer+NLDInternalMethodCall.h"

@implementation UIGestureRecognizer (NLDInternalMethodCall)

- (BOOL)isInternalMethodCallWithTarget:(id)target action:(SEL)action
{
    BOOL internalCall = YES;
    
    // 目前只判断这两种手势
    if (([self isKindOfClass:[UITapGestureRecognizer class]] || [self isKindOfClass:[UILongPressGestureRecognizer class]])) {
        NSString *bundleName = [[NSBundle bundleForClass:[target class]] description];
        if ([bundleName rangeOfString:@"UIKit.framework"].location == NSNotFound) {
            internalCall = NO;
            
            if ([target isKindOfClass:[UITableViewCell class]]) {
                NSString *sel = NSStringFromSelector(action);
                if ([sel hasPrefix:@"_"]) {
                    internalCall = YES;
                }
            }
        }
    }
    
    return internalCall;
}

@end
