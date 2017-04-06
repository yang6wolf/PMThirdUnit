//
//  NLDRemoteEventService.m
//  Pods
//
//  Created by 高振伟 on 16/8/8.
//
//

#import "NLDRemoteEventService.h"
#import "NLDRemoteEventModel.h"
#import "NLDAppInfoUtils.h"
#import "NLDDecrypt.h"

NSString * const NLDLocalEvents = @"NLDLocalEvents";
NSString * const NLDLocalHash   = @"NLDLocalHash";

@interface NLDRemoteEventService ()

@property (nonatomic, strong, nullable) NSArray<NLDRemoteEventModel *> *remoteEvents;
//@property (nonatomic, copy) NSString *appKey;

@property (nonatomic, assign) BOOL hasRequestData;
//@property (nonatomic, assign) BOOL isLoadingHash;
@property (nonatomic, assign) BOOL isLoadingEvents;
@property (nonatomic, copy) NSString *appKey;
@property (nonatomic, copy) NSString *remoteEventDomain;

@end

@implementation NLDRemoteEventService

- (instancetype)initWithAppKey:(NSString *)appKey domain:(NSString *)domain
{
    self = [super init];
    if (self) {
        self.hasRequestData = NO;
//        self.isLoadingHash = NO;
        self.isLoadingEvents = NO;
        self.appKey = appKey;
        self.remoteEventDomain = domain;
    }
    return self;
}

- (nullable NSArray<NLDRemoteEventModel *> *)remoteEvents
{
    if (self.hasRequestData) {
        return _remoteEvents;
    }
    
    return nil;
}

- (nullable NSArray<NLDRemoteEventModel *> *)getRemoteEvents
{
    // 每次启动只向服务器请求一次数据即可，下次启动的时候使用
    if (self.hasRequestData) {
        return _remoteEvents;
    }
    
    return nil;
    
    /*
    __weak typeof(self) weakSelf = self;
    [self getRemoteHashWithCompletionHandler:^(NSInteger hash, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!error) {
            NSInteger localHash = [self getLocalHash];
            if (hash != localHash) {
                [strongSelf getRemoteEventsWithCompletionHander:^(NSArray<NLDRemoteEventModel *> * _Nullable remoteEvents, NSError * _Nullable error) {
                    if (!error) {
                        [[NSUserDefaults standardUserDefaults] setInteger:hash forKey:NLDLocalHash];
                        strongSelf.hasRequestData = YES;  // 每次启动只请求一次数据
                    }
                }];
            }
        }
    }];
    
    _remoteEvents = [self getLocalEvents];
    return _remoteEvents;
     */
}

- (void)fetchRemoteEvents
{
    if (self.hasRequestData) return;
    
    if (self.isLoadingEvents) {
        return;
    }
    self.isLoadingEvents = YES;
    
    NSString *urlStr = [NSString stringWithFormat:@"%@2/view/route/info", _remoteEventDomain];
    __weak typeof(self) weakSelf = self;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    request.HTTPMethod = @"POST";
    NSString *params = [NSString stringWithFormat:@"appKey=%@&appVersion=%@&systemVersion=%@", self.appKey, [NLDAppInfoUtils appBuildVersion], [NLDAppInfoUtils systemVersion]];
    request.HTTPBody = [params dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.isLoadingEvents = NO;
        self.hasRequestData = YES;
        
        if (!error) {
            NSError *parseError = nil;
            NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments error:&parseError];
            if (!parseError) {
                NSInteger result = [jsonDictionary[@"resultCode"] integerValue];
                if (result == 100) {
                    NSArray *contents = jsonDictionary[@"dataList"];
                    NSMutableArray *array = [NSMutableArray arrayWithCapacity:5];
                    if (!contents || [contents isEqual:[NSNull null]]) {
                        return;
                    }
                    for (NSString *content in contents) {
                        NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
                        NSData *decryptData = [NLDDecrypt decryptPostData:data];
                        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:decryptData options:NSJSONReadingAllowFragments error:nil];
                        NLDRemoteEventModel *event = [[NLDRemoteEventModel alloc] initWithDictionary:dict];
                        if (event) {
                            [array addObject:event];
                        }
                    }
                    _remoteEvents = [array copy];
                }
            }
        }
    }];
    
    [task resume];
}

