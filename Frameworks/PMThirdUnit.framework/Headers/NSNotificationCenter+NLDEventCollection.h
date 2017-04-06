//
//  NSNotificationCenter+NLDEventCollection.h
//  LDEventCollection
//
//  Created by SongLi on 5/12/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NLDNotificationNameDefine(name) NSString * const name = @#name;

NS_ASSUME_NONNULL_BEGIN

@interface NSNotificationCenter (NLDEventCollection)

+ (void)NLD_postEventCollectionNotificationName:(NSString *)name object:(nullable id)anObject userInfo:(nullable NSDictionary *)aUserInfo;

+ (void)NLD_postMethodHookNotificationName:(NSString *)name userInfo:(nullable NSDictionary *)aUserInfo;

@end

NS_ASSUME_NONNULL_END
