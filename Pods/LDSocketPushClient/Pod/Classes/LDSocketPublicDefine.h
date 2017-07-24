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

static BOOL LDSP_debugLog = NO;

#define LDSPLog(...) \
if(LDSP_debugLog) {\
NSLog(@"LDSP: %@", [NSString stringWithFormat:__VA_ARGS__]);\
}

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
