//
//  LDPositioning.m
//  Pods
//
//  Created by wuxu on 16/5/20.
//
//

#import "LDActivePositioning.h"
#import "LDPositioningCommon.h"
#import "UIView+Positioning.h"
#import "LDPMethodSwizz.h"
#import <objc/message.h>

@interface LDActivePositioning()
@property (nullable, nonatomic, strong) NSMutableSet<NSString *> *unreuseControllers;
@property (nullable, nonatomic, strong) NSMutableDictionary<id<LDActiveUnreuseRoute>, void(^)(id<LDActiveUnreuseRoute> route, __kindof UIView *view)> *unreuseDic;
@property (nonatomic, strong) dispatch_semaphore_t unreuseSignal;

@property (nullable, nonatomic, strong) NSMutableSet<NSString *> *reuseTableViewControllers;
@property (nullable, nonatomic, strong) NSMutableDictionary<id<LDActiveReuseRoute>, void(^)(id<LDActiveReuseRoute> route, __kindof UIView *view)> *reuseTableViewDic;
@property (nonatomic, strong) dispatch_semaphore_t reuseTableViewSignal;

@property (nullable, nonatomic, strong) NSMutableSet<NSString *> *reuseCollectionViewControllers;
@property (nullable, nonatomic, strong) NSMutableDictionary<id<LDActiveReuseRoute>, void(^)(id<LDActiveReuseRoute> route, __kindof UIView *view)> *reuseCollectionViewDic;
@property (nonatomic, strong) dispatch_semaphore_t reuseCollectionViewSignal;

@property (nullable, nonatomic, strong) NSMutableSet<NSString *> *activeControllers;
@property (nonatomic, strong) dispatch_semaphore_t activeControllerSignal;
@end

@implementation LDActivePositioning

#pragma mark - load

