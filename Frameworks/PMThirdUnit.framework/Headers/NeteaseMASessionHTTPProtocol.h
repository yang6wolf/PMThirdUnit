//
//  NeteaseMASessionHTTPProtocol.h
//  MobileAnalysis
//
//  Created by quankai on 16/5/11.
//  Copyright © 2016年 zhang jie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NeteaseMAHTTPProtocolDelegate.h"

@interface NeteaseMASessionHTTPProtocol : NSURLProtocol

+ (void)setDelegate:(id<NeteaseMAHTTPProtocolDelegate>)newValue;

@end
