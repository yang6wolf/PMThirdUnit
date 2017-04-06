//
//  LDRemoteCommandResultHandler.m
//  NeteaseLottery
//
//  Created by david on 16/4/28.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "LDRemoteCommandResultHandler.h"
#import "LDRemoteCommandConfig.h"
#import "LDRemoteCommandDefine.h"

@interface LDRemoteCommandResultHandler ()

@property (nonatomic, copy) CompletedBlock completedBlock;

@end

@implementation LDRemoteCommandResultHandler

- (void)uploadExecuteResultToFile:(NSString *)fileName content:(NSString *)content completed:(CompletedBlock) completedBlock
{
    NSAssert([[NSThread currentThread] isMainThread], @"NSURLConnection发起异步连接需在开启runloop线程中");
    
    if (!fileName || !content) {
        return;
    }
    
    self.completedBlock = completedBlock;
    
    NSString *uploadUrl = [NSString stringWithFormat:@"%@%@", [LDRemoteCommandConfig sharedConfig].upLoadHost, @"/custom_log"];
    NSString *body = [NSString stringWithFormat:@"name=%@&zip=false&data=%@",URLStringEncode(fileName),URLStringEncode(content)];
    NSData *bodyData = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:uploadUrl] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[bodyData length]] forHTTPHeaderField:@"Content-Length"];
    
    [request setHTTPBody:bodyData];
    [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark NSURL NSURLConnectionDelegate methods
- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSHTTPURLResponse*)response
{
    
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
    
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    if (self.completedBlock) {
        self.completedBlock(NO,nil,error);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (self.completedBlock) {
        self.completedBlock(YES,nil,nil);
    }
}

@end
