//
//  LDSocketPushClient.m
//  Pods
//
//  Created by liubing on 8/5/15.
//
//

#import "LDSocketPushClient.h"
#import "GCDAsyncSocket.h"
#import "LDSPMessageObserver.h"
#import "LDSPMessageObserverManager.h"
#import "LDSPMessage.h"
#import "MSWeakTimer.h"
#import "Reachability.h"
#include <stdio.h>
#undef TYPE_BOOL
#include "Message.pb.h"
#import "LDSPErrorUploader.h"
#import "LDSPTopicInfo.h"

using namespace message;
using namespace google::protobuf;

NSString *const LDSPClientStatusChangedNotification = @"LDSPClientStatusChangedNotification";

@interface LDSPOperation : NSObject

@property (nonatomic,readonly) Message *message;

@property (nonatomic,readonly) int32_t tag;

- (instancetype)initWithMessage:(Message *)message tag:(int32_t)tag;

@end



typedef NS_ENUM(NSInteger, LDSPMessageType)
{
    LDSPMessageTypeHeartBeat = 0x0000,//	心跳
    LDSPMessageTypeRegClient = 0x0001,//		客户端注册设备
    LDSPMessageTypeSubscribeTopic = 0x0002,//		客户端订阅频道
    LDSPMessageTypeResponse = 0x0101,//		长连接消息响应
    LDSPMessageTypePushMessage = 0x0102,//		长连接转发给客户端的频道订阅消息
    LDSPMessageTypeAuthBackend = 0x0201,//		服务器验证连接合法性
    LDSPMessageTypePublishMessage = 0x0202,//		服务器发布的消息
};

static NSArray * retryIntervals = @[@(5.0),@(10.0),@(15.0)];

@interface LDSocketPushClient ()<NSStreamDelegate>
{
    LDSPClientStatus _status;
}

@property (nonatomic,copy,readwrite) NSString *host;
@property (nonatomic,assign,readwrite) UInt32 port;

@property (nonatomic,copy,readwrite) NSString *deviceId;
@property (nonatomic,assign,readwrite) UInt32 productCode;
@property (nonatomic,copy,readwrite) NSString *deviceToken;
@property (nonatomic,assign,readwrite) NSTimeInterval heartBeatsInterval;

@property (nonatomic,weak,readwrite) id<LDSocketPushClientDelegate> delegate;

@property (nonatomic,assign,readwrite) LDSPClientStatus status;

@property (nonatomic,strong) GCDAsyncSocket *socket;
@property (nonatomic,strong) LDSPMessageObserverManager *observerManager;
@property (nonatomic,strong) MSWeakTimer *heartbeatsTimer;

@property (nonatomic,strong) LDSPMessageObserverManager *errorObserverManager;

@property (nonatomic,strong) NSMutableDictionary *operationDic;
@property (nonatomic,assign) int32_t requestId;

@property (nonatomic,weak) Reachability *reachabilityNotifier;

@property (nonatomic, strong) NSMutableDictionary *topicInfoDict;

@property (nonatomic, strong) NSMutableData *buffer;

@property (nonatomic, assign) NSUInteger retriedTimes;

@property (nonatomic, strong) MSWeakTimer *retryTimer;

@end

//4个字节长度 + 2个字节协议 + 消息体
static NSInteger kLDSPMessageLengthWidth = 4;
static NSInteger kLDSPProtoBufTypeWidth = 2;

static int32_t kLDSPHeartbeatRequestTag = 1;
static int32_t kLDSPRegisterClientRequestTag = 2;

static NSString *kLDSPErrorTopic = @"__error__";
NSString * const LDSocketPushClientErrorDomain = @"LDSocketPushClientErrorDomain";

@implementation LDSocketPushClient

+ (instancetype)defaultClient
{
    static id client;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [LDSocketPushClient new];
    });
    
    return client;
}

