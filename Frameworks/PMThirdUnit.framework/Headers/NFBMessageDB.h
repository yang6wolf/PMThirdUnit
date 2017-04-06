//
//  FBMessageDB.h
//  NeteaseLottery
//
//  Created by wangbo on 13-3-21.
//  Copyright (c) 2013年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FeedBackMessages.h"
#import "FBSettings.h"

@interface NFBMessageDB : NSObject

/*!
 *  @brief  获取Coredata操作数据库的实例
 */
+ (NFBMessageDB *)getInstance;

#pragma mark - db query
/*!
 *  @brief  获取历史消息列表
 */
-(NSArray *)tenMessageBeforeDate:(NSDate *)date;

/*!
 *  @brief  获取最新消息
 */
-(NSArray *)messagesAfterDate:(NSDate *)date;

/*!
 *  @brief  查询最后一条消息
 */
-(FeedBackMessages *)lastMessage;

/*!
 *  @brief  根据msgId判断消息是否存在
 */
-(BOOL) isMessageExist:(NSString *)msgid;

/*!
 *  @brief  查询FBSettings
 */
-(FBSettings *)settings;


#pragma mark - db insert
/*!
 *  @brief  根据model描述创建一个新的反馈消息
 */
-(FeedBackMessages *)insertMessage;

/*!
 *  @brief  将当前的内存执行保存操作
 */
- (void)saveToDisk;

@end
