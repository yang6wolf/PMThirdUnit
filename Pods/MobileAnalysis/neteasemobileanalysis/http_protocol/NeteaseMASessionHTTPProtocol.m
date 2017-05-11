//
//  NeteaseMASessionHTTPProtocol.m
//  MobileAnalysis
//
//  Created by quankai on 16/5/11.
//  Copyright © 2016年 zhang jie. All rights reserved.
//

#import "NeteaseMASessionHTTPProtocol.h"
#import "CanonicalRequest.h"
#import "CacheStoragePolicy.h"
#import "QNSURLSessionDemux.h"
#import "NSURLSessionConfiguration+protocol.h"
#import "NetEaseMobileAgent.h"
#import "NSMutableDictionary+LDSafetyDictionary.h"

typedef void (^ChallengeCompletionHandler)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * credential);

@interface NeteaseMASessionHTTPProtocol ()<NSURLSessionDataDelegate>

@property (atomic, strong, readwrite) NSThread *                        clientThread;       ///< The thread on which we should call the client.

/*! The run loop modes in which to call the client.
 *  \details The concurrency control here is complex.  It's set up on the client
 *  thread in -startLoading and then never modified.  It is, however, read by code
 *  running on other threads (specifically the main thread), so we deallocate it in
 *  -dealloc rather than in -stopLoading.  We can be sure that it's not read before
 *  it's set up because the main thread code that reads it can only be called after
 *  -startLoading has started the connection running.
 */

@property (atomic, copy,   readwrite) NSArray *                         modes;
@property (atomic, assign, readwrite) NSTimeInterval                    startTime;          ///< The start time of the request; written by client thread only; read by any thread.
@property (atomic, assign, readwrite) NSTimeInterval                    endTime;
@property (atomic, strong, readwrite) NSURLSessionDataTask *            task;               ///< The NSURLSession task for that request; client thread only.
@property (atomic, strong, readwrite) NSURLAuthenticationChallenge *    pendingChallenge;
@property (atomic, copy,   readwrite) ChallengeCompletionHandler        pendingChallengeCompletionHandler;  ///< The completion handler that matches pendingChallenge; main thread only.

@property (atomic, strong, readwrite) NSURLRequest *                    actualRequest;      // client thread only
@property (atomic, strong) NSURLResponse *response;
@property (atomic, strong) NSError *error;

@property (atomic) NSUInteger rxBytes;
@property (atomic) NSUInteger txBytes;

@property (nonatomic, assign) long long dnsStartTime;
@property (nonatomic, assign) long long dnsEndTime;
@property (nonatomic, assign) long long sslHandshakeStartTime;
@property (nonatomic, assign) long long sslHandshakeEndTime;
@property (nonatomic, assign) long long tcpStartTime;
@property (nonatomic, assign) long long tcpEndTime;
@property (nonatomic, assign) long long readStartTime;
@property (nonatomic, assign) long long readEndTime;
@property (nonatomic, assign) long long writeStartTime;
@property (nonatomic, assign) long long writeEndTime;

@property (nonatomic, strong) NSDictionary *netDetailDic;


@property (atomic) BOOL isWebCoreThread;
@end

@implementation NeteaseMASessionHTTPProtocol

static id<NeteaseMAHTTPProtocolDelegate> sDelegate;

+ (void)load
{
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
        [NSURLProtocol registerClass:self];
        [NSURLSessionConfiguration hookDefaultSessionConfiguration];        
    }
}

+ (id<NeteaseMAHTTPProtocolDelegate>)delegate
// See comment in header.
{
    id<NeteaseMAHTTPProtocolDelegate> result;
    
    @synchronized (self) {
        result = sDelegate;
    }
    return result;
}

+ (void)setDelegate:(id<NeteaseMAHTTPProtocolDelegate>)newValue
{
    @synchronized (self) {
        sDelegate = newValue;
    }
}

