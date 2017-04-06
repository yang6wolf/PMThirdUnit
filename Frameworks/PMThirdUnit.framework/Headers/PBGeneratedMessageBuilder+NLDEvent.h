//
//  PBGeneratedMessageBuilder+NLDEvent.h
//  Pods
//
//  Created by SongLi on 6/13/16.
//
//

#import <ProtocolBuffers/ProtocolBuffers.h>

typedef NS_ENUM(int16_t, NLDProtoBufMessageType)
{
    NLDProtoBufMessageTypeUnknown = 0x0000,
    NLDProtoBufMessageTypeAppColdStart = 0x0001,
    NLDProtoBufMessageTypeAppEnterForeBackground = 0x0002,
    NLDProtoBufMessageTypeButtonView = 0x0003,
    NLDProtoBufMessageTypeListItemClick = 0x0004,
    NLDProtoBufMessageTypeScrollView = 0x0005,
    NLDProtoBufMessageTypeViewScroll = 0x0006,
    NLDProtoBufMessageTypePage = 0x0007,
    NLDProtoBufMessageTypeWebView = 0x0008,
    NLDProtoBufMessageTypeAppUrl = 0x0009,
    NLDProtoBufMessageTypeUserOptional = 0x000A,
    NLDProtoBufMessageTypeAppInstallList = 0x000B,
    NLDProtoBufMessageTypePushMsgClick = 0x000C,
    NLDProtoBufMessageTypeABTest = 0x000D,
    NLDProtoBufMessageTypeLocation = 0x000E,
    NLDProtoBufMessageTypeListScan = 0x000F
};

@interface PBGeneratedMessageBuilder (NLDEvent)

+ (instancetype)messageBuilderWithEventDict:(NSDictionary *)dict;

+ (instancetype)messageBuilderWithEventType:(NSString *)type;

- (NLDProtoBufMessageType)messageType;

+ (NLDProtoBufMessageType)messageTypeForEventDict:(NSDictionary *)dict;

+ (NLDProtoBufMessageType)messageTypeForEventType:(NSString *)type;

@end
