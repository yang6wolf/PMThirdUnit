//
//  FeedBackMessages.h
//  NeteaseLottery
//
//  Created by wangbo on 13-3-21.
//  Copyright (c) 2013年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>



typedef enum NFBMessageStatus {
    FBMessageSTNone, //默认标记
    FBMessageSTSending, //消息正在发送成功
    FBMessageSTSendFailed, //消息失败
    FBMessageSTSendSuccess, //消息发送成功
    FBMessageSTRecv, //客服端自动回复消息收到
    FBMessageSTResend //消息重发
}FBMessageStatus;

@interface FeedBackMessages : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * ssn;
@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * isOut;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * imgUrl;
@property (nonatomic, retain) NSNumber * hasRead;
@property (nonatomic, retain) NSString * msgid;
@property (nonatomic, retain) NSString * url;

@end