#pragma mark - init

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [_reachabilityNotifier stopNotifier];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.observerManager = [LDSPMessageObserverManager new];
        self.errorObserverManager = [LDSPMessageObserverManager new];
        self.operationDic = [NSMutableDictionary new];
        self.topicInfoDict = [NSMutableDictionary new];
        
        _requestId = kLDSPRegisterClientRequestTag;
        _reachabilityNotifier = [Reachability reachabilityForInternetConnection];
        [_reachabilityNotifier startNotifier];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleAppWillEnterForegroundNotification:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleReachabilityChangedNotification:)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];
        
        [self addErrorObserver:[LDSPErrorUploader sharedInstance] usingBlock:^(NSError *error) {
            [[LDSPErrorUploader sharedInstance] uploadSocketErrorIfNeed:error];
        }];
    }
    return self;
}

- (LDSPClientStatus)status
{
    return _status;
}

- (void)setStatus:(LDSPClientStatus)status
{
    _status = status;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:LDSPClientStatusChangedNotification object:nil];
}

- (int32_t)requestId
{
    return ++_requestId;
}

- (void)configClientWithProduct:(UInt32)productCode
             heartBeatsInterval:(NSTimeInterval)heartBeatsInterval
                       delegate:(id<LDSocketPushClientDelegate>)delegate
{
    
    self.productCode = productCode;
    self.heartBeatsInterval = heartBeatsInterval;
    self.delegate = delegate;
}

- (BOOL)isSocketAlive
{
    return self.status >= LDSPClientStatusReady;
}

- (void)resetToInitialStatus
{
    self.socket.delegate = nil;
    [self.socket disconnect];
    
    self.delegate = nil;
    self.status = LDSPClientStatusInitial;
    self.deviceId = nil;
    self.deviceToken = nil;
    self.host = nil;
    self.port = 0;
    self.productCode = 0;
}

#pragma mark - 连接建立与断开

- (void)fetchToken
{
    if (self.status == LDSPClientStatusPreparingToken) {
        return;
    }
    
    LDSPLog(@"fetching deviceId and token");
    
    [self.delegate socketClient:self fetchSocketPushTokenWithCompletion:^(NSError *error, NSString *deviceId, NSString *token) {
        
        LDSPLog(@"did fetch deviceId and token:%@,%@,%@",error,deviceId,token);
        if (deviceId.length && token.length) {
            self.deviceId = deviceId;
            self.deviceToken = token;
            self.status = LDSPClientStatusTokenPrepared;
            [self restoreConnection];
        }
    }];
}

- (void)fetchHost
{
    if (self.status == LDSPClientStatusPreparingHost) {
        return;
    }
    
    LDSPLog(@"fetching host and port");
    
    [self.delegate socketClient:self fetchSocketNodeWithCompletion:^(NSError *error, NSString *host, NSString *port) {
        LDSPLog(@"did fetch host and port:%@,%@,%@",error,host,port);
        if (host.length && port.length) {
            self.host = host;
            self.port = [port intValue];
            self.status = LDSPClientStatusHostPrepared;
            [self restoreConnection];
        }
    }];
}

- (void)connect
{
    if (!self.deviceToken.length || !self.deviceId.length || !self.host.length || self.port <= 0) {
        return;
    }
    
    if (self.status == LDSPClientStatusConnecting) {
        return;
    }
    
    self.status = LDSPClientStatusConnecting;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(disConnect) object:nil];
    
    self.socket.delegate = nil;
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self
                                             delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    [self.socket connectToHost:self.host onPort:self.port withTimeout:10 error:&error];
    
    if (error) {
        self.status = LDSPClientStatusUnconnected;
        
        LDSPLog(@"%@",error.localizedDescription);
        [self dispatchError:error];
        if (self.retriedTimes > 0) {
            [self handleDisconnetErrorRetry];
        }
    }
}

- (void)disConnect
{
    [self.socket disconnect];
    self.socket.delegate = nil;
    self.socket = nil;
    self.status = LDSPClientStatusUnconnected;
    [self stopHeartbeat];
}

