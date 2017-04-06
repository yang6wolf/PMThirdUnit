//
//  LDRemoteCommandResultHandler.h
//  NeteaseLottery
//
//  Created by david on 16/4/28.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CompletedBlock)(BOOL result,NSDictionary *response,NSError *error);

@interface LDRemoteCommandResultHandler : NSObject

- (void)uploadExecuteResultToFile:(NSString *)fileName content:(NSString *)content completed:(CompletedBlock) completedBlock;

@end
