//
//  NLDRemotePageService.m
//  LDEventCollection
//
//  Created by 高振伟 on 17/3/28.
//
//

#import "NLDRemotePageService.h"

#define kRemoteChildViewControllers @"RemoteChildViewControllers"

@implementation NLDRemotePageService

+ (instancetype)defaultService
{
    static NLDRemotePageService *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NLDRemotePageService alloc] init];
    });
    return instance;
}

- (void)fetchScreenShotPages
{
    NSString *urlStr = @"http://data.ms.netease.com/view/page/list";
    NSString *requestUrl = [NSString stringWithFormat:@"%@?appkey=%@&filter=false", urlStr, self.appKey];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    request.HTTPMethod = @"GET";
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (!error) {
            NSError *parseError = nil;
            NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments error:&parseError];
            if (!parseError) {
                NSInteger result = [jsonDictionary[@"resultCode"] integerValue];
                if (result == 100) {
                    NSArray *contents = jsonDictionary[@"dataList"];
                    if (!contents || [contents isEqual:[NSNull null]]) {
                        return;
                    }
                    self.screenShotPages = contents;
                }
            }
        }
    }];
    
    [task resume];
}

- (void)fetchChildViewControllers
{
    NSString *urlStr = @"http://data.ms.netease.com/view/page/list";
    NSString *requestUrl = [NSString stringWithFormat:@"%@?appkey=%@&filter=true", urlStr, self.appKey];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    request.HTTPMethod = @"GET";
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (!error) {
            NSError *parseError = nil;
            NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments error:&parseError];
            if (!parseError) {
                NSInteger result = [jsonDictionary[@"resultCode"] integerValue];
                if (result == 100) {
                    NSArray *contents = jsonDictionary[@"dataList"];
                    if (!contents || [contents isEqual:[NSNull null]]) {
                        return;
                    }
                    self.childViewControllers = contents;
                }
            }
        }
    }];
    
    [task resume];
}

- (BOOL)isAlreadyUploadPage:(NSString *)pageName
{
    if (self.screenShotPages && [self.screenShotPages containsObject:pageName]) {
        return YES;
    }
    
    return NO;
}

// 内部不再请求，由业务方提供
//- (nullable NSArray<NSString *> *)childViewControllers
//{
//    return self.childViewControllers;
//}

@end