- (void)handleAppWillEnterForegroundNotification:(NSNotification *)notification
{
    [self restoreConnection];
}

- (void)handleReachabilityChangedNotification:(NSNotification *)notification
{
    if ([self.reachabilityNotifier currentReachabilityStatus] != NotReachable) {
        [self restoreConnection];
    } else {
        [self disConnect];
    }
}

- (void)restoreConnection
{
    switch (self.status) {
        case LDSPClientStatusInitial:
        {
            [self fetchToken];
        }
            break;
        case LDSPClientStatusPreparingToken:
            break;
        case LDSPClientStatusTokenPrepared:
        {
            [self fetchHost];
        }
            break;
        case LDSPClientStatusPreparingHost:
            break;
        case LDSPClientStatusHostPrepared:
        {
            if ([self.observerManager hasObservers]) {
                [self connect];
            }
        }
            break;
        case LDSPClientStatusConnecting:
            break;
        case LDSPClientStatusConnected:
        {
            [self registerClient];
        }
            break;
        case LDSPClientStatusRegistering:
            break;
        case LDSPClientStatusReady:
        {
            [self startHeartbeat];
            [self subscribeAllObservedTopics];
        }
            break;
        default:
            break;
    }
}

#pragma mark - GCDAsyncSocketDelegate

