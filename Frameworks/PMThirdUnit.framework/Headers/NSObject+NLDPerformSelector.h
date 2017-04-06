//
//  NSObject+NLDPerformSelector.h
//  Pods
//
//  Created by 高振伟 on 16/6/22.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (NLDPerformSelector)

- (BOOL)invokeSelector:(SEL)aSelector withArguments:(nullable NSArray *)arguments;
- (BOOL)invokeSelector:(SEL)aSelector withArguments:(nullable NSArray *)arguments retureValue:(nullable void *)res;
- (nullable NSObject *)objectOrNull;

- (void)setAdditionalData:(nullable NSDictionary<NSString *, NSString *> *)data;
- (nullable NSDictionary<NSString *, NSString *> *)additionalData;

@end

@interface NSObject (KVCException)

- (nullable id)valueForUndefinedKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
