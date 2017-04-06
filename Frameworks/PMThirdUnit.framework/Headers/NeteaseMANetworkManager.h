//
//  NeteaseMAIPUpdater.h
//  MobileAnalysis
//
//  Created by  龙会湖 on 8/18/14.
//  Copyright (c) 2014 zhang jie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@class NeteaseMANetworkManager;

@protocol NeteaseMANetworkManagerDelegate <NSObject>
- (void)networkManagerNetworkBecomeAwailable:(NeteaseMANetworkManager*)manager;
- (void)networkManagerIPUpdated:(NeteaseMANetworkManager*)manager;
@end

@interface NeteaseMANetworkManager : NSObject
@property(nonatomic,weak) id<NeteaseMANetworkManagerDelegate> delegate;
@property(nonatomic,strong,readonly) NSString *ip;
+ (NetworkStatus)networkStatus;
- (void)start;
@end