+ (void)load
{
    @autoreleasepool {
        [LDActivePositioning share];
        
        SEL sel = @selector(viewDidLoad);
        SEL newSel = NSSelectorFromString([NSString stringWithFormat:@"LDP_hook_%@", NSStringFromSelector(sel)]);
        BOOL res = LDP_replaceMethodWithBlock([UIViewController class], sel, newSel, ^(__unsafe_unretained UIViewController *receiver) {
            [[LDActivePositioning share] hook_viewDidLoad:receiver];
            ((void ( *)(id, SEL))objc_msgSend)(receiver, newSel);
        });
        NSAssert(res, @"Failed Hook %@!", NSStringFromSelector(sel));
        
        sel = NSSelectorFromString(@"dealloc");
        newSel = NSSelectorFromString([NSString stringWithFormat:@"LDP_hook_%@", NSStringFromSelector(sel)]);
        res = LDP_replaceMethodWithBlock([UIViewController class], sel, newSel, ^(__unsafe_unretained UIViewController *receiver) {
            [[LDActivePositioning share] hook_dealloc:receiver];
            ((void ( *)(id, SEL))objc_msgSend)(receiver, newSel);
        });
        NSAssert(res, @"Failed Hook %@!", NSStringFromSelector(sel));
        
        sel = @selector(didMoveToWindow);
        newSel = NSSelectorFromString([NSString stringWithFormat:@"LDP_hook_%@", NSStringFromSelector(sel)]);
        res = LDP_replaceMethodWithBlock([UIView class], sel, newSel, ^(__unsafe_unretained UIView *receiver) {
            [[LDActivePositioning share] positioningUnreuseRoutesWithView:receiver];
            ((void ( *)(id, SEL))objc_msgSend)(receiver, newSel);
        });
        NSAssert(res, @"Failed Hook %@!", NSStringFromSelector(sel));
        
        sel = @selector(setDataSource:);
        newSel = NSSelectorFromString([NSString stringWithFormat:@"LDP_hook_uitableview_%@", NSStringFromSelector(sel)]);
        res = LDP_replaceMethodWithBlock([UITableView class], sel, newSel, ^(__unsafe_unretained UITableView *receiver, __unsafe_unretained id<UITableViewDataSource> dataSource) {
            SEL subSel = @selector(tableView:cellForRowAtIndexPath:);
            SEL subNewSel = NSSelectorFromString([NSString stringWithFormat:@"LDP_hook_%@", NSStringFromSelector(subSel)]);
            LDP_replaceMethodWithBlock([dataSource class], subSel, subNewSel, ^(__unsafe_unretained id receiver, __unsafe_unretained __kindof UITableView *tableView, __unsafe_unretained NSIndexPath *indexPath) {
                id returnValue = ((id ( *)(id, SEL, id, id))objc_msgSend)(receiver, subNewSel, tableView, indexPath);
                if ([returnValue isKindOfClass:[UITableViewCell class]]) {
                    [[LDActivePositioning share] positioningTableViewReuseRoutesWithCell:(UITableViewCell *)returnValue tableView:tableView indexPath:indexPath];
                }
                return  returnValue;
            });
            ((void ( *)(id, SEL, id))objc_msgSend)(receiver, newSel, dataSource);
        });
        NSAssert(res, @"Failed Hook %@!", NSStringFromSelector(sel));
        
        sel = @selector(setDataSource:);
        newSel = NSSelectorFromString([NSString stringWithFormat:@"LDP_hook_uicollectionview_%@", NSStringFromSelector(sel)]);
        res = LDP_replaceMethodWithBlock([UICollectionView class], sel, newSel, ^(__unsafe_unretained UICollectionView *receiver, __unsafe_unretained id<UICollectionViewDataSource> dataSource) {
            SEL subSel = @selector(collectionView:cellForItemAtIndexPath:);
            SEL subNewSel = NSSelectorFromString([NSString stringWithFormat:@"LDP_hook_%@", NSStringFromSelector(subSel)]);
            LDP_replaceMethodWithBlock([dataSource class], subSel, subNewSel, ^(__unsafe_unretained id receiver, __unsafe_unretained __kindof UICollectionView *collectionView, __unsafe_unretained NSIndexPath *indexPath) {
                id returnValue = ((id ( *)(id, SEL, id, id))objc_msgSend)(receiver, subNewSel, collectionView, indexPath);
                if ([returnValue isKindOfClass:[UICollectionViewCell class]]) {
                    [[LDActivePositioning share] positioningCollectionViewUnreuseRoutesWithCell:(UICollectionViewCell *)returnValue collectionView:collectionView indexPath:indexPath];
                }
                return  returnValue;
            });
            ((void ( *)(id, SEL, id))objc_msgSend)(receiver, newSel, dataSource);
        });
        NSAssert(res, @"Failed Hook %@!", NSStringFromSelector(sel));
    }
}

#pragma mark - init

+ (instancetype)share
{
    static LDActivePositioning *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LDActivePositioning alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _unreuseDic = [NSMutableDictionary dictionary];
        _unreuseControllers = [NSMutableSet set];
        _unreuseSignal = dispatch_semaphore_create(1);
        
        _reuseTableViewDic = [NSMutableDictionary dictionary];
        _reuseTableViewControllers = [NSMutableSet set];
        _reuseTableViewSignal = dispatch_semaphore_create(1);
        
        _reuseCollectionViewDic = [NSMutableDictionary dictionary];
        _reuseCollectionViewControllers = [NSMutableSet set];
        _reuseCollectionViewSignal = dispatch_semaphore_create(1);
        
        _activeControllers = [NSMutableSet set];
        _activeControllerSignal = dispatch_semaphore_create(1);
    }
    return self;
}

#pragma mark - UnreuseRoute

- (void)positioningUnreuseRoute:(id<LDActiveUnreuseRoute>)route hitTarget:(void (^)(id<LDActiveUnreuseRoute> route, __kindof UIView *view))target
{
    if (!route) {
        return;
    }
    
    dispatch_semaphore_wait(_unreuseSignal, DISPATCH_TIME_FOREVER);
    if (route.controllerName) {
        [self.unreuseControllers addObject:route.controllerName];
    }
    
    [self.unreuseDic setObject:[target copy] forKey:route];
    dispatch_semaphore_signal(_unreuseSignal);
}

