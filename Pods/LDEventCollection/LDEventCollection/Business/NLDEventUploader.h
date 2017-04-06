//
//  NLDEventUploader.h
//  LDEventCollection
//
//  Created by SongLi on 5/26/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NLDEventCache;
@interface NLDEventUploader : NSObject

@property (nonatomic, weak, readonly) NLDEventCache *eventCache;

- (nullable instancetype)initWithEventCache:(nonnull NLDEventCache *)eventCache domain:(nonnull NSString *)domain NS_DESIGNATED_INITIALIZER;

/**
 *  开始运行，每攒够duration秒上传一次
 */
- (void)startUploadWithDuration:(CGFloat)duration;

/**
 *  开始运行，每攒够bufSize条上传一次（cache监听）
 */
- (void)startUploadWithBufferSize:(NSUInteger)bufSize;

/**
 *  程序进入后台时，调用此方法，触发本地文件上传
 */
- (void)uploadAllEventsOnBackground;

/**
 *  将本地保存的文件逐个上传
 */
- (void)uploadLocalFiles;

/**
 *  停止运行（当前正在上传的操作不会停止）
 */
- (void)stop;

/**
 *  在冷启动时触发一次，如果cache中有事件可upload，立即执行一次upload（所有事件）
 */
- (void)uploadIfNeeded;

@end

NS_ASSUME_NONNULL_END
