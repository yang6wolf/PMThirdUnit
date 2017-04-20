//
//  LDSocketPublicDefine.h
//  Pods
//
//  Created by 延晋 张 on 16/2/1.
//
//

#ifndef LDSocketPublicDefine_h
#define LDSocketPublicDefine_h

#ifndef LDSocketPushDEBUG
#define LDSocketPushDEBUG 0
#endif

#if LDSocketPushDEBUG
#define LDSPLog(...) NSLog(@"LDSP: %@", [NSString stringWithFormat:__VA_ARGS__])
#else
#define LDSPLog(...) {}
#endif

typedef NS_ENUM(NSInteger, LDSocketPushType)
{
    LDSocketPushTypeGroup = 1,
    LDSocketPushTypeSpecial = 2,
    LDSocketPushTypeMulti = 3
};

typedef NS_ENUM(NSInteger, LDSPClientStatus)
{
    LDSPClientStatusInitial,
    LDSPClientStatusPreparingToken,
    LDSPClientStatusTokenPrepared,
    LDSPClientStatusPreparingHost,
    LDSPClientStatusHostPrepared,
    LDSPClientStatusUnconnected = LDSPClientStatusHostPrepared,
    LDSPClientStatusConnecting,
    LDSPClientStatusConnected,
    LDSPClientStatusRegistering,
    LDSPClientStatusRegisted,
    LDSPClientStatusReady = LDSPClientStatusRegisted,
};

typedef NS_ENUM(NSInteger, LDSocketPushClientErrorType)
{
    LDSocketPushClientErrorTypeDisconnected,
    LDSocketPushClientErrorTypeRegisterClientFail,
    LDSocketPushClientErrorTypeSubscribeTopicFail,
    LDSocketPushClientErrorTypeUnknown,
};

#endif /* Header_h */
