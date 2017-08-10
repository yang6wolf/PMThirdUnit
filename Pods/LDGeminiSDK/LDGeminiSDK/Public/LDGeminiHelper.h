//
//  LDGeminiHelper.h
//  Pods
//
//  Created by wangkaird on 2016/12/29.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LDGeminiHelper : NSObject

/**
 *  @brief  以字典的方式添加case-name与case-id的对应表
 *
 *  @param  map         key为name, value为caseId的字典
 *
 *  注意：
 *      添加的所有的caseId都会注册到LDGeminiSDK中。
 */
+ (void)addCaseIdWithMap:(NSDictionary <NSString *, NSString *> *)map;

/**
 *  @brief  添加一条case-name与case-id的对应项
 *
 *  @param  caseId      某条记录对应的caseId
 *  @param  name        caseId对应的name，之后可以用该那么查询对应的caseid
 *
 *  注意：
 *      添加的caseId会注册到LDGeminiSDK中。
 */
+ (void)addCaseId:(NSString *)caseId withName:(NSString *)name;

/**
 *  @brief  根据name查询对应的caseId
 *
 *  @rturn  返回值为name对应的caseId，若查询不到，则返回nil
 */
+ (nullable NSString *)caseIdForName:(NSString *)name;

/**
 *  @brief  返回所有添加进来的caseId的数组
 */
+ (NSArray *)caseIdArray;

/**
 *  @brief  返回所有添加进来的name的数组
 */
+ (NSArray *)nameArray;

@end
NS_ASSUME_NONNULL_END
