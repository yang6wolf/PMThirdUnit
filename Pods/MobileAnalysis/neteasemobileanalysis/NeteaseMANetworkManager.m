//
//  NeteaseMAIPUpdater.m
//  MobileAnalysis
//
//  Created by  龙会湖 on 8/18/14.
//  Copyright (c) 2014 zhang jie. All rights reserved.
//

#import "NeteaseMANetworkManager.h"
#import "Reachability.h"
#import "NetEaseMobileAgent.h"

#define IP_REFRESH_ADDRESS @"/ip"

@interface NeteaseMANetworkManager()
@property(nonatomic,strong,readwrite) NSString *ip;
@end

@implementation NeteaseMANetworkManager {
    Reachability* _internetReachable;
    
    NSURLConnection *_ipRefreshConnection;
    NSMutableData *_responseData;
    NSInteger _statusCode;
}

static NetworkStatus _networkStatus;

+ (NetworkStatus)networkStatus {
    return _networkStatus;
}

- (void)start {
    if  (!_internetReachable) {
        _internetReachable=[Reachability reachabilityForInternetConnection];
        [_internetReachable startNotifier];
        _networkStatus = _internetReachable.currentReachabilityStatus;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(networkStatusChanged)
                                                     name:kReachabilityChangedNotification
                                                   object:_internetReachable];
        [self refreshIP];
    }
}


- (void)networkStatusChanged {
    NetworkStatus status = [_internetReachable currentReachabilityStatus];
    if (_networkStatus==NotReachable
        &&status!=NotReachable) {
        [self.delegate networkManagerNetworkBecomeAwailable:self];
    }
    if (_networkStatus!=status) {
        [self refreshIP];
    }
    _networkStatus = status;
}

- (void)refreshIP {
    if (_ipRefreshConnection) {
        return;
    }
    _ipRefreshConnection = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[[NetEaseMobileAgent sharedInstance] getAnalysisHost],IP_REFRESH_ADDRESS]]]
                                                         delegate:self];
    [_ipRefreshConnection start];
}

-(void)refreshComplete:(BOOL)susccess
{
    NSData *ipData = _responseData;
    
    _ipRefreshConnection=nil;
    _responseData = nil;
    _statusCode = 0;
 
    NSString *ip = [[NSString alloc] initWithData:ipData encoding:NSUTF8StringEncoding];
    ip = [ip stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (ip) {
        self.ip = ip;
        [self.delegate networkManagerIPUpdated:self];
    }

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
    [self refreshComplete:NO];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (_statusCode<200||_statusCode>=300) {
        [self refreshComplete:NO];
    } else {
        [self refreshComplete:YES];
    }
}


@end
