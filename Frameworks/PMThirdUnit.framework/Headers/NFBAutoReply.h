//
//  FBAutoReply.h
//  NeteaseLottery
//
//  Created by wangbo on 13-4-17.
//  Copyright (c) 2013年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FeedBackMessages;

@interface NFBAutoReplyMessage : NSObject{
    NSString *content;
    NSString *type;
    NSString *imgUrl;
}


-(id) initWithDictionary:(NSDictionary*)dictionary;

@end

@interface NFBAutoReplySession : NSObject{
    NSMutableDictionary *questionDict;
}

@property(nonatomic,readonly) BOOL isOnline;
@property(nonatomic,strong,readonly) NSString *floatMessage;
@property(nonatomic) BOOL shouldAutoReplyToCustomQuestion;

+(NFBAutoReplySession *)sharedSession;
- (BOOL)canAutoReplyQuestion:(NSString *)question;
- (FeedBackMessages *)createAnswerForQuestion:(NSString *)question;
-(FeedBackMessages *)createOfflineMessage;
-(FeedBackMessages *)createEvaluationMessage;
- (void)refreshAutoReplyMessages;

- (NSArray *)autoReplyQuestionsWithEntrance:(NSString *)entrance;

@end



