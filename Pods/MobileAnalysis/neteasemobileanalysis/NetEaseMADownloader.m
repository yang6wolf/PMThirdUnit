//
//  NetEaseMADownloader.m
//  movie163
//
//  Created by Long Huihu on 13-6-27.
//  Copyright (c) 2013年 netease. All rights reserved.
//

#import "NetEaseMADownloader.h"
#import "NetEaseMAUtils.h"
#import "NetEaseMACache.h"
#import "JSONKit.h"
#import "NetEaseMobileAgent.h"

#define MOBILE_DOWNLOAD_URL @"/cst?appcode="
#define MAX_RETRY 2

@implementation NetEaseMADownloader {
    NSString *_appid;
    NSURLConnection *_downloadConnection;		// The connection which uploads the bits
    NSMutableData *_responseData;
    
    NSDictionary *_sessionTrunk; //用于重试
    NSTimer *_refreshTimer;
    NSInteger _retryCounter;
    
    NSInteger _statusCode;
}

-(void)complete:(BOOL)success
{
    _downloadConnection=nil;
    _isDownloading=NO;
    _isLastDownloadSuccess = success;
    
    long refreshDelay = 24*60*60; //默认24小时后更新
    NSMutableDictionary *onlineConfig = [NSMutableDictionary dictionary];
    if (success) {
        _retryCounter = MAX_RETRY;
        
        if (_responseData) {
            NSArray *configArray = [_responseData objectFromJSONData];
            _responseData = nil;
            
            if ([configArray isKindOfClass:[NSArray class]]) {
                for (NSDictionary *configDict in configArray) {
                    NSString * configKey = [configDict neteasema_stringValueForKey:@"pname"];
                    NSObject * value = [configDict objectForKey:@"pvalue"];
                    NSInteger delay = [[configDict objectForKey:@"prefresh"] intValue]*60*60;
                    if (configKey&&value) {
                        [onlineConfig setValue:value forKey:configKey];
                    }
                    if (delay>0) {
                        refreshDelay = MIN(refreshDelay, delay);
                    }
                }
            }
        }
    } else {
        _retryCounter --;
        if (_retryCounter>0) {
            refreshDelay = 30; //失败后30秒重试
        }
    }

    _refreshTimer  = [NSTimer scheduledTimerWithTimeInterval:refreshDelay target:self
                                                    selector:@selector(refreshTimerFired) userInfo:nil repeats:NO];
    
    [self.delegate netEaseMADownloaderComplete:success withResponse:onlineConfig];
}

- (void)refreshTimerFired {
    [self requestDownload];
}

-(id)initWithAppid:(NSString *)appid
{
    if(self=[super init])
    {
        _appid=appid;
        _downloadConnection=nil;
        _isDownloading=NO;
    }
    return self;
}

-(void)downloadWithSessionTrunk:(NSDictionary*)sessionTrunk
{
    if (!sessionTrunk) {
        return;
    }
    _sessionTrunk = sessionTrunk;
    _retryCounter = MAX_RETRY;
    [self requestDownload];
}

- (void)requestDownload {
    [_refreshTimer invalidate];
    
    if(_isDownloading) {
        return;
    }
    
    _isDownloading=YES;
    
    NSArray *jsonArray = @[_sessionTrunk];
    NSString *sessionText = [NetEaseMaUtils zipAndEncrypt:[jsonArray JSONData]];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@",[[NetEaseMobileAgent sharedInstance] getAnalysisHost],MOBILE_DOWNLOAD_URL,_appid];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:60.0];
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setObject:_appid forKey:@"p"];
    [dict setObject:sessionText forKey:@"d"];
    
    NSString *strJson = [dict JSONString];
    NSData *bodyData=[strJson dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPMethod:@"POST"];//POST请求
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)([bodyData length])] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:bodyData];
    
    _downloadConnection = [NSURLConnection connectionWithRequest:request delegate:self];
    [_downloadConnection start];
}


#pragma mark NSURL NSURLConnectionDelegate methods
- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSHTTPURLResponse*)response
{
    _statusCode = [response statusCode];
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
    if (!_responseData) {
        _responseData = [[NSMutableData alloc] init];
    }
    [_responseData appendData:data];
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    NETEASE_LOG(@"NetEaseMADownloader error");
    [self complete:NO];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NETEASE_LOG(@"NetEaseMADownloader complete");
    if (_statusCode<200||_statusCode>=300) {
        [self complete:NO];
    } else {
        [self complete:YES];
    }
}

@end
