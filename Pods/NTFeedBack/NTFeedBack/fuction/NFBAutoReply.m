//  FBAutoReply.m
//  NeteaseLottery
//
//  Created by wangbo on 13-4-17.
//  Copyright (c) 2013年 netease. All rights reserved.
//

#import "NFBAutoReply.h"
#import "NFBMessageDB.h"
#import "AFNetworking.h"
#import "NFBNotifications.h"
#import "NFBUtil.h"
#import "NFBHttpRequest.h"
#import "NFBConfig.h"

#define PARAGRAPH_SEP @"|"

#define FIRST_OFFLINE_AUTOREPLY_INDEX @"firstOfflineAuto"
#define FIRST_OFFLINE_AUTOREPLY_MSG @"亲，客服当前不在线，您的留言我们会尽快处理。在线服务时间：周一至周日(8:30-24:00)。由于近期咨询量较大，回复可能不够及时，敬请谅解！"
#define FROM_REFERENCE_TIME_STR @"08:30:00"
#define TO_REFERENCE_TIME_STR @"24:00:00"
#define EVALUATION_AUTOREPLY_MSG @"感谢您的反馈，我们将努力为您提供更好的服务！"

static NSString *const kNFBDefaultEntranceKey = @"default";

@implementation NFBAutoReplyMessage


-(id) initWithDictionary:(NSDictionary*)dictionary{
    if (self = [super init]) {
        content = [NFBUtil getStringFromDictionary:dictionary ofKey:@"message"];
        imgUrl =  [NFBUtil getStringFromDictionary:dictionary ofKey:@"imageUrl"];
        type  =  [NFBUtil getStringFromDictionary:dictionary ofKey:@"msgType"];
    }
    return self;
}

-(FeedBackMessages *)createMessage{
    FeedBackMessages *message = [[NFBMessageDB getInstance] insertMessage];
    message.imgUrl = imgUrl;
    message.content = content;
    message.time = [NSDate date];
    message.isOut = [NSNumber numberWithBool:NO];
    message.status = [NSNumber numberWithInt:FBMessageSTRecv];
    //messages
    return message;
}

@end

static NFBAutoReplySession *instance = nil;


@interface NFBAutoReplySession()
@property(nonatomic,strong) NSString *version;
@property(nonatomic,strong) NSString *onlineStatusFromServer;
@property(nonatomic,strong) NSString *floatMessageFromServer;
@property(nonatomic,strong) NSString *onlineFloatMessage;
@property(nonatomic,strong) NSString *offlineFloatMessage;
@property(nonatomic,strong) NSDictionary *autoReplyQuestions;
@end

@implementation NFBAutoReplySession

+(NFBAutoReplySession *)sharedSession{
    @synchronized(self) {
		if (instance == nil) {
			instance = [[NFBAutoReplySession alloc] init];
        }
    }
	return instance;
}

-(id)init{
    if (self = [super init]) {
        questionDict = [NSMutableDictionary dictionary];
        [self loadDataFromFile];
    }
    return self;
}

#pragma mark -
#pragma mark 常用回复
#pragma mark -
#pragma mark 读取和写入到文件
- (NSString *)getDocumentFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
	NSString *directory = [paths objectAtIndex:0];
	NSString *filename = [directory stringByAppendingString:@"/cywt2.json"]; //缓存有些改变，所以文件名改了一下
    return filename;
}


-(void)loadDataFromFile{
    [self loadDataFromBundleFile];
    [self loadDataFromDocumentFile];
}


- (void)loadDataFromBundleFile {
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"cywt" ofType:@"json"]];
    NSDictionary *dict = nil;
    if (data) {
        dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    }
    
    self.version = dict[@"version"];
    self.onlineFloatMessage = [dict objectForKey:@"floatMessage"];
    self.offlineFloatMessage = [dict objectForKey:@"floatMessageOff"];

    [self loadQuestionsFromJSONDict:dict];
    NSDictionary *config = [dict objectForKey:@"config"];
    [NFBConfig sharedConfig].helpLink = config[@"helplink"];

}

