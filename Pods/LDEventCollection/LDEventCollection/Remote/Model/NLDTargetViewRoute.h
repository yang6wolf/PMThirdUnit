//
//  NLDTargetViewRoute.h
//  Pods
//
//  Created by 高振伟 on 16/8/8.
//
//

#import <Foundation/Foundation.h>
#import "LDPassiveRoute.h"

NS_ASSUME_NONNULL_BEGIN
// 被动定位
@interface NLDTargetViewRoute : NSObject<LDPassiveRoute>

@property (nonatomic, copy) NSString *viewName;
@property (nonatomic, copy, nullable) NSString *controllerName;
@property (nonatomic, copy) NSString *windowName;

@property (nonatomic, copy) NSArray<NSString *> *fromControllerViewPaths;
@property (nonatomic, copy) NSArray<NSString *> *fromControllerDepthPaths;

@property (nonatomic, copy) NSString *targetViewEvent;  // 对应的方法
@property (nonatomic, copy) NSString *propertyPath;
@property (nonatomic, copy) NSString *propertyKey;

@property (nonatomic, copy) NSString *subViewNumber;
@property (nonatomic, copy) NSString *subViewClsName;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
