//
//  LDGeminiConfig.m
//  LDGeminiSDK
//
//  Created by wangkaird on 2016/10/11.
//  Copyright © 2016年 wangkaird. All rights reserved.
//

#import "LDGeminiConfig.h"

@interface LDGeminiConfig ()

@property (nonatomic, strong) NSMutableDictionary *configs;
@property (nonatomic, strong) NSArray *requiredConfigNames;
@property (nonatomic, strong) NSArray *optionalConfigNames;

@end

@implementation LDGeminiConfig

+ (instancetype)sharedConfig {
    static LDGeminiConfig *geminiConfig = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        geminiConfig = [[LDGeminiConfig alloc] init];
    });
    
    return geminiConfig;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _requiredConfigNames = @[LDGeminiAppKeyConfigAttributeName,
                                 LDGeminiUserIdConfigAttributeName,
                                 LDGeminiTimeStampConfigAttributeName,
                                 LDGeminiDeviceIDConfigAttributeName,
                                 LDGeminiSignConfigAttributeName];

        _optionalConfigNames = @[LDGeminiAccessIPConfigAttributeName,
                                 LDGeminiNetTypeConfigAttributeName,
                                 LDGeminiDeviceTypeConfigAttributeName,
                                 LDGeminiUserInfoConfigAttributeName];

        _configs = [[NSMutableDictionary alloc] initWithCapacity:_optionalConfigNames.count + _requiredConfigNames.count];
        [self iResetConfigs];
    }
    return self;
}

- (void)resetConfigs {
    [self iResetConfigs];
}

- (void)resetConfig:(NSString *)configName {
    if (![configName isKindOfClass:[NSString class]]) {
        return;
    }
    if (![_requiredConfigNames containsObject:configName] &&
        ![_optionalConfigNames containsObject:configName]) {
        return;
    }
    _configs[configName] = nil;
}

- (void)refreshConfig:(NSDictionary <NSString *, NSString *> *)configs {
    if (![configs isKindOfClass:[NSDictionary class]] ||
        [configs count] == 0) {
        return ;
    }

    NSDictionary *dictionary = [configs copy];
    NSArray *keys = [dictionary allKeys];

    for (NSString *key in keys) {
        NSString *value = dictionary[key];
        if (![key isKindOfClass:[NSString class]] ||
            ![value isKindOfClass:[NSString class]]) {
            continue;
        }
        if ([_requiredConfigNames containsObject:key] ||
            [_optionalConfigNames containsObject:key]) {
            _configs[key] = value;
        }
    }
}

- (NSString *)getConfig:(NSString *)configName {
    if (![configName isKindOfClass:[NSString class]]) {
        return nil;
    }
    if (![_requiredConfigNames containsObject:configName] &&
        ![_optionalConfigNames containsObject:configName]) {
        return nil;
    }
    return _configs[configName];
}

- (NSDictionary *)getAllConfigs {
    return _configs ? [_configs copy] : @{};
}

- (NSArray *)getAllRequiredConfigNames {
    NSArray *required = [_requiredConfigNames copy];
    return required ? : @[];
}

- (NSArray *)getAllOptionalConfigNames {
    NSArray *optional = [_optionalConfigNames copy];
    return optional ? : @[];
}

- (NSArray *)getAllConfigNames {
    NSMutableArray *muArray = [[NSMutableArray alloc] init];
    [muArray addObjectsFromArray:[self getAllRequiredConfigNames]];
    [muArray addObjectsFromArray:[self getAllOptionalConfigNames]];

    return [muArray copy];
}

#pragma mark - private methods

- (void)iResetConfigs {
    [_configs removeAllObjects];
    for (NSString *attribute in _requiredConfigNames) {
        _configs[attribute] = nil;
    }

    for (NSString *attribute in _optionalConfigNames) {
        _configs[attribute] = nil;
    }
}

@end