- (void)loadDataFromDocumentFile {
    NSData *data = [NSData dataWithContentsOfFile:[self getDocumentFilePath]];
    if (data) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        NSString *version = dict[@"version"];
        if (version&&[version compare:self.version options:NSNumericSearch]==NSOrderedAscending) {
            return;
        }

        [self loadQuestionsFromJSONDict:dict];
    }
}


- (NSArray *)loadQuestionsFromJSONArray:(NSArray*)array {
    if (![array isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    //get questions and answers
    NSMutableArray* questionArray =[NSMutableArray array];
    for (int i = 0; i < [array count]; i++) {
        //get questions
        NSDictionary *aquestionReply = [array objectAtIndex:i];
        [questionArray addObject:[aquestionReply objectForKey:@"question"]];
        
        //get answers
        NSMutableDictionary *aanswer = [NSMutableDictionary dictionary];
        [aanswer setObject:[aquestionReply objectForKey:@"reply"] forKey:@"message"];
        NFBAutoReplyMessage *message = [[NFBAutoReplyMessage alloc] initWithDictionary:aanswer];
        [questionDict setObject:message forKey:[aquestionReply objectForKey:@"question"]];
    }
    return questionArray;
}

- (void)loadQuestionsFromJSONDict:(NSDictionary *)jsonDict {
    id json = nil;
    if([jsonDict objectForKey:@"autoreplyTree"] != nil){
        json = [jsonDict objectForKey:@"autoreplyTree"];
    }else {
        json = [jsonDict objectForKey:@"autoreply"];
    }

    if(!json) return;

    //开始转化
    if ([json isKindOfClass:[NSArray class]]) {
        json = @{kNFBDefaultEntranceKey:json};
    }
    
    if (![json isKindOfClass:[NSDictionary class]]) {
        return;
    }

    NSDictionary *jsonDic = json;
    if(jsonDic.allKeys.count <= 0) return; //当价在为空的时候不进行替换

    [questionDict removeAllObjects];
    NSMutableDictionary *autoReplyQuestions = [NSMutableDictionary new];
    for (NSString *key in jsonDic.allKeys) {
        NSArray *questionArray = [self loadQuestionsFromJSONArray:jsonDic[key]];
        if (questionArray) {
            autoReplyQuestions[key] = questionArray;
        }
    }
 
    self.autoReplyQuestions = autoReplyQuestions;
}


-(BOOL)isOnline{
    if([self.onlineStatusFromServer length]>0){//从服务器拿到在线数据
        return ([self.onlineStatusFromServer intValue]>0);
    }else{//本地计算
        NSDate *nowDate = [NSDate date];
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:nowDate];// 1 = Sunday ... 7 = Saturday
        NSInteger index =  [components weekday];
        if(index >= 1 && index <=7){//周一至周日
        
            unsigned int unitFlags = NSYearCalendarUnit|NSMonthCalendarUnit| NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
            NSDateComponents *nowDateComponents = [ [NSCalendar currentCalendar] components:unitFlags fromDate:nowDate];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
        
            NSString* timeStr;
            timeStr = [NSString stringWithFormat:@"%ld-%ld-%ld %@",
                       (long)[nowDateComponents day],
                       (long)[nowDateComponents month],
                       (long)[nowDateComponents year],
                       FROM_REFERENCE_TIME_STR];
            
            NSDate *referenceFromDate = [dateFormatter dateFromString:timeStr];
            timeStr = [NSString stringWithFormat:@"%ld-%ld-%ld %@",
                       (long)[nowDateComponents day],
                       (long)[nowDateComponents month],
                       (long)[nowDateComponents year],
                       TO_REFERENCE_TIME_STR];
            
            NSDate *referenceToDate = [dateFormatter dateFromString:timeStr];
        
            if(([nowDate compare:referenceFromDate] !=NSOrderedAscending) && ([nowDate compare:referenceToDate] != NSOrderedDescending)){
                return YES;
            }else{
                return NO;
            }
        }else{
            return NO;
        }
    }
}


- (NSString*)floatMessage {
    if (self.onlineStatusFromServer.length>0&&self.floatMessageFromServer.length>0) {
        return self.floatMessageFromServer;
    } else if ([self isOnline]) {
        return self.onlineFloatMessage;
    } else {
        return self.offlineFloatMessage;
    }
}

-(BOOL) canAutoReplyQuestion:(NSString *)question{
    if ([questionDict objectForKey:question]) {
        return YES;
    }
    return NO;
}

-(FeedBackMessages *)createAnswerForQuestion:(NSString *)question{
    if ([questionDict objectForKey:question]) {
        NFBAutoReplyMessage *msg = [questionDict objectForKey:question];
        
/*#warning 测试数据，增加跳转链接
        FeedBackMessages *message = [msg createMessage];
        {
            NSString *url;
            NSInteger index = [key integerValue];
            switch (index) {
                case 1:
                    url = @"ntescaipiao://luckyTab"; break;
                case 2:
                    url = @"ntescaipiao://couponList";break;
                case 3:
                    url = @"ntescaipiao://bet?g=jczq_bf_p&mid=201308014024";break;
                case 4:
                    url = @"ntescaipiao://bet?g=jczq_bcspf_p&mid=201308014024";break;
                case 5:
                    url = @"ntescaipiao://bet?g=jczq_mix_p&mid=201308014024";break;
                default:
                    break;
            }
            if (url) {
                message.url = url;
                message.content = [message.content stringByAppendingString:url];
            }
            return message;
        }
*/
    
        return [msg createMessage];
    }
    return nil;
}

-(FeedBackMessages *)createOfflineMessage {
    //不在线服务时间段内，首次发送消息时，自动回复用户
    NSMutableDictionary *aanswer = [NSMutableDictionary dictionary];
    [aanswer setObject:FIRST_OFFLINE_AUTOREPLY_MSG forKey:@"message"];
    NFBAutoReplyMessage *message = [[NFBAutoReplyMessage alloc] initWithDictionary:aanswer];
    return [message createMessage];
}

-(FeedBackMessages *)createEvaluationMessage
{
    NSMutableDictionary *aanswer = [NSMutableDictionary dictionary];
    [aanswer setObject:EVALUATION_AUTOREPLY_MSG forKey:@"message"];
    NFBAutoReplyMessage *message = [[NFBAutoReplyMessage alloc] initWithDictionary:aanswer];
    return [message createMessage];
}

- (void)refreshAutoReplyMessages{
    [NFBHttpRequest startRequestWithUrl:[[NFBConfig sharedConfig].host stringByAppendingString:@"/admin/getAutoReplyQuestionsAndFloatMessage.do?referer=all"]
                                 params:nil
             completionBlockWithSuccess:^(NSURLSessionDataTask *dataTask, id responseObject) {
                 if ([responseObject isKindOfClass:[NSData class]]) {
                     NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:NULL];
                     if(dic && [[dic objectForKey:@"result"] integerValue] == 0){// 0正常， -1 是没取到任何数据
                         NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc] init];
                         [mutableDict addEntriesFromDictionary:dic];
                         if (self.version ) {
                             [mutableDict setObject:self.version forKey:@"version"];
                         }
                         [[NSJSONSerialization dataWithJSONObject:mutableDict options:0 error:NULL]
                                                      writeToFile:[self getDocumentFilePath]
                                                       atomically:YES];
                         
                         

                         self.floatMessageFromServer = [NFBUtil getStringFromDictionary:mutableDict ofKey:@"floatMessage"];
                         self.onlineStatusFromServer = [NFBUtil getStringFromDictionary:mutableDict ofKey:@"ifOnline"];
                         [self loadQuestionsFromJSONDict:mutableDict];
                         [[NSNotificationCenter defaultCenter] postNotificationName:NFBAutoReplySessionDidRefreshed object:nil];
                     }
                 }

             }
                                failure:nil];
}

- (NSArray *)autoReplyQuestionsWithEntrance:(NSString *)entrance
{
    entrance =  entrance.length>0?entrance:kNFBDefaultEntranceKey;
    NSArray *questions = self.autoReplyQuestions[entrance];
    
    if (!questions) {
        questions = self.autoReplyQuestions[kNFBDefaultEntranceKey];
    }
    
    if (!questions) {
        questions = [NSArray new];
    }
    
    return questions;
}

@end
