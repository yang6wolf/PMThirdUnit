//
//  NTProtocolProxy.h
//  ProxyTest
//
//  Created by  龙会湖 on 14-7-21.
//  Copyright (c) 2014年 netease. All rights reserved.
//

#import "NFBAppearance.h"

@interface NFBAppearanceProxy : NSProxy<NFBAppearance>
+ (NFBAppearanceProxy*)sharedAppearance;
- (void)setDefaultAppearance:(id<NFBAppearance>)defaultAppearance;
- (void)setCustomAppearance:(id<NFBAppearance>)customAppearance;
- (void)clearProxy;
@end