- (void)positioningUnreuseRoutes:(NSSet<id<LDActiveUnreuseRoute>> *)routes hitTarget:(void (^)(id<LDActiveUnreuseRoute> route, __kindof UIView *view))target
{
    if (!routes) {
        return;
    }
    
    [routes enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id<LDActiveUnreuseRoute>  _Nonnull route, BOOL * _Nonnull stop) {
        dispatch_semaphore_wait(_unreuseSignal, DISPATCH_TIME_FOREVER);
        if (route.controllerName) {
            [self.unreuseControllers addObject:route.controllerName];
        }
        
        [self.unreuseDic setObject:[target copy] forKey:route];
        dispatch_semaphore_signal(_unreuseSignal);
    }];
}

- (void)stopPositioningUnreuseRoute:(id<LDActiveUnreuseRoute>)route
{
    if (!route) {
        return;
    }
    dispatch_semaphore_wait(_unreuseSignal, DISPATCH_TIME_FOREVER);
    if (route.controllerName) {
        [self.unreuseControllers removeObject:route.controllerName];
    }
    
    [self.unreuseDic removeObjectForKey:route];
    dispatch_semaphore_signal(_unreuseSignal);
}

- (void)stopPositioningAllUnreuseRoute
{
    dispatch_semaphore_wait(_unreuseSignal, DISPATCH_TIME_FOREVER);
    [self.unreuseControllers removeAllObjects];
    
    [self.unreuseDic removeAllObjects];
    dispatch_semaphore_signal(_unreuseSignal);
}

- (void)positioningUnreuseRoutesWithView:(__kindof UIView *)view
{
    dispatch_semaphore_wait(_unreuseSignal, DISPATCH_TIME_FOREVER);
    dispatch_semaphore_wait(_activeControllerSignal, DISPATCH_TIME_FOREVER);
    if (self.unreuseDic.count == 0 || ![self.unreuseControllers intersectsSet:self.activeControllers]) {
        dispatch_semaphore_signal(_activeControllerSignal);
        dispatch_semaphore_signal(_unreuseSignal);
        return;
    }
    dispatch_semaphore_signal(_activeControllerSignal);
    
    if (!view || !view.window) {
        return;
    }
    
    [self.unreuseDic enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id<LDActiveUnreuseRoute>  _Nonnull route, void (^ _Nonnull block)(id<LDActiveUnreuseRoute>, __kindof UIView *), BOOL * _Nonnull stop) {
        
        NSString *viewName = NSStringFromClass([view class]);
        if (![viewName isEqualToString:route.viewName]) {
            return;
        }
        
        NSString *controllerName = NSStringFromClass([[view ldp_nearViewController] class]);
        if (![controllerName isEqualToString:route.controllerName]) {
            return;
        }
        
        NSString *windowName = NSStringFromClass([view.window class]);
        if (![windowName isEqualToString:route.windowName]) {
            return;
        }
        
        BOOL result = [LDPositioningCommon isView:view equalToPaths:route.fromControllerViewPaths andDepths:route.fromControllerDepthPaths];
        
        if (result) {
            block(route, view);
            *stop = YES;
            return;
        }
    }];
    dispatch_semaphore_signal(_unreuseSignal);
}

#pragma mark - ReuseRoute

- (void)positioningReuseRoute:(id<LDActiveReuseRoute>)route hitTarget:(void (^)(id<LDActiveReuseRoute> route, __kindof UIView *view))target
{
    if (!route) {
        return;
    }
    
    switch (route.containerType) {
        case TableView:
            dispatch_semaphore_wait(_reuseTableViewSignal, DISPATCH_TIME_FOREVER);
            if (route.controllerName) {
                [self.reuseTableViewControllers addObject:route.controllerName];
            }
            
            [self.reuseTableViewDic setObject:[target copy] forKey:route];
            dispatch_semaphore_signal(_reuseTableViewSignal);
            break;
        case CollectionView:
            dispatch_semaphore_wait(_reuseCollectionViewSignal, DISPATCH_TIME_FOREVER);
            if (route.controllerName) {
                [self.reuseCollectionViewControllers addObject:route.controllerName];
            }
            
            [self.reuseCollectionViewDic setObject:[target copy] forKey:route];
            dispatch_semaphore_signal(_reuseCollectionViewSignal);
            break;
        default:
            break;
    }
}

