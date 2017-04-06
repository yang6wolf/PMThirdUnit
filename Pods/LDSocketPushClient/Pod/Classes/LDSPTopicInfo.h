//
//  LDSPTopicInfo.h
//  Pods
//
//  Created by LiuLiming on 15/10/22.
//
//

#import <Foundation/Foundation.h>
#import "LDSocketPublicDefine.h"

@interface LDSPTopicInfo : NSObject

@property (nonatomic, copy)   NSString *topic;
@property (nonatomic, assign) LDSocketPushType pushType; //推送类型, 具体定义在LDSocketPushType

@property (nonatomic, copy)   NSString *accountID; //用户账号 仅可能会在Multi推送类型中包含

@end
