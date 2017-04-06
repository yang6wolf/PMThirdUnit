//
//  LDRemoteCommandPreferenceService.h
//  NeteaseLottery
//
//  Created by david on 16/2/26.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LDRemoteCommandPreferenceService : NSObject

/**
 * 目前是针对NSUserDefaults操作
 */
+ (BOOL)addPreferenceValue:(id)value key:(NSString *)key;

+ (BOOL)removePreferenceByKey:(NSString *)key;

+ (BOOL)modifyPreferenceValue:(id)value key:(NSString *)key;

+ (BOOL)readPreferenceByKey:(NSString *)key;

@end
