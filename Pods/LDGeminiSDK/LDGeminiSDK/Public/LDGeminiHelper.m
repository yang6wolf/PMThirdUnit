//
//  LDGeminiHelper.m
//  Pods
//
//  Created by wangkaird on 2016/12/29.
//
//

#import "LDGeminiHelper.h"
#import "LDGeminiSDK.h"

@interface LDGeminiHelper ()
@property (nonatomic, strong) NSMutableDictionary *map;
@end


@implementation LDGeminiHelper

+ (instancetype)sharedHelper {
    static LDGeminiHelper *helper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[LDGeminiHelper alloc] init];
    });

    return helper;
}

+ (void)addCaseIdWithMap:(NSDictionary <NSString *, NSString *> *)map {
    [[self sharedHelper] addCaseIdWithMap:map];
}

+ (void)addCaseId:(NSString *)caseId withName:(NSString *)name {
    [[self sharedHelper] addCaseId:caseId withName:name];
}

+ (nullable NSString *)caseIdForName:(NSString *)name {
    return [[self sharedHelper] caseIdForName:name];
}

+ (NSArray *)caseIdArray {
    return [[self sharedHelper] caseIdArray];
}

+ (NSArray *)nameArray {
    return [[self sharedHelper] nameArray];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _map = [[NSMutableDictionary alloc] init];
    }

    return self;
}

- (NSArray *)caseIdArray {
    return self.map.allValues;
}

- (NSArray *)nameArray {
    return self.map.allKeys;
}

- (void)addCaseIdWithMap:(NSDictionary<NSString *,NSString *> *)map {
    NSAssert([map isKindOfClass:[NSDictionary class]], @"%s %s: 非法的参数 map", __FILE__, __func__);
    [self.map addEntriesFromDictionary:map];
    [LDGeminiSDK registerCaseWithArray:[self caseIdArray]];
}

- (void)addCaseId:(NSString *)caseId withName:(NSString *)name {
    NSAssert([caseId isKindOfClass:[NSString class]], @"%s %s: 非法的参数 caseId", __FILE__, __func__);
    NSAssert([name isKindOfClass:[NSString class]], @"%s %s: 非法的参数 name", __FILE__, __func__);
    self.map[name] = [caseId copy];
    [LDGeminiSDK registerCaseWithArray:[self caseIdArray]];
}

- (NSString *)caseIdForName:(NSString *)name {
    NSAssert([name isKindOfClass:[NSString class]], @"%s %s: 非法的参数 name", __FILE__, __func__);
    return self.map[name];
}

@end
