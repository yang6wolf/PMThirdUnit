//
//  LDPassiveRoute.h
//  Pods
//
//  Created by wuxu on 16/5/20.
//
//

#ifndef LDPassiveRoute_h
#define LDPassiveRoute_h

NS_ASSUME_NONNULL_BEGIN

@protocol LDPassiveRoute <NSObject>

@required

@property (nonatomic, copy) NSString *viewName;
@property (nonatomic, copy) NSString *controllerName;
@property (nonatomic, copy) NSString *windowName;

@property (nonatomic, copy) NSArray<NSString *> *fromControllerViewPaths;
@property (nonatomic, copy) NSArray<NSString *> *fromControllerDepthPaths;

@end

NS_ASSUME_NONNULL_END

#endif /* LDPassiveRoute_h */
