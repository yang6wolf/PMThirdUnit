//
//  NLDEventUploader.m
//  LDEventCollection
//
//  Created by SongLi on 5/26/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import "NLDEventUploader.h"
#import "NLDEventCache.h"
#import "NSTimer+NLDBlock.h"
#import "NLDMacroDef.h"

#define MAX_RETRY_COUNT 5

@interface NLDEventUploader() <NSURLSessionDelegate>
@property (nonatomic, strong) NSTimer *uploadTimer;
@property (nonatomic, strong) dispatch_queue_t dataQueue;
@property (nonatomic, strong) dispatch_queue_t fileQueue;
@property (nonatomic, strong) dispatch_queue_t waitQueue;
@property (nonatomic, strong) dispatch_semaphore_t maxConcurrentSignal;
@property (nonatomic, weak) NLDEventCache *eventCache;
@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic, assign) BOOL isStarted;
@property (nonatomic, assign) NSUInteger bufferSize;
@property (nonatomic, assign) UIBackgroundTaskIdentifier taskIdentifier;
@property (nonatomic, copy) NSString *eventUploadDomain;
@property (nonatomic, assign, getter=isFileUploading) BOOL fileUploading;
@property (nonatomic, assign) NSUInteger retryCount;
@end


@implementation NLDEventUploader

- (instancetype)init
{
    NLDEventCache *nilCache;
    return [self initWithEventCache:nilCache domain:@"http://adc.163.com/"];
}

- (nullable instancetype)initWithEventCache:(nonnull NLDEventCache *)eventCache domain:(nonnull NSString *)domain
{
    NSParameterAssert(eventCache);
    if (!eventCache) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        _eventCache = eventCache;
        _dataQueue = dispatch_queue_create("NLDEventUploader_dataQueue", DISPATCH_QUEUE_CONCURRENT);
        _fileQueue = dispatch_queue_create("NLDEventUploader_fileQueue", DISPATCH_QUEUE_SERIAL);
        _waitQueue = dispatch_queue_create("NLDEventUploader_waitQueue", DISPATCH_QUEUE_SERIAL);
        _maxConcurrentSignal = dispatch_semaphore_create(15);
        _urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        _eventUploadDomain = domain;
        _taskIdentifier = UIBackgroundTaskInvalid;
        _retryCount = 0;
    }
    return self;
}

- (void)startUploadWithBufferSize:(NSUInteger)bufSize
{
    if (bufSize <= 0) {
        return;
    }
    
    // 由于不会重复调用 startUploadWithBufferSize：、startUploadWithDuration：方法，所以无需再调用此方法
//    [self stop];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _bufferSize = bufSize;
        __weak typeof(self) weakSelf = self;
        [_eventCache addEventObserver:self executeBlock:^(NSUInteger eventCount) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            for (NSInteger idx = 0; idx < eventCount/_bufferSize; idx++) {
                [strongSelf uploadBuffer];
            }
        }];
    });
}

- (void)startUploadWithDuration:(CGFloat)duration
{
    if (duration <= 0) {
        return;
    }
    
    if ([_uploadTimer isValid] && _uploadTimer.timeInterval == duration) {
        return;
    }
    
    // 由于不会重复调用 startUploadWithBufferSize：、startUploadWithDuration：方法，所以无需再调用此方法
//    [self stop];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        __weak typeof(self) weakSelf = self;
        _uploadTimer = [NSTimer NLD_timerWithTimeInterval:duration repeats:YES executeBlock:^(NSTimer *timer) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf uploadIfNeeded];
        }];
        [[NSRunLoop mainRunLoop] addTimer:self.uploadTimer forMode:NSRunLoopCommonModes];
        [_uploadTimer fire];
    });
}

- (void)uploadAllEventsOnBackground
{
    // 开启后台任务
    self.taskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        if (self) {
            [[UIApplication sharedApplication] endBackgroundTask:self.taskIdentifier];
            self.taskIdentifier = UIBackgroundTaskInvalid;
        }
    }];
    
    // 执行内存数据的保存至本地文件
    [_eventCache quickSave];
    
    // 触发本地文件的上传
    [self uploadLocalFiles];
    
        
        /* 进入前台时再上传
        dispatch_async(strongSelf.queue, ^{
            // 开启后台任务
            strongSelf.taskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                if (strongSelf) {
                    [[UIApplication sharedApplication] endBackgroundTask:strongSelf.taskIdentifier];
                    strongSelf.taskIdentifier = UIBackgroundTaskInvalid;
                }
            }];
            [strongSelf uploadEventsData:eventsData succeed:^{
                [strongSelf.eventCache cleanPoppedEventForIdentifier:identifier];
            } failed:^(NSError *error) {
                [strongSelf.eventCache failedProcessPoppedEventForIdentifier:identifier withError:error];
            }];
        });
         */
}