+ (QNSURLSessionDemux *)sharedDemux
{
    static dispatch_once_t      sOnceToken;
    static QNSURLSessionDemux * sDemux;
    dispatch_once(&sOnceToken, ^{
        NSURLSessionConfiguration *     config;
        
        config = [NSURLSessionConfiguration defaultSessionConfiguration];
        // You have to explicitly configure the session to use your own protocol subclass here
        // otherwise you don't see redirects <rdar://problem/17384498>.
        
        //此处用来配置需要使用的protocols
        config.protocolClasses = [[NetEaseMobileAgent sharedInstance] getAllProtocolClassNames];
        sDemux = [[QNSURLSessionDemux alloc] initWithConfiguration:config];
    });
    return sDemux;
}

#pragma mark * NSURLProtocol overrides

static NSString * kOurRecursiveRequestFlagProperty = @"com.apple.dts.NeteaseMAHTTPProtocol";

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
// An override of an NSURLProtocol method.  We claim all HTTPS requests that don't have
// kOurRequestProperty attached.
//
// This can be called on any thread, so we have to be careful what we touch.
{
    BOOL        shouldAccept;
    NSURL *     url;
    NSString *  scheme;
    
    // Check the basics.  This routine is extremely defensive because experience has shown that
    // it can be called with some very odd requests <rdar://problem/15197355>.
    
    shouldAccept = (request != nil);
    if (shouldAccept) {
        url = [request URL];
        shouldAccept = (url != nil);
    }
    
    //自定义url是否拦截
    if (shouldAccept) {
        shouldAccept = ([sDelegate protocolShouldHandleURL:url]);
    }

    // Decline our recursive requests.
    
    if (shouldAccept) {
        shouldAccept = ([self propertyForKey:kOurRecursiveRequestFlagProperty inRequest:request] == nil);
    }
    
    // Get the scheme.
    
    if (shouldAccept) {
        scheme = [[url scheme] lowercaseString];
        shouldAccept = (scheme != nil);
    }
    
    // Look for "http" or "https".
    //
    // Flip either or both of the following to YESes to control which schemes go through this custom
    // NSURLProtocol subclass.
    
    if (shouldAccept) {
        shouldAccept = YES && [scheme isEqual:@"http"];
        if ( ! shouldAccept ) {
            shouldAccept = YES && [scheme isEqual:@"https"];
        }
    }
    
    //过滤host为空的情况
    if (shouldAccept) {
        shouldAccept = YES && ([url host].length > 0);
    }
    
    if (shouldAccept) {
        shouldAccept = YES && (![[url host] isEqualToString:@"119.29.29.229"]);
    }
    
    return shouldAccept;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
// An override of an NSURLProtocol method.   Canonicalising a request is quite complex,
// so all the heavy lifting has been shuffled off to a separate module.
//
// This can be called on any thread, so we have to be careful what we touch.
{
    NSURLRequest *      result;
    
    NSCAssert(request != nil,@"request == nil");

    result = NeteaseMACanonicalRequestForRequest(request);
    return result;
}

- (void)dealloc
// This can be called on any thread, so we have to be careful what we touch.
{
    NSCAssert(self->_task == nil,@"self->_task != nil");                     // we should have cleared it by now
    NSCAssert(self->_pendingChallenge == nil,@"self->_pendingChallenge != nil");         // we should have cancelled it by now
    NSCAssert(self->_pendingChallengeCompletionHandler == nil,@"self->_pendingChallengeCompletionHandler != nil");    // we should have cancelled it by now
}

- (void)startLoading
// An override of an NSURLProtocol method.   At this point we kick off the process
// of loading the URL via NSURLConnection.
//
// The thread that this is called on becomes the client thread.
{
    NSMutableURLRequest *   recursiveRequest;
    NSMutableArray *        calculatedModes;
    NSString *              currentMode;
    
    // At this point we kick off the process of loading the URL via NSURLSession.
    // The thread that calls this method becomes the client thread.
    
    NSCAssert(self.clientThread == nil,@"self.clientThread != nil");           // you can't call -startLoading twice
    NSCAssert(self.task == nil,@"self.task != nil");
    
    // Calculate our effective run loop modes.  In some circumstances (yes I'm looking at
    // you UIWebView!) we can be called from a non-standard thread which then runs a
    // non-standard run loop mode waiting for the request to finish.  We detect this
    // non-standard mode and add it to the list of run loop modes we use when scheduling
    // our callbacks.  Exciting huh?
    //
    // For debugging purposes the non-standard mode is "WebCoreSynchronousLoaderRunLoopMode"
    // but it's better not to hard-code that here.
    
    NSCAssert(self.modes == nil,@"self.modes != nil");
    calculatedModes = [NSMutableArray array];
    [calculatedModes addObject:NSDefaultRunLoopMode];
    currentMode = [[NSRunLoop currentRunLoop] currentMode];
    if ( (currentMode != nil) && ! [currentMode isEqual:NSDefaultRunLoopMode] ) {
        [calculatedModes addObject:currentMode];
    }
    self.modes = calculatedModes;
    NSCAssert([self.modes count] > 0,@"[self.modes count] <= 0");
    
    // Create new request that's a clone of the request we were initialised with,
    // except that it has our 'recursive request flag' property set on it.
    
    recursiveRequest = [[self request] mutableCopy];
    NSCAssert(recursiveRequest != nil,@"recursiveRequest == nil");
    
    self.startTime = [NSDate timeIntervalSinceReferenceDate];
    self.rxBytes = 0;
    self.txBytes = 0;
    
    NSString *originalUrl = [recursiveRequest.URL absoluteString];
    NSURL *url = [NSURL URLWithString:originalUrl];
    
    //host不为空 且 不等于appbi的host
    //因为appbi要用来控制IP模式是否打开
    if (url.host.length> 0 && ![originalUrl containsString:[[NetEaseMobileAgent sharedInstance] getAnalysisHost]]) {
        if ([[self class] delegate] && [[[self class] delegate] respondsToSelector:@selector(protocolGetIPbyDomain:)]) {
            NSString *ip = [[[self class] delegate] protocolGetIPbyDomain:url.host];
            
            if (ip && ![ip isEqualToString:url.host]) {
                // 通过HTTPDNS获取IP成功，进行URL替换和HOST头设置
                NSLog(@"Get IP(%@) for host(%@) from HTTPDNS Successfully!", ip, url.host);
                NSRange hostFirstRange = [originalUrl rangeOfString:url.host];
                if (NSNotFound != hostFirstRange.location) {
                    NSString *newUrl = [originalUrl stringByReplacingCharactersInRange:hostFirstRange withString:ip];
                    NSLog(@"New URL: %@", newUrl);
                    recursiveRequest.URL = [NSURL URLWithString:newUrl];
                    [recursiveRequest setValue:url.host forHTTPHeaderField:@"host"];
                }
            }

        }
    }

    [[self class] setProperty:@YES forKey:kOurRecursiveRequestFlagProperty inRequest:recursiveRequest];

    self.actualRequest = recursiveRequest;
    // Latch the thread we were called on, primarily for debugging purposes.
    
    self.clientThread = [NSThread currentThread];
    self.isWebCoreThread = (self.clientThread && self.clientThread.name && [self.clientThread.name hasPrefix:@"WebCore: CFNetwork Loader"]) ? YES:NO;

    // Once everything is ready to go, create a data task with the new request.

    self.task = [[[self class] sharedDemux] dataTaskWithRequest:recursiveRequest delegate:self modes:self.modes];
    NSCAssert(self.task != nil,@"self.task == nil");
    
    [self.task resume];
}

- (void)stopLoading
// An override of an NSURLProtocol method.   We cancel our load.
//
// Expected to be called on the client thread.
{
    self.endTime = [NSDate timeIntervalSinceReferenceDate];
    
    //FIX iphone4s-iphone4+ios6-ios7machine webcore thread crash, don't log
    if(self.clientThread == nil && self.isWebCoreThread){
        self.task = nil;
        self.modes = nil;
        return;
    }

    NSCAssert(self.clientThread != nil,@"self.clientThread == nil");           // someone must have called -startLoading
    
    // Check that we're being stopped on the same thread that we were started
    // on.  Without this invariant things are going to go badly (for example,
    // run loop sources that got attached during -startLoading may not get
    // detached here).
    //
    // I originally had code here to skip over to the client thread but that
    // actually gets complex when you consider run loop modes, so I've nixed it.
    // Rather, I rely on our client calling us on the right thread, which is what
    // the following NSCAssert is about.
    
    NSCAssert([NSThread currentThread] == self.clientThread,@"[NSThread currentThread] != self.clientThread");
    
    if (self.task != nil) {
        [self.task cancel];
        self.task = nil;
        // The following ends up calling -URLSession:task:didCompleteWithError: with NSURLErrorDomain / NSURLErrorCancelled,
        // which specificallys traps and ignores the error.
    }
    // Don't nil out self.modes; see property declaration comments for a a discussion of this.
    
    NSURL * requestUrl = self.actualRequest.URL;
    
    if (self.response) {
        NSInteger statusCode = [(NSHTTPURLResponse*)self.response statusCode];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.netDetailDic) {
                [[[self class] delegate] protocolDidCompleteURL:requestUrl from:self.startTime to:self.endTime rxBytes:self.rxBytes txBytes:self.txBytes netDetailTime:self.netDetailDic withStatusCode:statusCode];
            } else {
                [[[self class] delegate] protocolDidCompleteURL:requestUrl from:self.startTime to:self.endTime rxBytes:self.rxBytes txBytes:self.txBytes withStatusCode:statusCode];
            }
        });
    }
    if (self.error) {
        NSError *error = self.error;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[self class] delegate] protocolDidCompleteURL:requestUrl from:self.startTime to:self.endTime withError:error];
        });
    }
    
    
    self.actualRequest = nil;
    // Don't nil out self.modes; see the comment near the property declaration for a
    // a discussion of this.
}

- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust
                  forDomain:(NSString *)domain {
    /*
     * 创建证书校验策略
     */
    NSMutableArray *policies = [NSMutableArray array];
    if (domain) {
        [policies addObject:(__bridge_transfer id) SecPolicyCreateSSL(true, (__bridge CFStringRef) domain)];
    } else {
        [policies addObject:(__bridge_transfer id) SecPolicyCreateBasicX509()];
    }
    /*
     * 绑定校验策略到服务端的证书上
     */
    SecTrustSetPolicies(serverTrust, (__bridge CFArrayRef) policies);
    /*
     * 评估当前serverTrust是否可信任，
     * 官方建议在result = kSecTrustResultUnspecified 或 kSecTrustResultProceed
     * 的情况下serverTrust可以被验证通过，https://developer.apple.com/library/ios/technotes/tn2232/_index.html
     * 关于SecTrustResultType的详细信息请参考SecTrust.h
     */
    SecTrustResultType result;
    SecTrustEvaluate(serverTrust, &result);
    return (result == kSecTrustResultUnspecified || result == kSecTrustResultProceed);
}

#pragma mark * NSURLSession delegate callbacks

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)newRequest completionHandler:(void (^)(NSURLRequest *))completionHandler
{
    NSMutableURLRequest *    redirectRequest;
    
#pragma unused(session)
#pragma unused(task)
    NSCAssert(task == self.task,@"task != self.task");
    NSCAssert(response != nil,@"response == nil");
    NSCAssert(newRequest != nil,@"newRequest == nil");
#pragma unused(completionHandler)
    NSCAssert(completionHandler != nil,@"completionHandler == nil");
    NSCAssert([NSThread currentThread] == self.clientThread,@"[NSThread currentThread] != self.clientThread");
    
    // The new request was copied from our old request, so it has our magic property.  We actually
    // have to remove that so that, when the client starts the new request, we see it.  If we
    // don't do this then we never see the new request and thus don't get a chance to change
    // its caching behaviour.
    //
    // We also cancel our current connection because the client is going to start a new request for
    // us anyway.
    
    NSCAssert([[self class] propertyForKey:kOurRecursiveRequestFlagProperty inRequest:newRequest] != nil,@"[[self class] propertyForKey:kOurRecursiveRequestFlagProperty inRequest:newRequest] == nil");
    
    self.txBytes += [newRequest.URL.absoluteString length];
    if(![[newRequest.HTTPMethod uppercaseString] isEqualToString:@"GET"] && newRequest.HTTPBody){
        self.txBytes += newRequest.HTTPBody.length;
    }

    redirectRequest = [newRequest mutableCopy];
    [[self class] removePropertyForKey:kOurRecursiveRequestFlagProperty inRequest:redirectRequest];
    
    // Tell the client about the redirect.
    
    [[self client] URLProtocol:self wasRedirectedToRequest:redirectRequest redirectResponse:response];
    
    // Stop our load.  The CFNetwork infrastructure will create a new NSURLProtocol instance to run
    // the load of the redirect.
    
    // The following ends up calling -URLSession:task:didCompleteWithError: with NSURLErrorDomain / NSURLErrorCancelled,
    // which specificallys traps and ignores the error.
    
    [self.task cancel];
    
    [[self client] URLProtocol:self didFailWithError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil]];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *_Nullable))completionHandler {
    if (!challenge) {
        return;
    }
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    NSURLCredential *credential = nil;
    /*
     * 获取原始域名信息。
     */
    NSString *host = [[self.actualRequest allHTTPHeaderFields] objectForKey:@"host"];
    if (!host) {
        host = self.actualRequest.URL.host;
    }
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if ([self evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:host]) {
            disposition = NSURLSessionAuthChallengeUseCredential;
            credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        } else {
            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        }
    } else {
        disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    }
    // 对于其他的challenges直接使用默认的验证方案
    completionHandler(disposition, credential);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    self.response = response;

    NSURLCacheStoragePolicy cacheStoragePolicy;
    NSInteger               statusCode;
    