- (void)positioningReuseRoutes:(NSSet<id<LDActiveReuseRoute>> *)routes hitTarget:(void (^)(id<LDActiveReuseRoute> route, __kindof UIView *view))target
{
    if (!routes) {
        return;
    }
    
    [routes enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id<LDActiveReuseRoute>  _Nonnull route, BOOL * _Nonnull stop) {
        switch (route.containerType) {
            case TableView:
                dispatch_semaphore_wait(_reuseTableViewSignal, DISPATCH_TIME_FOREVER);
                if (route.controllerName) {
                    [self.reuseTableViewControllers addObject:route.controllerName];
                }
                
                [self.reuseTableViewDic setObject:[target copy] forKey:route];
                dispatch_semaphore_signal(_reuseTableViewSignal);
                break;
            case CollectionView:
                dispatch_semaphore_wait(_reuseCollectionViewSignal, DISPATCH_TIME_FOREVER);
                if (route.controllerName) {
                    [self.reuseCollectionViewControllers addObject:route.controllerName];
                }
                
                [self.reuseCollectionViewDic setObject:[target copy] forKey:route];
                dispatch_semaphore_signal(_reuseCollectionViewSignal);
                break;
            default:
                break;
        }
    }];
}

- (void)stopPositioningReuseRoute:(id<LDActiveReuseRoute>)route
{
    if (!route) {
        return;
    }
    
    switch (route.containerType) {
        case TableView:
            dispatch_semaphore_wait(_reuseTableViewSignal, DISPATCH_TIME_FOREVER);
            if (route.controllerName) {
                [self.reuseTableViewControllers removeObject:route.controllerName];
            }
            
            [self.reuseTableViewDic removeObjectForKey:route];
            dispatch_semaphore_signal(_reuseTableViewSignal);
            break;
        case CollectionView:
            dispatch_semaphore_wait(_reuseCollectionViewSignal, DISPATCH_TIME_FOREVER);
            if (route.controllerName) {
                [self.reuseCollectionViewControllers removeObject:route.controllerName];
            }
            
            [self.reuseCollectionViewDic removeObjectForKey:route];
            dispatch_semaphore_signal(_reuseCollectionViewSignal);
            break;
        default:
            break;
    }
}

- (void)stopPositioningAllReuseRoute
{
    dispatch_semaphore_wait(_reuseTableViewSignal, DISPATCH_TIME_FOREVER);
    [self.reuseTableViewControllers removeAllObjects];
    [self.reuseTableViewDic removeAllObjects];
    dispatch_semaphore_signal(_reuseTableViewSignal);
    
    dispatch_semaphore_wait(_reuseCollectionViewSignal, DISPATCH_TIME_FOREVER);
    [self.reuseCollectionViewControllers removeAllObjects];
    [self.reuseCollectionViewDic removeAllObjects];
    dispatch_semaphore_signal(_reuseCollectionViewSignal);
}

#pragma mark TableView

- (void)positioningTableViewReuseRoutesWithCell:(__kindof UITableViewCell *)cell tableView:(__kindof UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    dispatch_semaphore_wait(_reuseTableViewSignal, DISPATCH_TIME_FOREVER);
    dispatch_semaphore_wait(_activeControllerSignal, DISPATCH_TIME_FOREVER);
    if (self.reuseTableViewDic.count == 0 || ![self.reuseTableViewControllers intersectsSet:self.activeControllers]) {
        dispatch_semaphore_signal(_activeControllerSignal);
        dispatch_semaphore_signal(_reuseTableViewSignal);
        return;
    }
    dispatch_semaphore_signal(_activeControllerSignal);
    
    if (!cell || !tableView || !indexPath) {
        return;
    }
    
    [self.reuseTableViewDic enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id<LDActiveReuseRoute>  _Nonnull route,  void (^ _Nonnull block)(id<LDActiveReuseRoute>, __kindof UIView *), BOOL * _Nonnull stop) {
        NSString *cellName = NSStringFromClass([cell class]);
        if (![cellName isEqualToString:route.reuseViewName]) {
            return;
        }
        
        NSString *tableViewName = NSStringFromClass([tableView class]);
        if (![tableViewName isEqualToString:route.reuseContainerName]) {
            return;
        }
        
        //如果传了indexPath，但不匹配，就return。如果没传indexPath，则视为需要匹配一类
        if (route.indexPath && (indexPath.section != route.indexPath.section || indexPath.row != route.indexPath.row)) {
            return;
        }
        
        NSString *controllerName = NSStringFromClass([[tableView ldp_nearViewController] class]);
        if (![controllerName isEqualToString:route.controllerName]) {
            return;
        }
        
        BOOL rseult = [LDPositioningCommon isView:tableView equalToPaths:route.fromControllerViewPaths andDepths:route.fromControllerDepthPaths];
        
        if (rseult) {
            UIView *view = [LDPositioningCommon findTargetWithRootView:cell paths:route.fromReuseViewPaths indexs:route.fromReuseViewIndexPaths];
            
            if (view) {
                block(route, view);
                *stop = YES;
                return;
            }
        }
    }];
    dispatch_semaphore_signal(_reuseTableViewSignal);
}

