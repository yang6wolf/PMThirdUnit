//
//  NeteaseMAHTTPProtocolDelegate.h
//  MobileAnalysis
//
//  Created by 庞辉 on 12/18/15.
//  Copyright © 2015 zhang jie. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NeteaseMAHTTPProtocolDelegate <NSObject>
/**
 *  是否需要探测此url，这个调用不保证发生在主线程
 */
- (bool)protocolShouldHandleURL:(NSURL*)url;
- (void)protocolDidCompleteURL:(NSURL*)url from:(NSTimeInterval)startTime to:(NSTimeInterval)endTime withStatusCode:(NSInteger)code;
- (void)protocolDidCompleteURL:(NSURL*)url from:(NSTimeInterval)startTime to:(NSTimeInterval)endTime rxBytes:(NSUInteger)rxBytes txBytes:(NSUInteger)txBytes withStatusCode:(NSInteger)code;
- (void)protocolDidCompleteURL:(NSURL*)url from:(NSTimeInterval)startTime to:(NSTimeInterval)endTime withError:(NSError*)error;
- (void)protocolDidCompleteURL:(NSURL*)url from:(NSTimeInterval)startTime to:(NSTimeInterval)endTime rxBytes:(NSUInteger)rxBytes txBytes:(NSUInteger)txBytes netDetailTime:(NSDictionary *)detailTime withStatusCode:(NSInteger)code;

@optional
/**
 *  是否需要探测某个host的dns监控
 */
- (BOOL)protocolShouldDNSResolve:(NSString *)host;
- (void)protocolDidCompleteDNSResolve:(NSString *)host dnsIP:(NSString *)dnsIP dnsResolveTime:(int)dnsResolveTime;

/**
 *  通过域名置换IP
 */
- (NSString *)protocolGetIPbyDomain:(NSString *)domain;

@end
