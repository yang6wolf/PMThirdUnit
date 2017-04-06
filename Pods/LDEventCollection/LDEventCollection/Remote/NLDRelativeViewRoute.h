//
//  NLDRelativeViewRoute.h
//  Pods
//
//  Created by 高振伟 on 16/8/13.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NLDRelativeViewType)
{
    NLDRelativeViewUnreuseType = 0,
    NLDRelativeViewReuseType = 1
};

@protocol NLDRelativeViewRoute <NSObject>

@property (nonatomic, readonly, assign) NLDRelativeViewType relativeViewType;
@property (nonatomic, readonly, copy) NSString *relativeViewPropertyPath;  // 用于通过kvc获取数据
@property (nonatomic, readonly, copy) NSString *relativeViewKey;           // 传递给后台数据时的key

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
