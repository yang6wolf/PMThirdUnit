//
//  NLDRemoteEventManager.m
//  Pods
//
//  Created by 高振伟 on 16/8/10.
//
//

#import "NLDRemoteEventManager.h"
#import "NLDRemoteEventService.h"
#import "NLDRemoteEventModel.h"
#import "NLDTargetViewRoute.h"
#import "NLDRelativeUnreuseViewRoute.h"
#import "LDActivePositioning.h"
#import "LDPassivePositioning.h"
#import "NLDAppInfoUtils.h"

@interface NLDRemoteEventManager ()

@property (nonatomic, strong) NLDRemoteEventService *dataService;
@property (nonatomic, nullable, strong) NSMutableDictionary<id<NLDRelativeViewRoute>, __kindof UIView *> *relativeViewDic;
@property (nonatomic, strong, nullable) NSArray<NLDRemoteEventModel *> *remoteEvents;
@property (nonatomic, strong) NSMutableArray *subviewArray;

@end

@implementation NLDRemoteEventManager

/*
+ (void)load
{
    @autoreleasepool {
        __block id observer =
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification
                                                         object:nil
                                                          queue:nil
                                                     usingBlock:^(NSNotification * _Nonnull note) {
                                                         
                                                         // 获取本地待收集数据项，开始主动定位View
                                                         [[NLDRemoteEventManager sharedManager] startPositioning];
                                                         
                                                         [[NSNotificationCenter defaultCenter] removeObserver:observer];
                                                         observer = nil;
                                                     }];
    }
}
 */

+ (instancetype)sharedManager
{
    static NLDRemoteEventManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NLDRemoteEventManager alloc] init];
    });
    return instance;
}

- (void)setAppKey:(NSString *)appKey domain:(NSString *)domain
{
    _dataService = [[NLDRemoteEventService alloc] initWithAppKey:appKey domain:domain];
    [_dataService fetchRemoteEvents];
}

#pragma mark - 收集与当前view相关的业务层的数据

- (nullable NSDictionary<NSString *, NSString *> *)tryToCollectDataWithCurrentView:(__kindof UIView *)view eventName:(NSString *)eventName
{
    return [self tryToCollectDataWithCurrentView:view indexPath:nil eventName:eventName];
}

