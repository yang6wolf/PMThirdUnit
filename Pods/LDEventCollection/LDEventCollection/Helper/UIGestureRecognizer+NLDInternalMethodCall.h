//
//  UIGestureRecognizer+NLDInternalMethodCall.h
//  Pods
//
//  Created by 高振伟 on 16/11/3.
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIGestureRecognizer (NLDInternalMethodCall)

- (BOOL)isInternalMethodCallWithTarget:(id)target action:(SEL)action;

@end

NS_ASSUME_NONNULL_END
