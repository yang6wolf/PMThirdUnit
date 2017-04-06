//
//  NFBNetworkDiagnoser.h
//  NTFeedBack
//
//  Created by  龙会湖 on 11/28/14.
//  Copyright (c) 2014 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NFBNetworkDiagnoser : NSObject
+ (instancetype)sharedInstance;
- (void)start;
@end
