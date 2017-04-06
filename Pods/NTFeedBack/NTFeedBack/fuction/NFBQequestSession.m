//
//  FBQequestSession.m
//  NeteaseLottery
//
//  Created by wangbo on 13-3-21.
//  Copyright (c) 2013年 netease. All rights reserved.
//

#import "NFBQequestSession.h"
#import "NFBMessageDB.h"
#import "NFBAutoReply.h"
#import "NFBMMHeaderView.h"
#import "NFBConfig.h"
#import "NFBHttpRequest.h"
#import "NFBUtil.h"
#import "NFBTimer.h"
#import "NFBManager.h"
#import "NFBNotifications.h"
#import "NFBDataBackupPool.h"
#import "NFBImageLoaderView.h"
#import "NFBNetworkDiagnoser.h"


@interface NFBQequestSession()
@property(nonatomic) BOOL isRefreshing;
@property(nonatomic,readwrite) NFBPollingMessageMode pollingMode;
@property(nonatomic,readwrite) NSMutableDictionary *uploadProgresses;
@end

@implementation NFBQequestSession {
    NFBTimer *_poolTimer;
    NSMutableSet *_sendMessageSet;
}

static NFBQequestSession *instance = nil;
+ (NFBQequestSession *)session {
	@synchronized(self) {
		if (instance == nil) {
			instance = [[NFBQequestSession alloc] init];
        }
    }
	return instance;
}

- (id)init {
    if (self=[super init]) {
        FBSettings *settings = [NFBMessageDB getInstance].settings;
        _unreadNums = settings.unread.integerValue;
        self.uploadProgresses = [NSMutableDictionary dictionary];
    }
    return self;
}


- (void)dealloc{
    [_poolTimer invalidate];
}

- (void)startPollMessage:(NFBPollingMessageMode)mode; {
    if ((self.pollingMode==NFBPollingMessageNone&&mode!=NFBPollingMessageNone)
        ||mode==NFBPollingMessageFast) {
        [self refreshMessageRightnow];
    }
    if (self.pollingMode!=mode) {
        self.pollingMode = mode;
        
        [_poolTimer invalidate];
        if (mode!=NFBPollingMessageNone) {
            NSTimeInterval interval = (mode==NFBPollingMessageFast)?10:120;
            _poolTimer = [NFBTimer timerWithInterval:interval repeats:YES onFire:^{
                [self pollMessageTimerFired];
            }];
        }

    }
}

- (void)refreshMessageRightnow {
    FeedBackMessages *lastMessage = [[NFBMessageDB getInstance] lastMessage];
    [self doRefreshFromServer:lastMessage.msgid];
}

- (void)setUnreadNums:(NSUInteger)unreadNums {
    if (_unreadNums==unreadNums) {
        return;
    }
    _unreadNums = unreadNums;
    FBSettings *settings = [NFBMessageDB getInstance].settings;
     settings.unread = [NSNumber numberWithUnsignedLong:(unsigned long)unreadNums] ;
    [[NSNotificationCenter defaultCenter] postNotificationName:NFeedBackUnreadMessageCountChangedNotification
                                                        object:self
                                                      userInfo:@{NFeedBackUnreadMessageCountKey:settings.unread}];
}


- (BOOL)isMessageSending:(FeedBackMessages *)message{
    if(message == nil){
        return NO;
    }
    if ([_sendMessageSet containsObject:message]) {
        return YES;
    }
    return NO;
}



-(void)pollMessageTimerFired {
    if (self.isRefreshing) {
        return;
    }
    FeedBackMessages *lastMessage = [[NFBMessageDB getInstance] lastMessage];
//    if (lastMessage) {
//        if (! [lastMessage.isOut boolValue]) {
//            FBSettings *settings = [[NFBMessageDB getInstance] settings];
//            if ([[NSDate date] timeIntervalSinceDate:[settings lasUpdateTime]] < 60) {
//                return;
//            }
//        }else{
//            FBSettings *settings = [[NFBMessageDB getInstance] settings];
//            if ([[NSDate date] timeIntervalSinceDate:[settings lasUpdateTime]] < 10) {
//                return;
//            }
//        }
//    }
    [self doRefreshFromServer:lastMessage.msgid];
}


