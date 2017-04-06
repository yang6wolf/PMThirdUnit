//
//  NLDRemoteEventModel.h
//  Pods
//
//  Created by 高振伟 on 16/8/8.
//
//

#import <Foundation/Foundation.h>

@class NLDTargetViewRoute;
@protocol NLDRelativeViewRoute;

NS_ASSUME_NONNULL_BEGIN

@interface NLDRemoteEventModel : NSObject

@property (nonatomic, strong) NLDTargetViewRoute   *targetViewRoute;
@property (nonatomic, strong) id<NLDRelativeViewRoute> relativeViewRoute;

@property (nonatomic, weak, nullable) UIView *targetView;    // 如果 weak 引用造成crash，就改成 unsafe_unretained
@property (nonatomic, weak, nullable) UIView *relativeView;  // 有可能这个view已经被释放了，如果为nil，则重新去字典里获取

@property (nonatomic, copy) NSString *targetViewIndexPath;  // 如果有则记录对应的indexPath

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