-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    LDSPLog(@"connected。\n connected host:%@ \n connected port:%@ \n local host:%@ \n local port:%@ \n",sock.connectedHost,@(sock.connectedPort),sock.localHost,@(sock.localPort));
    
    self.status = LDSPClientStatusConnected;
    [self restoreConnection];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    LDSPLog(@"disconnected error:%@", err);
    
    if (err) {
        [self handleDisconnetErrorRetry];
    } else {
        self.status = LDSPClientStatusUnconnected;
        [self stopHeartbeat];
    }
    
    [self dispatchError:err];
    
    NSError *error = [NSError errorWithDomain:LDSocketPushClientErrorDomain code:LDSocketPushClientErrorTypeDisconnected userInfo:nil];
    [self dispatchError:error];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    if (self.buffer) {
        [self.buffer appendData:data];
        data = self.buffer;
    }
    
    NSInteger bodyOffset = kLDSPMessageLengthWidth + kLDSPProtoBufTypeWidth;
    if (data.length > bodyOffset) {
        char lengthData[kLDSPMessageLengthWidth];
        [data getBytes:lengthData length:kLDSPMessageLengthWidth];
        int32_t messageLength = *((int32_t *)(lengthData));
        messageLength = CFSwapInt32BigToHost(messageLength);
        messageLength += kLDSPMessageLengthWidth;
        
        NSInteger remainLength = data.length - messageLength;
        if (remainLength == 0) {
            [self handleRawMessage:data withTag:tag];
            self.buffer = nil;
            [self.socket readDataWithTimeout:-1 tag:0];
        } else if (remainLength > 0) {
            NSData *remainData = [data subdataWithRange:NSMakeRange(messageLength, remainLength)];
            [self handleRawMessage:[data subdataWithRange:NSMakeRange(0, messageLength)] withTag:tag];
            self.buffer = nil;
            [self socket:sock didReadData:remainData withTag:tag];//防止死循环？
        } else {
            if (!self.buffer) {
                self.buffer = [data mutableCopy];
            }
            
            NSMutableData *buffer = [data mutableCopy]; //直接用 self.buffer ?
            NSUInteger maxLength = -remainLength;
            [self.socket readDataWithTimeout:-1 buffer:buffer bufferOffset:data.length maxLength:maxLength tag:0];
        }
    } else {
        //should never reach here
        self.buffer = nil;
        [self.socket readDataWithTimeout:-1 tag:0];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    LDSPLog(@"did send data with tag:%@",@(tag));
    [self.socket readDataWithTimeout:-1 tag:0];
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length
{
    LDSPLog(@"send data timeout with tag:%@",@(tag));
    
    if (tag == kLDSPRegisterClientRequestTag) { //注册
        self.status = LDSPClientStatusConnected;
        
        NSError *error = [NSError errorWithDomain:LDSocketPushClientErrorDomain code:LDSocketPushClientErrorTypeRegisterClientFail userInfo:nil];
        [self dispatchError:error];
    } else if (tag == kLDSPHeartbeatRequestTag) { //心跳
        
    } else { //订阅
        LDSPOperation *operation = self.operationDic[@(tag)];
        Subscribe *subcribe = (Subscribe *)operation.message;
        NSDictionary *userInfo = nil;
        if (subcribe && subcribe->has_topic()) {
            NSString *topic = [NSString stringWithCString:subcribe->topic().c_str() encoding:NSUTF8StringEncoding];
            if (topic) {
                userInfo = @{@"topic":topic};
            }
        }
        NSError *error = [NSError errorWithDomain:LDSocketPushClientErrorDomain code:LDSocketPushClientErrorTypeSubscribeTopicFail userInfo:userInfo];
        [self dispatchError:error];
    }
    
    [self.operationDic removeObjectForKey:@(tag)];
    
    return 0;
}

#pragma mark - 消息处理与分发

- (void)handleRawMessage:(NSData *)data  withTag:(long)tag
{
    NSInteger bodyOffset = kLDSPMessageLengthWidth + kLDSPProtoBufTypeWidth;
    if (data.length > bodyOffset) {
        char rawData[data.length];
        [data getBytes:rawData length:data.length];
        
        int32_t messageLength = *((int32_t *)(rawData));
        messageLength = CFSwapInt32BigToHost(messageLength);
        
        int16_t protoType =  *((int16_t *)(rawData+kLDSPMessageLengthWidth));
        protoType = CFSwapInt16BigToHost(protoType);
        
        const void *pBody = rawData+bodyOffset;
        int bodyLength = (int)(data.length-bodyOffset);
        
        if (messageLength != bodyLength + kLDSPProtoBufTypeWidth || bodyLength <= 0) {
            return;
        }
        
        switch (protoType) {
            case LDSPMessageTypeHeartBeat:
            {
                LDSPLog(@"received server heartbeat");
            }
                break;
            case LDSPMessageTypeResponse:
            {
                Response *response = new Response();
                response->ParseFromArray(pBody,bodyLength);
                
                LDSPLog(@"received server response,requestId:%@,retCode:%@",@(response->requestid()),@(response->retcode()));
                LDSPLog(@"has_righthost %@",@(response->has_righthost()));
                if (response->has_righthost()) {
                    //表明需要重新获取ip地址
                    self.status = LDSPClientStatusInitial;
                    [self restoreConnection];
                } else {
                    if (response->retcode() == SUCCESS) {
                        if (response->requestid() == kLDSPRegisterClientRequestTag) {
                            self.status = LDSPClientStatusRegisted;
                            
                            //清掉重试信息
                            self.retriedTimes = 0;
                            
                            [self restoreConnection];
                        }
                    } else {
                        if (response->requestid() == kLDSPRegisterClientRequestTag) {
                            self.status = LDSPClientStatusConnected;
                            
                            NSError *error = [NSError errorWithDomain:LDSocketPushClientErrorDomain code:LDSocketPushClientErrorTypeRegisterClientFail userInfo:nil];
                            [self dispatchError:error];
                        } else {
                            LDSPOperation *operation = self.operationDic[@(response->requestid())];
                            Subscribe *subcribe = (Subscribe *)operation.message;
                            NSDictionary *userInfo = nil;
                            if (subcribe && subcribe->has_topic()) {
                                NSString *topic = [NSString stringWithCString:subcribe->topic().c_str() encoding:NSUTF8StringEncoding];
                                if (topic) {
                                    userInfo = @{@"topic":topic};
                                }
                            }
                            
                            NSError *error = [NSError errorWithDomain:LDSocketPushClientErrorDomain code:LDSocketPushClientErrorTypeSubscribeTopicFail userInfo:nil];
                            [self dispatchError:error];
                        }
                    }
                }
                
                [self.operationDic removeObjectForKey:@(response->requestid())];
                
                delete response;
            }
                break;
            case LDSPMessageTypePushMessage:
            {
                LDSPLog(@"received server ret message");
                RetMsg *msg = new RetMsg();
                msg->ParseFromArray(pBody,bodyLength);
                
                LDSPMessage *message = [LDSPMessage new];
                
                if (msg->has_body()) {
                    message.body = [NSData dataWithBytes:msg->body().c_str() length:msg->body().size()];
                }
                
                if (msg->has_topic()) {
                    message.topic = [NSString stringWithCString:msg->topic().c_str() encoding:NSUTF8StringEncoding];
                }
                
                [self dispatchMessage:message];
                
                LDSPLog(@"received server ret message,topic:%@,body:%@",message.topic,message.body);
                
                delete msg;
            }
                break;
                
            default:
            {
                LDSPLog(@"bad message,unknown type:%@",@(protoType));
            }
                break;
        }
    } else {
        LDSPLog(@"bad message,illegal length");
    }
}

- (void)dispatchMessage:(LDSPMessage *)message
{
    NSArray *observersQueue = [self.observerManager observersQueueWithTopic:message.topic];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        for (LDSPMessageObserver *observer in observersQueue) {
            if (observer.target) {
                void (^block)(LDSPMessage *message) = observer.block;
                block(message);
            } else {
                [self.observerManager removeObserver:observer];
            }
        }
    });
}