- (void)uploadLocalFiles
{
    dispatch_async(self.fileQueue, ^{
        _retryCount = 0;
        if (self.isFileUploading) return;
        [self uploadFile];
    });
}

- (void)stop
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_uploadTimer) {
            [_uploadTimer invalidate];
            _uploadTimer = nil;
        }
        
        if (_bufferSize > 0) {
            _bufferSize = 0;
            [_eventCache removeEventObserver:self];
        }
    });
}

- (void)uploadIfNeeded
{
    __weak typeof(self) weakSelf = self;
    [_eventCache popAllEventsCompletion:^(NSData * _Nullable eventsData, NSString * _Nullable identifier) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        dispatch_async(strongSelf.waitQueue, ^{
            dispatch_semaphore_wait(strongSelf.maxConcurrentSignal, DISPATCH_TIME_FOREVER);
            dispatch_async(strongSelf.dataQueue, ^{
                [strongSelf uploadEventsData:eventsData succeed:^{
                    [strongSelf.eventCache cleanPoppedEventForIdentifier:identifier];
                    dispatch_semaphore_signal(strongSelf.maxConcurrentSignal);
                } failed:^(NSError *error) {
                    [strongSelf.eventCache failedProcessPoppedEventForIdentifier:identifier withError:error];
                    dispatch_semaphore_signal(strongSelf.maxConcurrentSignal);
                }];
            });
        });
    }];
}

#pragma mark - Private Methods

- (void)uploadBuffer
{
    __weak typeof(self) weakSelf = self;
    [_eventCache popEventsToIndex:_bufferSize completion:^(NSData * _Nullable eventsData, NSString * _Nullable identifier) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        dispatch_async(strongSelf.waitQueue, ^{
            dispatch_semaphore_wait(strongSelf.maxConcurrentSignal, DISPATCH_TIME_FOREVER);
            dispatch_async(strongSelf.dataQueue, ^{
                [strongSelf uploadEventsData:eventsData succeed:^{
                    [strongSelf.eventCache cleanPoppedEventForIdentifier:identifier];
                    dispatch_semaphore_signal(strongSelf.maxConcurrentSignal);
                } failed:^(NSError *error) {
                    [strongSelf.eventCache failedProcessPoppedEventForIdentifier:identifier withError:error];
                    dispatch_semaphore_signal(strongSelf.maxConcurrentSignal);
                }];
            });
        });
    }];
}

- (void)uploadFile
{
    __weak typeof(self) weakSelf = self;
    [_eventCache popLocalFileCompletion:^(NSData * _Nullable eventsData, NSString * _Nullable identifier) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        dispatch_async(strongSelf.fileQueue, ^{
            if (!eventsData || _retryCount > MAX_RETRY_COUNT) {
                strongSelf.fileUploading = NO;
                if (strongSelf.taskIdentifier != UIBackgroundTaskInvalid) {
                    [strongSelf completeBackgroundTask];
                }
                return;
            }
            [strongSelf uploadEventsData:eventsData succeed:^{
                [strongSelf.eventCache cleanPoppedEventForIdentifier:identifier];
                dispatch_async(strongSelf.fileQueue, ^{
                    [strongSelf uploadFile];
                    _retryCount = 0;
                });
            } failed:^(NSError *error) {
                [strongSelf.eventCache failedProcessPoppedEventForIdentifier:identifier withError:error];
                dispatch_async(strongSelf.fileQueue, ^{
                    [strongSelf uploadFile];
                    _retryCount++;
                });
            }];
        });
    }];
}

- (void)uploadEventsData:(nonnull NSData *)data succeed:(nonnull void(^)(void))succeed failed:(nullable void(^)(NSError *error))failed
{
//    NSString *urlStr = @"http://adc.163.com/1/log_protobuf";
    NSString *urlStr = [NSString stringWithFormat:@"%@1/log_protobuf", _eventUploadDomain];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
    [request setValue:[NSString stringWithFormat:@"application/x-google-protobuf"] forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
//    __weak typeof(self) weakSelf = self;
    [[_urlSession uploadTaskWithRequest:request fromData:data completionHandler:^(NSData * _Nullable responseData, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            !failed ?: failed(error);
        } else {
            !succeed ?: succeed();
        }
        /* 不再开启后台上传任务
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.taskIdentifier != UIBackgroundTaskInvalid) {
            [strongSelf completeBackgroundTask];
        }
         */
        
        LDECLog(@"responsedata: %@ \n error: %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding], error);
    }] resume];
}

- (void)completeBackgroundTask
{
    [[UIApplication sharedApplication] endBackgroundTask:self.taskIdentifier];
    self.taskIdentifier = UIBackgroundTaskInvalid;
}

@end