- (void)doRefreshFromServer:(NSString*)lastMessageId
{
    [[NFBMessageDB getInstance] settings].lasUpdateTime = [NSDate date];
    self.isRefreshing = YES;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[NFBConfig sharedConfig].deviceId forKey:@"deviceId"];
    if (lastMessageId) {
        [params setObject:lastMessageId forKey:@"msgId"];
    }
    [NFBHttpRequest startRequestWithUrl:[[NFBConfig sharedConfig].host stringByAppendingString:@"/service/pollFeedback.do"]
                                 params:params
             completionBlockWithSuccess:^(NSURLSessionDataTask *dataTask, id responseObject) {
                 self.isRefreshing = NO;
                 
                 NSDictionary *mdict = nil;
                 if ([ responseObject isKindOfClass:[NSData class]]) {
                     mdict = [NSJSONSerialization JSONObjectWithData:responseObject
                                                             options:0
                                                               error:NULL];
                 }
                 NSArray *array  = [mdict objectForKey:@"msgList"];
                 for(NSDictionary *dict in array){
                     NSString *msgId = [NFBUtil getStringFromDictionary:dict ofKey:@"msgId"];
                     if ( [msgId compare:lastMessageId] != NSOrderedDescending) {
                         continue ;
                     }
                     if ([[NFBMessageDB getInstance] isMessageExist:msgId]) {
                         continue;
                     }
                     FeedBackMessages *message = [[NFBMessageDB getInstance] insertMessage];
                     message.content = [NFBUtil getStringFromDictionary:dict ofKey:@"message"];
                     message.title = [NFBUtil getStringFromDictionary:dict ofKey:@"title"];
                     message.imgUrl = [NFBUtil getStringFromDictionary:dict ofKey:@"imageUrl"];
                     message.msgid = [NFBUtil getStringFromDictionary:dict ofKey:@"msgId"];
                     message.url = [NFBUtil getStringFromDictionary:dict ofKey:@"url"];

                     NSString *dateString = [NFBUtil getStringFromDictionary:dict ofKey:@"createTime"];
                     message.time = [self formateStringToDate:dateString];
                     if ([NFBUtil getIntegerFromDictionary:dict ofKey:@"msgType" defaultValue:0] == 0) {
                         message.isOut = [NSNumber numberWithBool:YES];
                     }else{
                         message.isOut = [NSNumber numberWithBool:NO];
                     }
                 }
                 
                 //当msgId为nil时，说明是第一次拉取数据，即使返回了数据也不提示用户，避免卸载重装后提示有消息，但实际是老的消息。
                 //这样的问题是，如果在上次卸载后真的有新消息，也不会提示。
                 if ([array count] != 0 && lastMessageId) {
                     self.unreadNums = array.count+self.unreadNums;
                 }
                 [[NFBMessageDB getInstance] saveToDisk];
                 
                 if (array.count>0) {
                     [[NSNotificationCenter defaultCenter] postNotificationName:NFBNewMessageArrived object:self];
                 }
                 
             }
                                failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
                                    self.isRefreshing = NO;
                                }];
}

-(void) sendMessage:(FeedBackMessages *)message {
    if (_sendMessageSet == nil) {
        _sendMessageSet = [[NSMutableSet alloc] init];
    }
    [_sendMessageSet addObject:message];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[NFBConfig sharedConfig].deviceId forKey:@"deviceId"];
    [params setObject:@"iphone" forKey:@"deviceType"];
    [params setObject:@"1" forKey:@"diagnostic"];
    NSString *messageContent = message.content ? message.content:@"上传图片";
    [params setObject:messageContent forKey:@"message"];
    if(message.title){
        [params setObject:message.title forKey:@"title"];
    }else{
       [params setObject:messageContent forKey:@"title"];
    }

    if (message.ssn) {
        [params setObject:message.ssn forKey:@"accountId"];
    }
    [params setObject:@"json" forKey:@"format"];
    
    if (message.imgUrl.length <= 0) {
        [NFBHttpRequest startRequestWithUrl:[[NFBConfig sharedConfig].host stringByAppendingString:@"/service/sendFeedback.do"]
                                     params:params
                 completionBlockWithSuccess:^(NSURLSessionDataTask *dataTask, id responseObject) {
                     [self handleSendingMessage:message response:responseObject];
                 } failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
                     [self handleSendingMessage:message response:nil];
                 }];
    } else {
        UIImage *img = [self cachedImageAtUrl:message.imgUrl];
        [NFBHttpRequest startRequestWithUrl:[[NFBConfig sharedConfig].host stringByAppendingString:@"/service/sendFeedback.do"]
                                     params:params image:img
                 completionBlockWithSuccess:^(NSURLSessionDataTask *dataTask, id responseObject) {
                     [ self handleSendingMessage:message response:responseObject];
                 } failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
                     [self handleSendingMessage:message response:nil];
                 } progressBlock:^(NSUInteger uploadProgress) {
                     [self handleSendingMessage:message progress:uploadProgress];
                 }];
    }

}

-(UIImage*)cachedImageAtUrl:(NSString*)url {
	NSData *data = [NFBDataBackupPool dataForKey:url];
    if (data) {
        return [UIImage imageWithData:data];
    }
	return nil;
}

