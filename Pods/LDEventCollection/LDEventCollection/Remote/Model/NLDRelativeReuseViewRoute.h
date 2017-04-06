//
//  NLDRelativeReuseViewRoute.h
//  Pods
//
//  Created by 高振伟 on 16/8/13.
//
//

#import <Foundation/Foundation.h>
#import "LDActiveReuseRoute.h"
#import "NLDRelativeViewRoute.h"

NS_ASSUME_NONNULL_BEGIN

@interface NLDRelativeReuseViewRoute : NSObject<LDActiveReuseRoute, NLDRelativeViewRoute>

@property (nonatomic, readonly, assign) NLDRelativeViewType relativeViewType;

@property (nonatomic, copy) NSString *viewName;
@property (nonatomic, copy) NSString *reuseViewName;
@property (nonatomic, copy) NSString *reuseContainerName;
@property (nonatomic, assign) LDContainerType containerType;
@property (nonatomic, copy) NSIndexPath *indexPath;
@property (nullable, nonatomic, copy) NSString *controllerName;

@property (nonatomic, copy) NSArray<NSString *> *fromControllerViewPaths;
@property (nonatomic, copy) NSArray<NSString *> *fromControllerDepthPaths;

@property (nonatomic, copy) NSArray<NSString *> *fromReuseViewPaths;
@property (nonatomic, copy) NSArray<NSString *> *fromReuseViewIndexPaths;

@property (nonatomic, readonly, copy) NSString *relativeViewPropertyPath;  // 用于通过kvc获取数据
@property (nonatomic, readonly, copy) NSString *relativeViewKey;           // 传递给后台数据时的key

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
