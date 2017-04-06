//
//  UpLoader.m
//  MobileAnalysis
//
//  Created by zhang jie on 13-4-18.
//  Copyright (c) 2013年 zhang jie. All rights reserved.
//

#import "NetEaseMAUpLoader.h"
#import "NetEaseMACache.h"
#import "NetEaseMAUtils.h"
#import "JSONKit.h"
#import "NeteaseMobileManager.h"

@interface NetEaseMAUpLoader()
@property(nonatomic,strong) NSArray *uploadingFiles;
@property(nonatomic) BOOL isUploading;
@property(nonatomic) UIBackgroundTaskIdentifier taskIdentifier;
@property(nonatomic) NSString *url;
@end

@implementation NetEaseMAUpLoader {
    NSURLConnection *_uploadConnection;		// The connection which uploads the bits
}

- (id)initWithUrl:(NSString*)url {
    if (self=[super init]) {
        self.url = url;
    }
    return self;
}


-(void)uploadSessionCacheFiles:(NSArray*)array
{
    if(!self.isUploading)
    {
        self.uploadingFiles = array;
        NSMutableArray *sessionArray = [NSMutableArray array];
        for (NSString *filePath in self.uploadingFiles) {
            NSDictionary *dict = [[NSData dataWithContentsOfFile:filePath] objectFromJSONData];
            /*
             TODO: Try to fix a crash on iOS 10.2.0
             https://fabric.io/netease3/ios/apps/com.changying.rrzcp/issues/585984be0aeb16625b3a86a4
             */
            if (dict) {
                [sessionArray addObject:dict];
            }
        }
        if (sessionArray.count==0) {
            return;
        }
        
        self.isUploading=YES;

#ifdef DEBUG
        NETEASE_LOG(@"NetEaseMAUpLoader complete at debug statge");
        [self complete];
        [self.delegate netEaseMAUploadSessionFiles:self.uploadingFiles complete:YES];
        return;
#endif
        //upload to mobileanalysis server
        NSString *body = [NetEaseMaUtils zipAndEncrypt:[sessionArray JSONData]];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]
                                                                     cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                                 timeoutInterval:60.0];
        
        NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
        [dict setObject:[NeteaseMobileManager sharedManager].appId forKey:@"p"];
        [dict setObject:body forKey:@"d"];
        NSString *strJson = [dict JSONString];
        NSData *bodyData=[strJson dataUsingEncoding:NSUTF8StringEncoding];
        
        [request setHTTPMethod:@"POST"];//POST请求
        [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[bodyData length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:bodyData];
        
        _uploadConnection = [NSURLConnection connectionWithRequest:request delegate:self];
        
        
        self.taskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            //开启后台任务的目的是希望，connection delegate的回调尽快被调用；任务一旦挂起就可能不再恢复，这会导致已经成功上传的本地数据文件没有被删除
        }];
    }
}

-(void)complete
{
    _uploadConnection=nil;
    self.isUploading=NO;
    [[UIApplication sharedApplication] endBackgroundTask:self.taskIdentifier];
    self.taskIdentifier = UIBackgroundTaskInvalid;
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
    NETEASE_LOG(@"NetEaseMAUpLoader error");
    [self.delegate netEaseMAUploadSessionFiles:self.uploadingFiles complete:NO];
    [self complete];//终止后台任务需要在删除文件之后
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NETEASE_LOG(@"NetEaseMAUpLoader complete");
    [self.delegate netEaseMAUploadSessionFiles:self.uploadingFiles complete:YES];
    [self complete];//终止后台任务需要在删除文件之后
}

@end