#pragma mark - Private

/*
- (void)getRemoteHashWithCompletionHandler:(void (^)(NSInteger hash, NSError * _Nullable error))handler
{
    if (self.isLoadingHash) {
        return;
    }
    self.isLoadingHash = YES;
    
    __weak typeof(self) weakSelf = self;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NLDRemoteEventInterface remoteEventHashUrl]]];
    request.HTTPMethod = @"POST";
    NSString *params = [NSString stringWithFormat:@"appBundle=%@&appVersion=%@&appBuild=%@", [NLDAppInfoUtils appBundle], [NLDAppInfoUtils appVersion], [NLDAppInfoUtils appBuildVersion]];
    request.HTTPBody = [params dataUsingEncoding:NSUTF8StringEncoding];
    
//    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    configuration.protocolClasses = @[[NSClassFromString(@"OHHTTPStubsProtocol") class]];
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.isLoadingHash = NO;
        
        if (!error) {
            NSError *error = nil;
            NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments error:&error];
            if (!error) {
                NSInteger result = [jsonDictionary[@"result"] integerValue];
                NSString *resultDesc = jsonDictionary[@"resultDesc"];
                if (result == 100) {
                    NSInteger hash = [jsonDictionary[@"hash"] integerValue];
                    handler(hash, nil);
                } else {
                    NSError *error = [NSError errorWithDomain:@"com.lede.remoteEvent" code:result userInfo:@{NSLocalizedDescriptionKey:resultDesc}];
                    handler(-1, error);
                }
            } else {
                handler(-1, error);
            }
        } else {
            handler(-1, error);
        }
    }];
    
    
    [task resume];
}

- (void)getRemoteEventsWithCompletionHander:(void (^)( NSArray<NLDRemoteEventModel *> * _Nullable remoteEvents, NSError * _Nullable error))handler
{
    if (self.isLoadingEvents) {
        return;
    }
    self.isLoadingEvents = YES;
    
    __weak typeof(self) weakSelf = self;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NLDRemoteEventInterface remoteEventUrl]]];
    request.HTTPMethod = @"POST";
    NSString *params = [NSString stringWithFormat:@"appBundle=%@&appVersion=%@&appBuild=%@", [NLDAppInfoUtils appBundle], [NLDAppInfoUtils appVersion], [NLDAppInfoUtils appBuildVersion]];
    request.HTTPBody = [params dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.isLoadingEvents = NO;
        
        if (!error) {
            NSError *error = nil;
            NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments error:&error];
            if (!error) {
                NSInteger result = [jsonDictionary[@"result"] integerValue];
                NSString *resultDesc = jsonDictionary[@"resultDesc"];
                if (result == 100) {
                    [[NSUserDefaults standardUserDefaults] setObject:jsonDictionary forKey:NLDLocalEvents];
                    NSArray *eventModels = [self parseEventModelWithDict:jsonDictionary];
                    handler([eventModels copy], nil);
                } else {
                    NSError *error = [NSError errorWithDomain:@"com.lede.remoteEvent" code:result userInfo:@{NSLocalizedDescriptionKey:resultDesc}];
                    handler(nil, error);
                }
            } else {
                handler(nil, error);
            }
        } else {
            handler(nil, error);
        }
    }];
    
    [task resume];
}

- (nullable NSArray<NLDRemoteEventModel *> *)getLocalEvents
{
    NSDictionary *jsonDictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:NLDLocalEvents];
    if (!jsonDictionary) {
        return nil;
    }
    
    return [self parseEventModelWithDict:jsonDictionary];
}

- (NSInteger)getLocalHash
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:NLDLocalHash];
}

- (nullable NSArray<NLDRemoteEventModel *> *)parseEventModelWithDict:(NSDictionary *)jsonDictionary
{
    NSArray *events = jsonDictionary[@"configValues"];
    if (![events isKindOfClass:[NSArray class]]) {
        return nil;
    }
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:5];
    for (NSDictionary *dic in events) {
        NLDRemoteEventModel *event = [[NLDRemoteEventModel alloc] initWithDictionary:dic];
        if (event) {
            [array addObject:event];
        }
    }
    
    return [array copy];
}
 */

@end