#pragma mark - Topic subscribe && unsubscribe

- (void)addObserver:(id)observer topic:(NSString *)topic pushType:(LDSocketPushType)pushType usingBlock:(void (^)(LDSPMessage *))block
{
    [self addObserver:observer topic:topic pushType:pushType accountID:nil usingBlock:block];
}

- (void)addObserver:(id)observer topic:(NSString *)topic pushType:(LDSocketPushType)pushType accountID:(NSString *)accountID usingBlock:(void (^)(LDSPMessage *))block
{
    if (!observer || !topic.length || !block) {
        return;
    }
    
    LDSPTopicInfo *topicInfo = [LDSPTopicInfo new];
    topicInfo.topic = topic;
    topicInfo.pushType = pushType;
    self.topicInfoDict[topic] = topicInfo;
    if (pushType == LDSocketPushTypeMulti) {
        topicInfo.accountID = accountID;
    }
    
    BOOL hasObserver = [self.observerManager observersQueueWithTopic:topic].count > 0;
    [self.observerManager addObserver:[LDSPMessageObserver observerWithTarget:observer topic:topic block:block]];
    
    if (!hasObserver) {//还没有订阅过该主题，则增加订阅
        if (self.status == LDSPClientStatusReady) {
            [self subscribeTopic:topic];
        } else {
            if (self.status == LDSPClientStatusUnconnected) {//只有在Token和Host均已准备好时才主动建立连接，避免频繁获取token对后台造成较大压力
                [self restoreConnection];
            }
        }
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(disConnect) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(unsubscribeTopic:) object:topic];
}

- (void)removeObserver:(id)observer topic:(NSString *)topic
{
    if (!observer || !topic.length) {
        return;
    }
    
    NSArray *observers = [self.observerManager observersQueueWithTopic:topic];
    
    for (LDSPMessageObserver *messageObserver in observers) {
        if (messageObserver.target == observer) {
            [self.observerManager removeObserver:messageObserver];
        }
    }
    
    if ([self.observerManager observersQueueWithTopic:topic].count == 0) {
        [self performSelector:@selector(unsubscribeTopic:) withObject:topic afterDelay:30]; //延迟执行，避免频繁取消订阅后再次订阅主题
    }
    
    if (![self.observerManager hasObservers]) {
        [self performSelector:@selector(disConnect) withObject:nil afterDelay:35]; //延迟执行，避免频繁断开建立连接
    }
}

