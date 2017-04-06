//
//  NLDEventCache.m
//  LDEventCollection
//
//  Created by SongLi on 6/1/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import "NLDEventCache.h"
#import "NLDDataEntity.h"
#import "NSMutableDictionary+NLDUUID.h"
#import "NLDEventSerializerProtocol.h"
#import "NLDEventJsonSerializer.h"
#import <objc/message.h>
#import "NLDEventCollectionManager.h"

NSUInteger const NLDMaxEventCountLimit = 2000;
NSUInteger const NLDMaxLocalFileCountLimit = 500;

@protocol NLDEvent;
@interface NLDEventCache ()
@property (nonatomic, strong) dispatch_queue_t queue;
/// 序列化工具
@property (nonatomic, strong) id <NLDEventSerializer> serializer;
/// 事件监听者列表
@property (nonatomic, strong) NSMapTable *eventObserverMap;
/// 缓存列表
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *eventArray;
/// 读出列表
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSArray<NSDictionary *> *> *poppedEventDict;

@property (nonatomic, strong) dispatch_semaphore_t observerMapSignal;
@end

@implementation NLDEventCache

- (instancetype)init
{
    return [self initWithSerializer:nil];
}

- (instancetype)initWithSerializer:(nullable id<NLDEventSerializer>)serializer
{
    self = [super init];
    if (self) {
        _queue = dispatch_queue_create(NSStringFromClass(self.class).UTF8String, DISPATCH_QUEUE_SERIAL);
        _eventObserverMap = [[NSMapTable alloc] initWithKeyOptions:NSMapTableWeakMemory valueOptions:NSMapTableCopyIn capacity:1];
        _eventArray = [NSMutableArray arrayWithCapacity:50];
        _poppedEventDict = [NSMutableDictionary dictionaryWithCapacity:5];
        _serializer = serializer ?: [[NLDEventJsonSerializer alloc] init];
        _observerMapSignal = dispatch_semaphore_create(1);
        
        // 不再恢复至内存中，直接从文件读取数据并上传
//        [self restoreCache];
        
        // 发生crash时执行本地保存
        Class cls = [self class];
        SEL sel = NSSelectorFromString(@"NLD_swizzForAppTerminate");
        if ([(id)cls respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [(id)cls performSelector:sel];
#pragma clang diagnostic pop
        }

    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addEventObserver:(id)observer executeBlock:(void(^)(NSUInteger eventCount))block;
{
    dispatch_semaphore_wait(_observerMapSignal, DISPATCH_TIME_FOREVER);
    [_eventObserverMap setObject:block forKey:observer];
    dispatch_semaphore_signal(_observerMapSignal);
}

- (void)removeEventObserver:(id)observer
{
    dispatch_semaphore_wait(_observerMapSignal, DISPATCH_TIME_FOREVER);
    [_eventObserverMap removeObjectForKey:observer];
    dispatch_semaphore_signal(_observerMapSignal);
}

- (void)addEvent:(NLDDataEntity<NLDEvent> *)event
{
    dispatch_async(_queue, ^{
        // 限制eventArray存储不超过 2000 条事件信息
        // 超出限制，则移除最早加入的事件信息
        if (_eventArray.count >= NLDMaxEventCountLimit) {
            [_eventArray removeObjectAtIndex:0];
        }
        [_eventArray addObject:[event toDictionary]];
        [self notifyObservers];
    });
}

- (void)popAllEventsCompletion:(CompletionHandler)completion;
{
    dispatch_async(_queue, ^{
        if (_eventArray.count == 0) {
            return;
        }
        
        NSArray *array = _eventArray.copy;
        [_eventArray removeAllObjects];
        NSString *uuid = [_poppedEventDict NLD_setObjectOrNilForRandomUUID:array];
        NSData *eventsData = [_serializer dataWithObjects:array];
        !completion ?: completion(eventsData, uuid);
    });
}

- (void)popEventsToIndex:(NSUInteger)toIndex completion:(CompletionHandler)completion
{
    dispatch_async(_queue, ^{
        NSUInteger length = MIN(toIndex, _eventArray.count);
        if (length == 0) {
            return;
        }
        
        NSRange popRange = NSMakeRange(0, length);
        NSArray *array = [_eventArray subarrayWithRange:popRange];
        [_eventArray removeObjectsInRange:popRange];
        NSString *uuid = [_poppedEventDict NLD_setObjectOrNilForRandomUUID:array];
        NSData *eventsData = [_serializer dataWithObjects:array];
        !completion ?: completion(eventsData, uuid);
    });
}

- (void)popLocalFileCompletion:(CompletionHandler)completion
{
    dispatch_async(_queue, ^{
        NSArray<NSString *> *filePaths = [[NSFileManager defaultManager] subpathsAtPath:[self eventLogDirectory]];
        for (NSString *identifier in filePaths) {
            if ([identifier.pathExtension isEqualToString:@"cache"]) {
                NSString *fullPath = [[self eventLogDirectory] stringByAppendingPathComponent:identifier];
                NSArray<NSDictionary *> *array = [NSArray arrayWithContentsOfFile:fullPath];
                NSData *eventsData = [_serializer dataWithObjects:array];
                !completion ?: completion(eventsData, identifier.stringByDeletingPathExtension);
                return;
            }
        }
        !completion ?: completion(nil, nil);
    });
}

- (void)cleanPoppedEventForIdentifier:(nonnull NSString *)identifier
{
    dispatch_async(_queue, ^{
        [_poppedEventDict removeObjectForKey:identifier];
        
        NSString *diskPath = [NSString stringWithFormat:@"%@/%@.cache", [self eventLogDirectory], identifier];
        if ([[NSFileManager defaultManager] fileExistsAtPath:diskPath]) {
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:diskPath error:&error];
            if (error) {
                [[NLDEventCollectionManager sharedManager] addEventName:@"RemoveLocalFileFailed" withParams:@{@"error":error}];
            }
        }
        
    });
}

- (void)failedProcessPoppedEventForIdentifier:(nonnull NSString *)identifier withError:(NSError *)error
{
    dispatch_async(_queue, ^{
        NSArray<NSDictionary *> *array = _poppedEventDict[identifier];
        if (array) {
            NSString *cachePath = [NSString stringWithFormat:@"%@/%@.cache", [self eventLogDirectory], identifier];
            BOOL success = [array writeToFile:cachePath atomically:YES];
            if (success) {
                [_poppedEventDict removeObjectForKey:identifier];
                [self removeLocalFileIfNeeded];
            }
        }
        
        /* 不再添加至内存中
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, array.count)];
        [_eventArray insertObjects:array atIndexes:indexSet];
         */
//        [self notifyObservers];   // 在数据上传失败之后，直接加入到 _eventArray 中，不再通知监听者，以防当前无网络的情况下重复循环执行无效代码
    });
}

- (void)quickSave
{
    __weak typeof(self) weakSelf = self;
    [self popAllEventsCompletion:^(NSData * _Nullable eventsData, NSString * _Nullable identifier) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        // 保存数据至本地文件
        NSDictionary *tempDic = [_poppedEventDict copy];
        [tempDic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSArray<NSDictionary *> * _Nonnull obj, BOOL * _Nonnull stop) {
            [strongSelf removeLocalFileIfNeeded];
            
            NSString *cachePath = [NSString stringWithFormat:@"%@/%@.cache", [strongSelf eventLogDirectory], key];
            BOOL success = [obj writeToFile:cachePath atomically:YES];
            if (!success) {
                [[NLDEventCollectionManager sharedManager] addEventName:@"WriteToFileFailed" withParams:@{@"identifier": key}];
            }
        }];
        [_poppedEventDict removeAllObjects];
    }];
}

