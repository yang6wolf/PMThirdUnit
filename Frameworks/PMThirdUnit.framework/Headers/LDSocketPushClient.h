//
//  LDSocketPushClient.h
//  Pods
//
//  Created by liubing on 8/5/15.
//
//

#import <Foundation/Foundation.h>
#import "LDSocketPublicDefine.h"

#ifndef LDSocketPushDEBUG
#define LDSocketPushDEBUG 0
#endif

#if LDSocketPushDEBUG
#define LDSPLog(...) NSLog(__VA_ARGS__)
#else
#define LDSPLog(...) {}
#endif

extern NSString * const LDSocketPushClientErrorDomain;
extern NSString *const LDSPClientStatusChangedNotification;

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

@class LDSPMessage;

@class LDSocketPushClient;

@protocol LDSocketPushClientDelegate <NSObject>

@required
- (void)socketClient:(LDSocketPushClient *)client fetchSocketPushTokenWithCompletion:(void(^)(NSError *error,NSString *deviceId,NSString *token))completion;
- (void)socketClient:(LDSocketPushClient *)client fetchSocketNodeWithCompletion:(void(^)(NSError *error, NSString *host, NSString *port))completion;

@end

@interface LDSocketPushClient : NSObject

@property (nonatomic,copy,readonly) NSString *host;
@property (nonatomic,assign,readonly) UInt32 port;

@property (nonatomic,assign,readonly) NSTimeInterval heartBeatsInterval;

@property (nonatomic,copy,readonly) NSString *deviceId;
@property (nonatomic,assign,readonly) UInt32 productCode;
@property (nonatomic,copy,readonly) NSString *deviceToken;

@property (nonatomic,assign,readonly) LDSPClientStatus status;

@property (nonatomic,weak,readonly) id<LDSocketPushClientDelegate> delegate;

+ (instancetype)defaultClient;

- (void)configClientWithProduct:(UInt32)productCode
             heartBeatsInterval:(NSTimeInterval)heartBeatsInterval
                       delegate:(id<LDSocketPushClientDelegate>)delegate;
- (BOOL)isSocketAlive;

- (void)resetToInitialStatus;
- (void)restoreConnection;
- (void)disConnect;

- (void)addObserver:(id)observer
              topic:(NSString *)topic
           pushType:(LDSocketPushType)pushType
         usingBlock:(void (^)(LDSPMessage *message))block;

- (void)addObserver:(id)observer
              topic:(NSString *)topic
           pushType:(LDSocketPushType)pushType
          accountID:(NSString *)accountID
         usingBlock:(void (^)(LDSPMessage *message))block;

- (void)removeObserver:(id)observer topic:(NSString *)topic;

- (void)addErrorObserver:(id)observer usingBlock:(void (^)(NSError *error))block;
- (void)removeErrorObserver:(id)observer;

@end
