//
//  LDActiveReuseRoute.h
//  Pods
//
//  Created by wuxu on 16/5/20.
//
//

#ifndef LDActiveReuseRoute_h
#define LDActiveReuseRoute_h

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, LDContainerType) {
    TableView,
    CollectionView,
};

@protocol LDActiveReuseRoute <NSObject, NSCopying>

@required

@property (nonatomic, copy) NSString *viewName;
@property (nonatomic, copy) NSString *reuseViewName; // like cell
@property (nonatomic, copy) NSString *reuseContainerName; // like tableView、collectionView
@property (nonatomic, assign) LDContainerType containerType;
@property (nullable, nonatomic, copy) NSIndexPath *indexPath; // nil when want to find similar views
@property (nonatomic, copy) NSString *controllerName;

@property (nonatomic, copy) NSArray<NSString *> *fromControllerViewPaths;
@property (nonatomic, copy) NSArray<NSString *> *fromControllerDepthPaths;

@property (nonatomic, copy) NSArray<NSString *> *fromReuseViewPaths;
@property (nonatomic, copy) NSArray<NSString *> *fromReuseViewIndexPaths;

@end

NS_ASSUME_NONNULL_END

#endif /* LDActiveReuseRoute_h */