#pragma mark - Private Methods

- (nullable NSString *)seekFirstCreateFile
{
    NSArray<NSString *> *filePaths = [[NSFileManager defaultManager] subpathsAtPath:[self eventLogDirectory]];
    if (filePaths.count < NLDMaxLocalFileCountLimit) {
        return nil;
    }
    NSString *firstCreateFile = nil;
    NSDate *firstCreateDate = nil;
    for (NSString *identifier in filePaths) {
        if ([identifier.pathExtension isEqualToString:@"cache"]) {
            NSString *fullPath = [[self eventLogDirectory] stringByAppendingPathComponent:identifier];
            NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:nil];
            if (fileAttributes) {
                NSDate *fileCreateDate = [fileAttributes objectForKey:NSFileCreationDate];
                if (firstCreateDate) {
                    if ([firstCreateDate compare:fileCreateDate] == NSOrderedDescending) {
                        firstCreateDate = fileCreateDate;
                        firstCreateFile = identifier;
                    }
                } else {
                    firstCreateDate = fileCreateDate;
                    firstCreateFile = identifier;
                }
            }
        }
    }
    
    return firstCreateFile;
}

- (void)removeLocalFileIfNeeded
{
    NSString *firstCreateFile = [self seekFirstCreateFile];
    if (firstCreateFile) {
        NSString *diskPath = [NSString stringWithFormat:@"%@/%@", [self eventLogDirectory], firstCreateFile];
        [[NSFileManager defaultManager] removeItemAtPath:diskPath error:nil];
        [[NLDEventCollectionManager sharedManager] addEventName:@"ReachMaxFileLimit" withParams:@{@"identifier":firstCreateFile}];
    }
}


- (void)notifyObservers
{
    dispatch_semaphore_wait(_observerMapSignal, DISPATCH_TIME_FOREVER);
        NSEnumerator *enumerator = _eventObserverMap.objectEnumerator;
        while (YES) {
            void(^block)(NSUInteger eventCount) = enumerator.nextObject;
            if (block) { block(_eventArray.count); }
            else { break; }
        }
    dispatch_semaphore_signal(_observerMapSignal);
}

- (void)restoreCache
{
    dispatch_async(_queue, ^{
        // 已读出但未完成上传的添加到_eventArray等待下一次上传，未读出的添加到_eventArray等待下一次上传
        [[[NSFileManager defaultManager] subpathsAtPath:[self eventLogDirectory]] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.pathExtension isEqualToString:@"cache"]) {
                NSString *fullPath = [[self eventLogDirectory] stringByAppendingPathComponent:obj];
                NSArray<NSDictionary *> *array = [NSArray arrayWithContentsOfFile:fullPath];
                if (array.count > 0) {
                    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, array.count)];
                    [_eventArray insertObjects:array atIndexes:indexSet];
                }
            }
        }];
        [[NSFileManager defaultManager] removeItemAtPath:[self eventLogDirectory] error:NULL];
        [self notifyObservers];
    });
}


#pragma mark - Helper

- (NSString *)eventLogDirectory
{
    static NSString *eventLogDirectory;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        eventLogDirectory = [documentsDirectory stringByAppendingPathComponent:@"NLDEventLog"];
    });
    if (![[NSFileManager defaultManager] fileExistsAtPath:eventLogDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:eventLogDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    return eventLogDirectory;
}

@end