#pragma unused(session)
#pragma unused(dataTask)
    NSCAssert(dataTask == self.task,@"dataTask != self.task");
    NSCAssert(response != nil,@"response == nil");
    NSCAssert(completionHandler != nil,@"completionHandler == nil");
    NSCAssert([NSThread currentThread] == self.clientThread,@"[NSThread currentThread] != self.clientThread");
    
    // Pass the call on to our client.  The only tricky thing is that we have to decide on a
    // cache storage policy, which is based on the actual request we issued, not the request
    // we were given.
    
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        cacheStoragePolicy = NeteaseMACacheStoragePolicyForRequestAndResponse(self.actualRequest, (NSHTTPURLResponse *) response);
        statusCode = [((NSHTTPURLResponse *) response) statusCode];
    } else {
        NSCAssert(NO,@"response is Not KindOfClass:NSHTTPURLResponse");
        cacheStoragePolicy = NSURLCacheStorageNotAllowed;
        statusCode = 42;
    }
    
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:cacheStoragePolicy];
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
#pragma unused(session)
#pragma unused(dataTask)
    NSCAssert(dataTask == self.task,@"dataTask != self.task");
    NSCAssert(data != nil,@"data == nil");
    NSCAssert([NSThread currentThread] == self.clientThread,@"[NSThread currentThread] != self.clientThread");
    
    if (!self.txBytes) {
        self.txBytes += [self.request.URL.absoluteString length];
        if(![[self.request.HTTPMethod uppercaseString] isEqualToString:@"GET"] && self.request.HTTPBody){
            self.txBytes += self.request.HTTPBody.length;
        }
    }
    
    self.rxBytes += data.length;
    
    // Just pass the call on to our client.
    
    [[self client] URLProtocol:self didLoadData:data];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse *))completionHandler
{
#pragma unused(session)
#pragma unused(dataTask)
    NSCAssert(dataTask == self.task,@"dataTask != self.task");
    NSCAssert(proposedResponse != nil,@"proposedResponse == nil");
    NSCAssert(completionHandler != nil,@"completionHandler == nil");
    NSCAssert([NSThread currentThread] == self.clientThread,@"[NSThread currentThread] != self.clientThread");
    
    // We implement this delegate callback purely for the purposes of logging.
    
    completionHandler(proposedResponse);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
// An NSURLSession delegate callback.  We pass this on to the client.
{
#pragma unused(session)
#pragma unused(task)
    NSCAssert( (self.task == nil) || (task == self.task),@"(self.task != nil) && (task != self.task)" );        // can be nil in the 'cancel from -stopLoading' case
    NSCAssert([NSThread currentThread] == self.clientThread,@"[NSThread currentThread] != self.clientThread");
    
    // Just log and then, in most cases, pass the call on to our client.
    self.error = error;

    if (error == nil) {
        [[self client] URLProtocolDidFinishLoading:self];
    } else if ( [[error domain] isEqual:NSURLErrorDomain] && ([error code] == NSURLErrorCancelled) ) {
        // Do nothing.  This happens in two cases:
        //
        // o during a redirect, in which case the redirect code has already told the client about
        //   the failure
        //
        // o if the request is cancelled by a call to -stopLoading, in which case the client doesn't
        //   want to know about the failure
    } else {
        [[self client] URLProtocol:self didFailWithError:error];
    }
    
    // We don't need to clean up the connection here; the system will call, or has already called,
    // -stopLoading to do that.
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didFinishCollectingMetrics:(NSURLSessionTaskMetrics *)metrics {
    
    for (NSURLSessionTaskTransactionMetrics *metric in metrics.transactionMetrics) {
        if (metric.resourceFetchType == NSURLSessionTaskMetricsResourceFetchTypeNetworkLoad) {
            @synchronized (self) {
                self.dnsStartTime = [metric.domainLookupStartDate timeIntervalSince1970] * 1000;
                self.dnsEndTime = [metric.domainLookupEndDate timeIntervalSince1970] * 1000;
                self.writeStartTime = [metric.requestStartDate timeIntervalSince1970] * 1000;
                self.writeEndTime = [metric.requestEndDate timeIntervalSince1970] * 1000;
                self.readStartTime = [metric.responseStartDate timeIntervalSince1970] * 1000;
                self.readEndTime = [metric.responseEndDate timeIntervalSince1970] * 1000;
                self.sslHandshakeStartTime = [metric.secureConnectionStartDate timeIntervalSince1970] * 1000;
                self.sslHandshakeEndTime = [metric.secureConnectionEndDate timeIntervalSince1970] * 1000;
                self.tcpStartTime = [metric.connectStartDate timeIntervalSince1970] * 1000;
                self.tcpEndTime = [metric.connectEndDate timeIntervalSince1970] * 1000;
                self.netDetailDic = [self toDictionaryValue];
            }
        }
    }
}

- (NSDictionary *)toDictionaryValue {
    NSMutableDictionary *mutableJSONValue = [[NSMutableDictionary alloc] init];
    [mutableJSONValue _safety_setInteger:self.dnsStartTime forKey:@"dnsSTime"];
    [mutableJSONValue _safety_setInteger:self.dnsEndTime forKey:@"dnsETime"];
    [mutableJSONValue _safety_setInteger:self.tcpStartTime forKey:@"tcpSTime"];
    [mutableJSONValue _safety_setInteger:self.tcpEndTime forKey:@"tcpETime"];
    [mutableJSONValue _safety_setInteger:self.sslHandshakeStartTime forKey:@"sslSTime"];
    [mutableJSONValue _safety_setInteger:self.sslHandshakeEndTime forKey:@"sslETime"];
    
    [mutableJSONValue _safety_setInteger:self.writeStartTime forKey:@"reqSTime"];
    [mutableJSONValue _safety_setInteger:self.writeEndTime forKey:@"reqETime"];
    [mutableJSONValue _safety_setInteger:self.readStartTime forKey:@"respSTime"];
    [mutableJSONValue _safety_setInteger:self.readEndTime forKey:@"respETime"];
    
    return mutableJSONValue;
}

@end

