//
//  LDPositioning.h
//  Pods
//
//  Created by wuxu on 16/5/20.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LDActiveUnreuseRoute.h"
#import "LDActiveReuseRoute.h"

NS_ASSUME_NONNULL_BEGIN

@interface LDActivePositioning : NSObject

/**
 *  存储非重用路径的字典，key是路径信息，value是含有路径信息和view实例的block
 */
@property (nullable, nonatomic, readonly, strong) NSMutableDictionary<id<LDActiveUnreuseRoute>, void(^)(id<LDActiveUnreuseRoute> route, __kindof UIView *view)> *unreuseDic;

/**
 *  存储重用TableView路径的字典，key是路径信息，value是含有路径信息和view实例的block
 */
@property (nullable, nonatomic, readonly, strong) NSMutableDictionary<id<LDActiveReuseRoute>, void(^)(id<LDActiveReuseRoute> route, __kindof UIView *view)> *reuseTableViewDic;

/**
 *  存储重用CollectionView路径的字典，key是路径信息，value是含有路径信息和view实例的block
 */
@property (nullable, nonatomic, readonly, strong) NSMutableDictionary<id<LDActiveReuseRoute>, void(^)(id<LDActiveReuseRoute> route, __kindof UIView *view)> *reuseCollectionViewDic;

+ (instancetype)share;

@end


@interface LDActivePositioning () //Unreuse Route

/**
 *  定位一个不含重用控件的路径
 *
 *  @param route  实现LDPUnreuseRoute协议的对象
 *  @param target 找到后以block方式返回View
 */
- (void)positioningUnreuseRoute:(id<LDActiveUnreuseRoute>)route hitTarget:(void (^)(id<LDActiveUnreuseRoute> route, __kindof UIView *view))target;

/**
 *  定位多个不含重用控件的路径
 *
 *  @param routes  实现LDPUnreuseRoute协议的对象集合
 *  @param target 找到后以block方式返回View
 */
- (void)positioningUnreuseRoutes:(NSSet<id<LDActiveUnreuseRoute>> *)routes hitTarget:(void (^)(id<LDActiveUnreuseRoute> route, __kindof UIView *view))target;

/**
 *  移除某个不含重用控件的路径
 *
 *  @param route 实现LDPUnreuseRoute协议的对象
 */
- (void)stopPositioningUnreuseRoute:(id<LDActiveUnreuseRoute>)route;

/**
 *  移除全部不含重用控件的路径
 */
- (void)stopPositioningAllUnreuseRoute;

@end


@interface LDActivePositioning () //Reuse Route

/**
 *  定位一个包含重用控件的路径
 *
 *  @param route  实现LDPReuseRoute协议的对象
 *  @param target 找到后以block方式返回View
 */
- (void)positioningReuseRoute:(id<LDActiveReuseRoute>)route hitTarget:(void (^)(id<LDActiveReuseRoute> route, __kindof UIView *view))target;

/**
 *  定位多个包含重用控件的路径
 *
 *  @param routes  实现LDPReuseRoute协议的对象集合
 *  @param target 找到后以block方式返回View
 */
- (void)positioningReuseRoutes:(NSSet<id<LDActiveReuseRoute>> *)routes hitTarget:(void (^)(id<LDActiveReuseRoute> route, __kindof UIView *view))target;

/**
 *  移除某个包含重用控件的路径
 *
 *  @param route 实现LDPReuseRoute协议的对象
 */
- (void)stopPositioningReuseRoute:(id<LDActiveReuseRoute>)route;

/**
 *  移除全部包含重用控件的路径
 */
- (void)stopPositioningAllReuseRoute;

@end

NS_ASSUME_NONNULL_END