- (void)sendMessageWithContent:(NSString*)content andImg:(UIImage*)img andTitle:(NSString*)title{
    FeedBackMessages *message = [[NFBMessageDB getInstance] insertMessage];
    message.content = content;
    message.title = title;
    message.time = [NSDate date];
    message.isOut = [NSNumber numberWithBool:YES];
    message.status = [NSNumber numberWithInt:FBMessageSTSending];
    if (img) {
        NSString *imgurlr = [[NSUUID UUID] UUIDString];
        [NFBDataBackupPool addData:[NFBUtil imageToData:img] forKey:imgurlr expire:nil];
        message.imgUrl = imgurlr;
    }
    [[NFBMessageDB getInstance] saveToDisk];
    [self sendMessage:message];
    
    if(![NFBAutoReplySession sharedSession].isOnline
       && [NFBAutoReplySession sharedSession].shouldAutoReplyToCustomQuestion){//不在线，对用户首次输入自动回复
        [NFBAutoReplySession sharedSession].shouldAutoReplyToCustomQuestion = NO;
        [[NFBAutoReplySession sharedSession] createOfflineMessage];
    }
    
}

- (void)sendAutoReplayQuestion:(NSString *)question{
    if ([[NFBAutoReplySession sharedSession] canAutoReplyQuestion:question] == NO)
        return;
 
    FeedBackMessages *autoReplyMessage = [[NFBAutoReplySession sharedSession] createAnswerForQuestion:question];
    if(autoReplyMessage){
        [[NSNotificationCenter defaultCenter] postNotificationName:NFBNewAutoReplyMessageArrived object:autoReplyMessage];
    }
}

- (void)handleSendingMessage:(FeedBackMessages*)message response:(NSData*)response
{
    if (response) {
        id resultJson = [NSJSONSerialization JSONObjectWithData:response
                                                        options:NSJSONReadingMutableLeaves
                                                          error:nil];
        int result = [resultJson[@"result"] intValue];
        //上传成功，重新保存msgID和msgTime
        //-1是参数缺失或者deviceId不合法，-2是没有相应产品，0是未知异常,1是成功
        if(result == 1){
            message.status = [NSNumber numberWithInt:FBMessageSTSendSuccess];
            message.msgid = [NSString stringWithString:resultJson[@"msgId"]];
            message.time =  [self formateStringToDate:[NSString stringWithString:resultJson[@"createTime"]]];
            //如果有网络敏感词，启动网络诊断
            if([resultJson[@"netDiagno"] boolValue]){
                //发送检测域名劫持的通知
                [[NSNotificationCenter defaultCenter] postNotificationName:CheckDNSisHijacked object:nil];
                [[NFBNetworkDiagnoser sharedInstance] start];
            }
        }else {
            message.status = [NSNumber numberWithInt:FBMessageSTSendFailed];
        }
    } else {
        message.status = [NSNumber numberWithInt:FBMessageSTSendFailed];
    }
    [[NFBMessageDB getInstance] saveToDisk];
    [_sendMessageSet removeObject:message];
    if (self.uploadProgresses[message.imgUrl]) {
        [self.uploadProgresses removeObjectForKey:message.imgUrl];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NFeedBackMessageStatusChanged object:message userInfo:nil];
}

- (void)handleSendingMessage:(FeedBackMessages*)message progress:(NSUInteger)uploadProgress {
    if (message.imgUrl.length <= 0) {
        return;
    }
    
    self.uploadProgresses[message.imgUrl] = @(uploadProgress);
    [[NSNotificationCenter defaultCenter] postNotificationName:NFeedBackMessageUploadProgressChanged object:message userInfo:nil];
}


#pragma mark - util method

-(NSDate *)formateStringToDate:(NSString *)str {
    if(!str) return nil;

    NSDate *dateTime = nil;
    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }

    dateTime = [dateFormatter dateFromString:str];
    return dateTime;
}

#pragma mark 测试专属代码，直接发送反馈消息不经过CoreData

-(void)debugSend:(NSString *)content title:(NSString *)title accountId:(NSString*)accountId
{
    if (!content) {
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[NFBConfig sharedConfig].deviceId forKey:@"deviceId"];
    [params setObject:@"iphone" forKey:@"deviceType"];
    [params setObject:content forKey:@"message"];
    if(title){
        [params setObject:title forKey:@"title"];
    }else{
        [params setObject:content forKey:@"title"];
    }
    if (accountId) {
        [params setObject:accountId forKey:@"accountId"];
    }
    
    [NFBHttpRequest startRequestWithUrl:[[NFBConfig sharedConfig].host stringByAppendingString:@"/service/sendFeedback.do"]
                                 params:params
             completionBlockWithSuccess:^(NSURLSessionDataTask *dataTask, id responseObject) {
                        NSLog(@"debugSend:%@",[responseObject description]);
                 
             }
                                failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
                                    NSLog(@"debugSend error:%@",error);
                                }];
    
}

@end