- (void)subscribeAllObservedTopics
{
    NSArray *allTopic = [self.observerManager allObservedTopic];
    for (NSString *topic in allTopic) {
        [self subscribeTopic:topic]; //优化，合并请求。
    }
}

- (void)subscribeTopic:(NSString *)topic
{
    LDSPLog(@"subscribe topic: %@",topic);
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(disConnect) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(unsubscribeTopic:) object:topic];
    
    Subscribe *subscribe = new Subscribe();
    subscribe->set_requestid([self requestId]);
    subscribe->set_topic(topic.UTF8String);
    subscribe->set_subtype(SUB);
    
    LDSPTopicInfo *topicInfo = self.topicInfoDict[topic];
    PushType pushType = [self typeWithOCType:topicInfo.pushType];
    subscribe->set_pushtype(pushType);
    if (pushType == MULTI) {
        subscribe->set_accountid([topicInfo.accountID UTF8String]);
    }
    
    LDSPOperation *operation = [[LDSPOperation alloc] initWithMessage:subscribe tag:subscribe->requestid()];
    self.operationDic[@(subscribe->requestid())] = operation;
    
    [self sendProtoMessage:subscribe type:LDSPMessageTypeSubscribeTopic tag:subscribe->requestid()];
    
    delete subscribe;
}

- (PushType)typeWithOCType:(LDSocketPushType)ocType
{
    PushType cppType = GROUP;
    switch (ocType) {
        case LDSocketPushTypeGroup: {
            cppType = GROUP;
            break;
        }
        case LDSocketPushTypeSpecial: {
            cppType = SPECIAL;
            break;
        }
        case LDSocketPushTypeMulti: {
            cppType = MULTI;
            break;
        }
    }
    return cppType;
}

- (void)unsubscribeTopic:(NSString *)topic
{
    LDSPLog(@"unsubscribe topic: %@",topic);
    
    Subscribe *unsubscribe = new Subscribe();
    unsubscribe->set_requestid([self requestId]);
    unsubscribe->set_topic(topic.UTF8String);
    unsubscribe->set_subtype(UNSUB);
    
    LDSPTopicInfo *topicInfo = self.topicInfoDict[topic];
    PushType pushType = topicInfo.pushType == LDSocketPushTypeSpecial? SPECIAL : GROUP;
    unsubscribe->set_pushtype(pushType);
    
    [self sendProtoMessage:unsubscribe type:LDSPMessageTypeSubscribeTopic  tag:unsubscribe->requestid()];
    
    delete unsubscribe;
}

#pragma mark - 心跳

