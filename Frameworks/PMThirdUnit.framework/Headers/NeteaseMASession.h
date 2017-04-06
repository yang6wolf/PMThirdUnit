//
//  NeteaseMASession.h
//  MobileAnalysis
//
//  Created by  龙会湖 on 8/13/14.
//  Copyright (c) 2014 zhang jie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NeteaseMASession : NSObject
+ (NeteaseMASession*)startSession:(NSString*)appId deviceId:(NSString*)deviceId channel:(NSString*)channel;
- (NSDictionary*)getSessionInfo;
- (NSDictionary*)endSession;

- (void)setURSID:(NSString*)ursId;
- (void)setExtra:(NSString*)extra;
- (void)setChannel:(NSString *)channel;

- (void)addEvent:(NSString *)name param:(NSString *)param extra:(NSString *)extra;
- (void)addCrashLog:(id)crash;
@end
