//
//  NLDRemoteEventManager.h
//  Pods
//
//  Created by 高振伟 on 16/8/10.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NLDRelativeViewRoute;

@interface NLDRemoteEventManager : NSObject

@property (nonatomic, nullable, readonly, strong) NSMutableDictionary<id<NLDRelativeViewRoute>, __kindof UIView *> *relativeViewDic;

+ (instancetype)sharedManager;

- (void)setAppKey:(NSString *)appKey domain:(NSString *)domain;

- (nullable NSDictionary<NSString *, NSString *> *)tryToCollectDataWithCurrentView:(__kindof UIView *)view eventName:(NSString *)eventName;

- (nullable NSDictionary<NSString *, NSString *> *)tryToCollectDataWithCurrentView:(__kindof UIView *)view indexPath:(nullable NSIndexPath *)indexPath eventName:(NSString *)eventName;

@end

NS_ASSUME_NONNULL_END
