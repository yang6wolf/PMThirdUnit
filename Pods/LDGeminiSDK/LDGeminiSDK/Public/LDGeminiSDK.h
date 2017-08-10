//
//  LDGeminiSDK.h
//  LDGeminiSDK
//
//  Created by wangkaird on 2016/10/11.
//  Copyright © 2016年 wangkaird. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^LDGeminiAsyncGetHandler)(id flag,  NSError * _Nullable error);
typedef void(^LDGeminiCacheUpdateHandler)(void);
typedef void(^LDGeminiAsyncUpdateHandler)(BOOL success);

@interface LDGeminiSDK : NSObject

// MARK: SDK参数配置方法
/**
 *  @brief  配置LDGeminiSDK的必要参数，并启用SDK。
 *          不执行该方法，SDK会处于未启动状态，这是所有功能都无法正常使用（如无法请求case数据、查询结果全部为默认值）。
 *
 *  @param  appKey      应用的appkey，用于唯一标识某个应用
 *  @param  deviceId    设备ID，用于唯一标识一台设备
 *  @param  userId      已登录用户的用户名（未登录用户可以传nil）
 *
 *  @return 返回值标识设置成功与否。YES：设置成功；NO：设置失败；
 */
+ (BOOL)setupGeminiWithAppKey:(NSString *)appKey
                     deviceId:(NSString *)deviceId
                       userId:(nullable NSString *)userId;

/**
 * @brief   可选方法，设置请求的url的base地址，若不设置，则默认为http://adc.163.com/
 *          该方法请在SDK启动前完成调用，该方法不会触发SDK启动
 *
 * @param   baseUrl     请求的url的base地址
 */
+ (void)setBaseUrl:(NSString *)baseUrl;

/**
 *  @brief  注册App中启动的合法case（可选）。
 *
 *  @param  caseIdArray 向SDK注册合法的caseId的数组，只接受NSString类型的值，其他类型的值将被抛弃
 *                      传递的数组为nil: 则SDK中所有的caseId均为已注册的合法caseId
 *                      传递的数组为@[]（元素个数为0的空数组）: 则SDK中所有的caseId均为未注册的非法caseId
 */
+ (void)registerCaseWithArray:(nullable NSArray<NSString *> *)caseIdArray;

/**
 *  @brief  设置每次SDK，更新本地Cache时的回调block（可通过该接口上报当前使用的case列表）。
 *
 *  @param  updateBlock SDK中Cache更新时执行的block
 */
+ (void)setupCacheUpdateHandler:(_Nullable LDGeminiCacheUpdateHandler)handler;

// MARK: 控制开关
/**
 *  @breif  控制是否开启Cache自动更新功能（默认开启）。
 *          若开启，则在APP进入前台时，如果发现上次Cache更新失败，则会再次发起一次异步Cache更新。
 *
 *  @param  enable  是否开启：YES开启；NO关闭
 */
+ (void)enableCacheAutoUpdate:(BOOL)enable;

// MARK: 请求与查询
/**
 *  @brief  异步更新SDK中存储AB测试Case列表的Cache。
 *
 *  @param  completion  异步请求完成后的回调block
 *
 *  注意：该方法更新完Cache时，同样会调用setupCacheUpdateHandler:中设置的Cache更新回调。
 */
+ (void)asyncUpdateCache:(_Nullable LDGeminiAsyncUpdateHandler)completion;

/**
 *  @brief  同步更新SDK中存储AB测试case列表的Cache。
 *
 *  @param  timeout     同步请求操作的超时时间，单位为毫秒(ms, 1s = 1000ms)
 *  @param  error       用于返回更新Cache过程中错误（error != nil 说明更新失败，否则更新成功）
 */
+ (void)syncUpdateCache:(NSTimeInterval)timeout error:(NSError * _Nullable  __autoreleasing *)error;

/**
 *  @brief  在SDK的本地Cache中，查询caseId对应的Flag，Cache为空。
 *
 *  @param  caseId      需要查询flag的caseId
 *  @param  defaultFlag 默认的Flag，当caseId查找不到对应的flag、或者caseId不合法时，返回该值
 *
 *  @return 返回caseId对应的flag值，如果查找失败，则返回默认值
 */
+ (id)getFlag:(NSString *)caseId defaultFlag:(id)defaultFlag;

/**
 *  @brief  从服务器异步查询caseId对应的flag。这个方法会从服务器异步获取case列表，并更新到SDK的Cache中，然后通过回调返回查询结果。
 *
 *  @param  caseId      需要查询flag的caseId
 *  @param  defaultFlag 默认的Flag，当caseId查找不到对应的flag、或者caseId不合法时，返回该值
 *  @param  handler     查询到结果之后的回调block。！！注意：handler为nil时，这个方法不会执行任何动作
 */
+ (void)asyncGetFlag:(NSString *)caseId defaultFlag:(id)defaultFlag handler:(LDGeminiAsyncGetHandler)handler;

/**
 *  @brief  从服务器同步查询caseId对应的flag。这个方法会从服务器同步获取case列表，并更新到SDK的Cache中，然后返回查询结果。
 *
 *  @param  caseId      需要查询flag的caseId
 *  @param  defaultFlag 默认的Flag，当caseId查找不到对应的flag、或者caseId不合法时，返回该值
 *  @param  timeout     同步请求操作的超时时间，单位为毫秒(ms, 1s = 1000ms)
 *  @param  error       用于返回请求过程中出现的错误
 *
 *  @return 返回caseId对应的flag值，如果查找失败，则返回默认值
 */
+ (id)syncGetFlag:(NSString *)caseId defaultFlag:(id)defaultFlag timeout:(NSTimeInterval)timeout error:(NSError * _Nullable __autoreleasing *)error;

// MARK: 辅助方法
/**
 *  @brief  判定给定的caseId是否为已注册的合法caseId。是返回YES，否则返回NO。
 *
 *  @param  caseId  待判定的的caseId
 *
 *  @return 传入的caseId是否合法。YES：合法；NO：不合法；
 */
+ (BOOL)registeredCase:(NSString *)caseId;

/**
 *  @brief  返回SDK中当前已注册的合法的caseId的列表。
 *          返回的列表中的caseId符合以下条件:
 *          1. 当前SDK已请求到的case的caseId
 *          2. 该caseId是已注册的合法的值
 *
 *  注意：这里的返回值有可能比注册的合法的caseId的个数要少。
 *
 *  @return 返回SDK中当前已注册的合法的caseId的列表。
 */
+ (NSArray *)currentCaseIdList;

/**
 *  @brief  返回Cache中，具有合法caseId（已注册的caseId）的case列表的JSON字符串。
 *
 *  注意：这个接口主要是为数据收集SDK上报数据使用。
 *
 *  @return 当前case列表的JSON字符串
 */
+ (NSString *)stringForCaseList;

/**
 *  @brief  返回debug信息(只有在LDGeminiMacro.h中的LDGeminiDebug不为0时，才会输出有意义的值。否则只输出一个空字典。)
 *          信息包括:
 *          1. 当前GeminiSDK的配置参数（key: @"configInfo"）
 *          2. 当前GeminiSDK中已注册的caseId列表（key: @"registeredCaseId"）
 *          3. 当前GeminiSDK中已注册的case信息（key: @"caseList"）
 */
+ (NSDictionary *)debugInfo;
@end

NS_ASSUME_NONNULL_END