#pragma mark CollectionView

- (void)positioningCollectionViewUnreuseRoutesWithCell:(__kindof UICollectionViewCell *)cell collectionView:(__kindof UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath
{
    dispatch_semaphore_wait(_reuseCollectionViewSignal, DISPATCH_TIME_FOREVER);
    dispatch_semaphore_wait(_activeControllerSignal, DISPATCH_TIME_FOREVER);
    //有需要匹配的路径，且route.Controller和存在的Controller有重叠
    if (self.reuseCollectionViewDic.count == 0 || ![self.reuseCollectionViewControllers intersectsSet:self.activeControllers]) {
        dispatch_semaphore_signal(_activeControllerSignal);
        dispatch_semaphore_signal(_reuseCollectionViewSignal);
        return;
    }
    dispatch_semaphore_signal(_activeControllerSignal);
    
    if (!cell || !collectionView || !indexPath) {
        return;
    }
    
    [self.reuseCollectionViewDic enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id<LDActiveReuseRoute>  _Nonnull route, void (^ _Nonnull block)(id<LDActiveReuseRoute>, __kindof UIView *), BOOL * _Nonnull stop) {
        NSString *cellName = NSStringFromClass([cell class]);
        if (![cellName isEqualToString:route.reuseViewName]) {
            return;
        }
        
        NSString *collectionViewName = NSStringFromClass([collectionView class]);
        if (![collectionViewName isEqualToString:route.reuseContainerName]) {
            return;
        }
        
        //如果传了indexPath，但不匹配，就return。如果没传indexPath，则视为需要匹配一类
        if (route.indexPath && (indexPath.section != route.indexPath.section || indexPath.row != route.indexPath.row)) {
            return;
        }
        
        NSString *controllerName = NSStringFromClass([[collectionView ldp_nearViewController] class]);
        if (![controllerName isEqualToString:route.controllerName]) {
            return;
        }
        
        BOOL rseult = [LDPositioningCommon isView:collectionView equalToPaths:route.fromControllerViewPaths andDepths:route.fromControllerDepthPaths];
        
        if (rseult) {
            UIView *view = [LDPositioningCommon findTargetWithRootView:cell paths:route.fromReuseViewPaths indexs:route.fromReuseViewIndexPaths];
            
            if (view) {
                block(route, view);
                *stop = YES;
                return;
            }
        }
    }];
    dispatch_semaphore_signal(_reuseCollectionViewSignal);
}

#pragma mark - UIViewController hook

- (void)hook_viewDidLoad:(__kindof UIViewController *)viewController
{
    if (!viewController) {
        return;
    }
    dispatch_semaphore_wait(_activeControllerSignal, DISPATCH_TIME_FOREVER);
    [self.activeControllers addObject:NSStringFromClass(viewController.class)];
    dispatch_semaphore_signal(_activeControllerSignal);
}

- (void)hook_dealloc:(__kindof UIViewController *)viewController
{
    if (!viewController) {
        return;
    }
    dispatch_semaphore_wait(_activeControllerSignal, dispatch_semaphore_signal(_activeControllerSignal));
    [self.activeControllers removeObject:NSStringFromClass(viewController.class)];
    dispatch_semaphore_signal(_activeControllerSignal);
}

@end
