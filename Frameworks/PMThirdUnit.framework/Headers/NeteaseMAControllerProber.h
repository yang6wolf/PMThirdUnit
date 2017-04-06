//
//  NeteaseMAControllerProber.h
//  MobileAnalysis
//
//  Created by  龙会湖 on 8/14/14.
//  Copyright (c) 2014 zhang jie. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CONTROLLER_LOAD_TIME_LIMIT 5.0

@class NeteaseMAControllerProber;

typedef NS_ENUM(NSUInteger, NeteaseMAControllerEvent) {
    NeteaseMAControllerCreate,
    NeteaseMAControllerOpen,
    NeteaseMAControllerClose,
    NeteaseMAControllerDestroy
};

@protocol NeteaseMAControllerProberDelegate <NSObject>
- (void)controllerProber:(NeteaseMAControllerProber*)probe didGetPeformanceRecord:(NSDictionary*)dict;
- (void)controllerProber:(NeteaseMAControllerProber*)probe didGetEvent:(NeteaseMAControllerEvent)event forController:(UIViewController*)controller;
@end

@interface NeteaseMAControllerProber : NSObject
@property(nonatomic,weak) id<NeteaseMAControllerProberDelegate> delegate;
- (void)start;
@end


@interface NeteaseMAViewControllerRecord : NSObject
@property(nonatomic,strong) NSString *controllerName;
@property(nonatomic) NSTimeInterval willloadTime;
@property(nonatomic) NSTimeInterval didloadTime;
@property(nonatomic) NSTimeInterval appearTime;
@property(nonatomic) BOOL firstAppear;
- (BOOL)isExpired;
- (NSDictionary*)toDictionary;
@end