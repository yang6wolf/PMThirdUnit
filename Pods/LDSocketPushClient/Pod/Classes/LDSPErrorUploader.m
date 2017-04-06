//
//  LDSPErrorUploader.m
//  Pods
//
//  Created by liubing on 9/10/15.
//
//

#import "LDSPErrorUploader.h"
#import "LDSocketPushClient.h"

#define EMPTY_IF_NIL(a) (((a) == nil) ? @"" : (a))

#define ERROR_LOG_PATH @"/custom_log"

@interface LDSPErrorUploader ()

@property (strong, nonatomic) NSString *errorUploadHost;

@end

@implementation LDSPErrorUploader

+ (instancetype)sharedInstance
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    
    return instance;
}

- (void)setErrorLogHost:(NSString *)errorLogHost
{
    if (errorLogHost) {
        self.errorUploadHost = errorLogHost;
    } else {
        self.errorUploadHost = @"http://mt.analytics.163.com";
    }
}

- (void)uploadSocketErrorIfNeed:(NSError *)error
{
    if (!error) {
        return;
    }
    
    if (error.code == LDSocketPushClientErrorTypeDisconnected && [error.domain isEqual:LDSocketPushClientErrorDomain]) {//正常断开不上报
        return;
    }
    
    NSDictionary *errorDic = @{@"error_domain":EMPTY_IF_NIL(error.domain),
                               @"error_code":@(error.code),
                               @"error_desc":EMPTY_IF_NIL([error localizedDescription])};
    
    static NSMutableSet *errorSet = nil;
    
    if (!errorSet) {
        errorSet = [NSMutableSet new];
    }
    
    if (![errorSet containsObject:errorDic]) {
        [errorSet addObject:errorDic];
        
        NSMutableDictionary *infoDic = [NSMutableDictionary new];
        
        [infoDic addEntriesFromDictionary:errorDic];
        
        [infoDic addEntriesFromDictionary:@{@"host":EMPTY_IF_NIL([LDSocketPushClient defaultClient].host),
                                            @"port":@([LDSocketPushClient defaultClient].port),
                                            @"product":@([LDSocketPushClient defaultClient].productCode),
                                            @"deviceId":EMPTY_IF_NIL([LDSocketPushClient defaultClient].deviceId),
                                            @"token":EMPTY_IF_NIL([LDSocketPushClient defaultClient].deviceToken)}];
        
        [self uploadErrorInfo:infoDic];
    }
}

- (void)uploadErrorInfo:(NSDictionary *)infoDic
{
    /*
    NSMutableString *error = [NSMutableString new];
    
    [infoDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [error appendFormat:@"%@=%@;",key,obj];
    }];
     */
    
    NSString *body = [NSString stringWithFormat:@"name=lede_tcp_push_error_ios&zip=false&data=%@",infoDic.description];
    NSData *bodyData = [body dataUsingEncoding:NSUTF8StringEncoding];
    if (!self.errorUploadHost) {
        self.errorUploadHost = @"http://mt.analytics.163.com";
    }
    NSString *errorLogUploadUrl = [NSString stringWithFormat:@"%@%@", self.errorUploadHost, ERROR_LOG_PATH];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:errorLogUploadUrl]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:60.0];
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
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
}

@end
