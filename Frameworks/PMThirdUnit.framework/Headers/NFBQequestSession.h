//
//  FBQequestSession.h
//  NeteaseLottery
//
//  Created by wangbo on 13-3-21.
//  Copyright (c) 2013年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedBackMessages.h"
#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, NFBPollingMessageMode) {
    NFBPollingMessageNone = 0,
    NFBPollingMessageSlow,
    NFBPollingMessageFast
};

@class NFBQequestSession;

@interface NFBQequestSession : NSObject

+ (NFBQequestSession *)session;

@property(nonatomic,assign) NSUInteger unreadNums;
@property(nonatomic,readonly) NFBPollingMessageMode pollingMode;
@property(nonatomic,readonly) NSMutableDictionary *uploadProgresses;

- (void)startPollMessage:(NFBPollingMessageMode)mode;
- (void)refreshMessageRightnow;

- (void)sendMessage:(FeedBackMessages *)message;
- (void)sendMessageWithContent:(NSString*)content andImg:(UIImage*)img andTitle:(NSString*)title;
- (void)sendAutoReplayQuestion:(NSString *)question;

- (BOOL)isMessageSending:(FeedBackMessages *)message;

#pragma mark 测试专属代码，直接发送反馈消息不经过CoreData
-(void)debugSend:(NSString *)content title:(NSString *)title accountId:(NSString*)accountId;

@end