- (void)startHeartbeat
{
    [self.heartbeatsTimer invalidate];
    self.heartbeatsTimer = [MSWeakTimer scheduledTimerWithTimeInterval:self.heartBeatsInterval
                                                                target:self
                                                              selector:@selector(heartbeat)
                                                              userInfo:nil
                                                               repeats:YES
                                                         dispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

- (void)stopHeartbeat
{
    [self.heartbeatsTimer invalidate];
    self.heartbeatsTimer = nil;
}

- (void)heartbeat
{
    LDSPLog(@"heartbeat at time: %@",[NSDate date]);
    
    HeartBeat *heartbeat = new HeartBeat();
    heartbeat->set_requestid(kLDSPHeartbeatRequestTag);
    [self sendProtoMessage:heartbeat type:LDSPMessageTypeHeartBeat tag:kLDSPHeartbeatRequestTag];
    delete heartbeat;
}

#pragma mark - 设备注册

- (void)registerClient
{
    if (self.status == LDSPClientStatusRegistering) {
        return;
    }
    
    if (self.deviceId.length==0 || self.deviceToken.length==0) {
        return;
    }
    
    LDSPLog(@"registerClient");
    
    self.status = LDSPClientStatusRegistering;
    
    RegDev *regDev = new RegDev();
    
    regDev->set_requestid(kLDSPRegisterClientRequestTag);
    regDev->set_productcode(self.productCode);
    regDev->set_deviceid([self.deviceId UTF8String]);
    regDev->set_devtype(IOS);
    regDev->set_token([self.deviceToken UTF8String]);
    
    [self sendProtoMessage:regDev type:LDSPMessageTypeRegClient tag:regDev->requestid()];
    
    delete regDev;
}

#pragma mark - 发送消息

- (void)sendProtoMessage:(Message *)messgae type:(NSInteger)type tag:(long)tag
{
    std::string ps = messgae->SerializeAsString();
    NSInteger messageLength = kLDSPProtoBufTypeWidth+ps.size();//不包含长度4个字节
    
    if (messageLength <= INT32_MAX) {
        int32_t length = (int32_t)messageLength;
        int16_t protoType = (int16_t)type;
        NSMutableData *data = [NSMutableData dataWithCapacity:messageLength];
        
        //转为大端序
        length = CFSwapInt32HostToBig(length);
        protoType = CFSwapInt16HostToBig(protoType);
        
        // 4个字节长度 + 2个字节协议 + 消息体
        [data appendBytes:&length length:sizeof(length)];
        [data appendBytes:&protoType length:sizeof(protoType)];
        [data appendBytes:ps.c_str() length:ps.size()];
        
        [self.socket writeData:data withTimeout:15 tag:tag];
        
        LDSPLog(@"send data with tag:%@",@(tag));
    } else {
        LDSPLog(@"message too long");
    }
}

#pragma mark - 错误分发

- (void)addErrorObserver:(id)observer usingBlock:(void (^)(NSError *error))block
{
    [self.errorObserverManager addObserver:[LDSPMessageObserver observerWithTarget:observer topic:kLDSPErrorTopic block:block]];
}

- (void)removeErrorObserver:(id)observer
{
    [self.errorObserverManager removeObserver:[LDSPMessageObserver observerWithTarget:observer topic:kLDSPErrorTopic block:nil]];
}

- (void)dispatchError:(NSError *)error
{
    NSArray *observersQueue = [self.errorObserverManager observersQueueWithTopic:kLDSPErrorTopic];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        for (LDSPMessageObserver *observer in observersQueue) {
            if (observer.target) {
                void (^block)(NSError *error) = observer.block;
                block(error);
            } else {
                [self.errorObserverManager removeObserver:observer];
            }
        }
    });
}

#pragma mark - Disconnect后重连

- (void)handleDisconnetErrorRetry
{
    if (self.retriedTimes >= [retryIntervals count]) {
        //如果已经尝试完5、10、15s的三次重试，则不再尝试
        LDSPLog(@"disconnetErrorRetry failed");
    } else {
        NSTimeInterval interval = [retryIntervals[self.retriedTimes] doubleValue];
        [self.retryTimer invalidate];
        self.retryTimer = [MSWeakTimer scheduledTimerWithTimeInterval:interval
                                                               target:self
                                                             selector:@selector(doRetryFromInitialStatus)
                                                             userInfo:nil
                                                              repeats:NO
                                                        dispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        
    }
}

- (void)doRetryFromInitialStatus
{
    LDSPLog(@"do retry %ld",self.retriedTimes + 1);
    [self stopHeartbeat];
    self.status = LDSPClientStatusInitial;
    [self.retryTimer invalidate];
    self.retryTimer = nil;
    [self restoreConnection];
    self.retriedTimes++;
}
@end

@implementation LDSPOperation

- (void)dealloc
{
    if (_message) {
        delete _message;
    }
}

- (instancetype)initWithMessage:(Message *)message tag:(int32_t)tag
{
    if (self = [super init]) {
        if (message) {
            _message = message->New();
            _message->CopyFrom(*message);
        }
        _tag = tag;
    }
    return self;
}

@end
