//
//  NLDRelativeViewRoute.h
//  Pods
//
//  Created by 高振伟 on 16/8/8.
//
//

#import <Foundation/Foundation.h>
#import "LDActiveUnreuseRoute.h"
#import "NLDRelativeViewRoute.h"

NS_ASSUME_NONNULL_BEGIN
// 主动定位
@interface NLDRelativeUnreuseViewRoute : NSObject<LDActiveUnreuseRoute, NLDRelativeViewRoute>

@property (nonatomic, readonly, assign) NLDRelativeViewType relativeViewType;

@property (nonatomic, copy) NSString *viewName;
@property (nonatomic, copy, nullable) NSString *controllerName;
@property (nonatomic, copy) NSString *windowName;

@property (nonatomic, copy) NSArray<NSString *> *fromControllerViewPaths;
@property (nonatomic, copy) NSArray<NSString *> *fromControllerDepthPaths;

@property (nonatomic, readonly, copy) NSString *relativeViewPropertyPath;  // 用于通过kvc获取数据
@property (nonatomic, readonly, copy) NSString *relativeViewKey;           // 传递给后台数据时的key

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END