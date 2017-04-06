//
//  NLDEventCache.h
//  LDEventCollection
//
//  Created by SongLi on 6/1/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NLDDataEntity;
@protocol NLDEvent;
@protocol NLDEventSerializer;

typedef void(^CompletionHandler)(NSData * _Nullable eventsData, NSString * _Nullable identifier);

@interface NLDEventCache : NSObject

/**
 *  指定的初始化方法
 *  @param  serializer  序列化工具，传nil默认使用NLDEventJsonSerializer。
 *                      序列化方案影响popEvent方法的block参数中传递的NSData内容格式。
 */
- (instancetype)initWithSerializer:(nullable id<NLDEventSerializer>)serializer NS_DESIGNATED_INITIALIZER;

/**
 *  监听event数量变化
 */
- (void)addEventObserver:(id)observer executeBlock:(void(^)(NSUInteger eventCount))block;

/**
 *  放弃监听event数量变化
 */
- (void)removeEventObserver:(id)observer;

/**
 *  缓存事件
 */
- (void)addEvent:(NLDDataEntity<NLDEvent> *)event;

/**
 *  读取所有缓存的事件，被读出的事件暂时存放在读出列表中。该方法线程安全，后一个调用会在前一个调用结束后执行。
 *  @param  eventsData  根据serializer序列化之后的数据
 *
 *  @warning    pop之后需要调用cleanPoppedEventForIdentifier:或failedProcessPoppedEventForIdentifier:withError:方法，否则读出的内容会在程序再次启动时被再次写入cache。
 */
- (void)popAllEventsCompletion:(CompletionHandler)completion;

/**
 *  读取指定缓存区的事件，被读出的事件暂时存放在读出列表中。该方法线程安全，后一个调用会在前一个调用结束后执行。
 *  @param  eventsData  根据serializer序列化之后的数据
 *
 *  @warning    pop之后需要调用cleanPoppedEventForIdentifier:或failedProcessPoppedEventForIdentifier:withError:方法，否则读出的内容会在程序再次启动时被再次写入cache。
 */
- (void)popEventsToIndex:(NSUInteger)toIndex completion:(CompletionHandler)completion;

/**
 *  读取disk中存储的文件数据
 *  @param  eventsData  根据serializer序列化之后的数据
 */
- (void)popLocalFileCompletion:(CompletionHandler)completion;

/**
 *  处理读出列表的数据：成功，清除数据
 */
- (void)cleanPoppedEventForIdentifier:(NSString *)identifier;

/**
 *  处理读出列表的数据：失败，保存至本地
 */
- (void)failedProcessPoppedEventForIdentifier:(NSString *)identifier withError:(NSError *)error;

/**
 *  将内存中的数据全部存至本地文件中
 */
- (void)quickSave;

@end

NS_ASSUME_NONNULL_END