- (nullable NSDictionary<NSString *, NSString *> *)tryToCollectDataWithCurrentView:(__kindof UIView *)view indexPath:(nullable NSIndexPath *)indexPath eventName:(NSString *)eventName
{
    NSArray *remoteEvents = [self.dataService getRemoteEvents];
    if (!remoteEvents) {
        return nil;
    }
    if (!self.remoteEvents) {
        self.remoteEvents = remoteEvents;
    }
    __block NSMutableDictionary *resultDict = nil;
    
    [self.remoteEvents enumerateObjectsUsingBlock:^(NLDRemoteEventModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NLDRemoteEventModel *eventModel = (NLDRemoteEventModel *)obj;
        NLDTargetViewRoute *targetViewRoute = eventModel.targetViewRoute;
        
        // 首先判断事件名是否相同
        if (![targetViewRoute.targetViewEvent isEqualToString:eventName]) {
            return;
        }
        
        // 判断当前view是否等于targetView
        if (!eventModel.targetView || ![eventModel.targetView isEqual:view]) {
            // 采用被动定位来判断当前view是否是targetView
            BOOL isMatch = [LDPassivePositioning isRoute:targetViewRoute matchToView:view ignoreSwiftModule:YES];
            if (!isMatch) {
                return;
            }
        }
        
        // 判断当前view的indexPath是否等于viewRoute的indexPath
        if (eventModel.targetViewIndexPath && indexPath) {
            if (![eventModel.targetViewIndexPath isEqualToString:@"*:*"]) {
                NSString *indexPathString = [NSString stringWithFormat:@"%ld:%ld", (long)indexPath.section, (long)indexPath.row];
                if (![eventModel.targetViewIndexPath isEqualToString:indexPathString]) {
                    return;
                }
            }
        }
        
        // 获取所需要收集的数据
        eventModel.targetView = view;
        NSString *viewRouteIndexPath = [self viewRouteIndexPathForTargetViewRoute:targetViewRoute];
        eventModel.targetViewIndexPath = viewRouteIndexPath;
        
        NSString *keyValuePath = eventModel.targetViewRoute.propertyPath;
        NSMutableString *value = [[NSMutableString alloc] init];
        NSInteger viewSubViewNumber = [eventModel.targetViewRoute.subViewNumber integerValue];
        
        __block BOOL kvcAvailable = YES;
        // cell中只有一个item需要收集数据
        if (viewSubViewNumber == 1 || !viewSubViewNumber) {
            id data = [view valueForKeyPath:keyValuePath];
            if (!data) {
                kvcAvailable = NO;
            } else if ([data isKindOfClass:[NSNumber class]]){
                value = [data stringValue].mutableCopy;
            } else {
                value = data;
            }
        }
        // cell中多个item需要收集数据的情况
        else if (viewSubViewNumber > 1) {
            NSString *subViewClassName =  eventModel.targetViewRoute.subViewClsName;

            if (!subViewClassName) return;
            
            self.subviewArray = [[NSMutableArray alloc] init];
            [self getAllSubviews:view subViewClsName:subViewClassName];
            
            [self.subviewArray enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subView, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([subView isKindOfClass:NSClassFromString(subViewClassName)]) {
                    id data = [subView valueForKeyPath:keyValuePath];
                    if (data) {
                        if ([data isKindOfClass:[NSNumber class]]) {
                            data = [data stringValue];
                        }
                        if (value.length > 0) {
                            [value appendFormat:@";%@",data];
                        }
                        else {
                            [value appendString:data];
                        }
                    } else {
                        kvcAvailable = NO;
                    }
                }
            }];
        }
        // viewSubViewNumber 为零的话，可能为误填，返回
        else {
            return;
        }
        
        NSString *key = eventModel.targetViewRoute.propertyKey;
        if (!resultDict) {
            resultDict = [NSMutableDictionary dictionaryWithCapacity:2];
        }
        if (kvcAvailable) {
            [resultDict setObject:value forKey:key];
        } else {
            NSString *errorKey = @"KVC_ERROR";
            NSString *errorMsg = [NSString stringWithFormat:@"appVersion=%@, keyPath=%@", [NLDAppInfoUtils appBuildVersion], keyValuePath];
            [resultDict setValue:errorMsg forKey:errorKey];
        }
        
        /*
         UIView *relativeView = [self.relativeViewDic objectForKey:eventModel.relativeViewRoute];
         if (!relativeView) {  // 如果没有定位到相关view，则终止
         *stop = YES;
         return;
         }
         
         NSString *keyValuePath = eventModel.relativeViewRoute.relativeViewPropertyPath;
         id relativeData = [relativeView valueForKeyPath:keyValuePath];
         if (!relativeData) {
         *stop = YES;
         return;
         }
         NSString *relativeValue = relativeData;
         if ([relativeData isKindOfClass:[NSNumber class]]) {
         relativeValue = [relativeData stringValue];
         }
         NSString *relativeKey = eventModel.relativeViewRoute.relativeViewKey;
         resultDict = @{relativeKey: relativeValue};
         *stop = YES;
         return;
         */
    }];
    
    return resultDict;
}

- (nullable NSString *)viewRouteIndexPathForTargetViewRoute:(NLDTargetViewRoute *)viewRoute
{
    NSArray *depthPaths = viewRoute.fromControllerDepthPaths;
    for (NSString *str in depthPaths) {
        if ([str rangeOfString:@":"].location != NSNotFound) {
            return str;
        }
    }
    return nil;
}

- (void)getAllSubviews:(UIView *)view subViewClsName:(NSString *)clsName
{
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:NSClassFromString(clsName)]) {
            [self.subviewArray addObject:subview];
        }
        if (subview.subviews.count > 0) {
            [self getAllSubviews:subview subViewClsName:clsName];
        }
    }
}
    
/*
- (void)startPositioning
{
    self.relativeViewDic = [NSMutableDictionary dictionary];
    NSArray *remoteEvents = [self.dataService getRemoteEvents];
    if (!remoteEvents) {
        return;
    }
    
    for (NLDRemoteEventModel *eventModel in remoteEvents) {
        NLDRelativeViewType type = eventModel.relativeViewRoute.relativeViewType;
        if (type == NLDRelativeViewUnreuseType) {
            [[LDActivePositioning share] positioningUnreuseRoute:eventModel.relativeViewRoute hitTarget:^(id<LDActiveUnreuseRoute>  _Nonnull route, __kindof UIView * _Nonnull view) {
                @synchronized (self.relativeViewDic) {
                    [self.relativeViewDic setObject:view forKey:route];
                }
            }];
        } else if (type == NLDRelativeViewReuseType) {
            [[LDActivePositioning share] positioningReuseRoute:eventModel.relativeViewRoute hitTarget:^(id<LDActiveReuseRoute>  _Nonnull route, __kindof UIView * _Nonnull view) {
                @synchronized (self.relativeViewDic) {
                    [self.relativeViewDic setObject:view forKey:route];
                }
            }];
        }
    }
}
*/


@end
