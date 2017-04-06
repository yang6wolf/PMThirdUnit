//
//  NetEaseMADiagnoseLog.m
//  MobileAnalysis
//
//  Created by 高振伟 on 16/9/5.
//
//

#import "NetEaseMADiagnoseLog.h"
#import "NetEaseMADiagnoseModel.h"
#import "NetEaseMobileAgent.h"

static NSString *const TAG_ALL = @"all";
static NSString *const DIAGNOSIS_UPLOAD_URL = @"/custom_log";
static NSString *const TAG_DATE_KEY = @"tag_date_key";

@interface NetEaseMADiagnoseLog ()

@property(nonatomic, strong) NSArray *uploadTags;                 // 需上报的tag
@property(nonatomic, strong) NSMutableDictionary *diagnoseDic;   // 目前已打开的上报事件

@end

@implementation NetEaseMADiagnoseLog

+ (instancetype)sharedInstance {
    static NetEaseMADiagnoseLog *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NetEaseMADiagnoseLog alloc] init];
        instance.uploadTags = [NSArray array];
        if ([[NSUserDefaults standardUserDefaults] objectForKey:TAG_DATE_KEY]) {
            instance.diagnoseDic = [[[NSUserDefaults standardUserDefaults] objectForKey:TAG_DATE_KEY] mutableCopy];
        } else {
            instance.diagnoseDic = [NSMutableDictionary dictionaryWithCapacity:4];
        }
    });
    
    return instance;
}

- (void)setupDiagnose:(NSArray *)params {
    [self parseDiagnose:params];
    [self validateExpired];
}

- (void)addDiagnoseLog:(NSString *)log tag:(NSString *)tag {
    [self validateExpired];
    if (![self.uploadTags containsObject:tag] && ![self.uploadTags containsObject:TAG_ALL]) {
        return;
    }
    
    [self uploadTag:tag diagnose:log];
}

#pragma mark - private

- (void)parseDiagnose:(NSArray *)params {
    for (NSDictionary *dic in params) {
        NetEaseMADiagnoseModel *model = [[NetEaseMADiagnoseModel alloc] initWithDictionary:dic];
        if (model.tag) {
            [self.diagnoseDic setObject:model.expiredDate forKey:model.tag];
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:self.diagnoseDic.copy forKey:TAG_DATE_KEY];
}

- (void)validateExpired {
    NSDictionary *tempDict = [self.diagnoseDic copy];
    NSMutableArray *expiredOrClosedTags = [NSMutableArray arrayWithCapacity:4];
    [tempDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSDate *now = [NSDate date];
        if ([now compare:obj] != NSOrderedAscending) {
            [expiredOrClosedTags addObject:key];
        }
    }];
    
    if (expiredOrClosedTags.count) {
        [self.diagnoseDic removeObjectsForKeys:expiredOrClosedTags];
        [[NSUserDefaults standardUserDefaults] setObject:self.diagnoseDic.copy forKey:TAG_DATE_KEY];
    }
    self.uploadTags = [self.diagnoseDic allKeys];
}

#pragma mark - upload

- (void)uploadTag:(NSString *)tag diagnose:(NSString *)diagnoseLog {
    NSDictionary *infoDict = @{@"log":diagnoseLog, @"uploadTime":[self currentTime]};
    NSString *bodyStr = [NSString stringWithFormat:@"name=%@&zip=false&data=%@", @"DIAG_LOG", infoDict.description];
    NSData *bodyData = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[[NetEaseMobileAgent sharedInstance] getAnalysisHost],DIAGNOSIS_UPLOAD_URL]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[bodyData length]] forHTTPHeaderField:@"Content-Length"];
    
    [request setHTTPBody:bodyData];
    [NSURLConnection connectionWithRequest:request delegate:nil];
}

- (NSString *)currentTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSS"];
    return [formatter stringFromDate:[NSDate date]];
}

@end
