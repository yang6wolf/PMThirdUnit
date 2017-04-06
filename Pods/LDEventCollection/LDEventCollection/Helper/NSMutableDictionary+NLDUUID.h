//
//  NSMutableDictionary+NLDUUID.h
//  LDEventCollection
//
//  Created by SongLi on 6/1/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (NLDUUID)

/**
 *  在字典里存一个以随机UUID为key的对象，返回该UUID，失败返回nil
 */
- (nullable NSString *)NLD_setObjectOrNilForRandomUUID:(nullable id)obj;

@end
