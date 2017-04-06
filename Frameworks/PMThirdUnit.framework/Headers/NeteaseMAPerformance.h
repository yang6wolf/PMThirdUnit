//
//  NeteaseMAPerformance.h
//  MobileAnalysis
//
//  Created by  龙会湖 on 8/15/14.
//  Copyright (c) 2014 zhang jie. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NeteaseMAPerformanceDelegate <NSObject>
- (BOOL)neteaseMAPerformanceShouldProbeUrl:(NSURL*)url;
- (NSString *)neteaseMAPerformanceGetIPbyDomain:(NSString *)domain;
@end

@interface NeteaseMAPerformance : NSObject
@property(nonatomic,strong) NSString *ip;
@property(nonatomic,weak) id<NeteaseMAPerformanceDelegate> delegate;

+ (NeteaseMAPerformance*)startWithAppId:(NSString*)appId deviceId:(NSString*)deviceId channel:(NSString*)channel;

- (void)addControllerRecord:(NSDictionary*)dict;
- (void)clearRecords;
- (NSDictionary*)convertAllRecordsToDataTrunk;
- (void)setChannel:(NSString *)channel;
@end
