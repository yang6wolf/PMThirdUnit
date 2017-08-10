//
//  LDGeminiSDK+Helper.h
//  Pods
//
//  Created by wangkaird on 2016/12/29.
//
//

#import "LDGeminiSDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface LDGeminiSDK (Helper)

/**
 *  @brief  在SDK的本地Cache中，查询caseId对应的Flag，Cache为空。
 *
 *  @param  name        需要查询flag的caseId在LDGeminiHelper中的name
 *  @param  defaultFlag 默认的Flag，当caseId查找不到对应的flag、或者caseId不合法时，返回该值
 *
 *  @return 返回caseId对应的flag值，如果查找失败，则返回默认值
 */
+ (id)getFlagWithName:(NSString *)name defaultFlag:(id)defaultFlag;

/**
 *  @brief  从服务器异步查询caseId对应的flag。这个方法会从服务器异步获取case列表，并更新到SDK的Cache中，然后通过回调返回查询结果。
 *
 *  @param  name        需要查询flag的caseId在LDGeminiHelper中的name
 *  @param  defaultFlag 默认的Flag，当caseId查找不到对应的flag、或者caseId不合法时，返回该值
 *  @param  handler     查询到结果之后的回调block。！！注意：handler为nil时，这个方法不会执行任何动作
 */
+ (void)asyncGetFlagWithName:(NSString *)name defaultFlag:(id)defaultFlag handler:(LDGeminiAsyncGetHandler)handler;

/**
 *  @brief  从服务器同步查询caseId对应的flag。这个方法会从服务器同步获取case列表，并更新到SDK的Cache中，然后返回查询结果。
 *
 *  @param  name        需要查询flag的caseId在LDGeminiHelper中的name
 *  @param  defaultFlag 默认的Flag，当caseId查找不到对应的flag、或者caseId不合法时，返回该值
 *  @param  timeout     同步请求操作的超时时间，单位为毫秒(ms, 1s = 1000ms)
 *  @param  error       用于返回请求过程中出现的错误
 *
 *  @return 返回caseId对应的flag值，如果查找失败，则返回默认值
 */
+ (id)syncGetFlagWithName:(NSString *)name defaultFlag:(id)defaultFlag timeout:(NSTimeInterval)timeout error:(NSError * _Nullable __autoreleasing *)error;

@end

NS_ASSUME_NONNULL_END
