//
//  LDGeminiCase.m
//  LDGeminiSDKiOS
//
//  Created by wangkaird on 2016/10/13.
//  Copyright © 2016年 wangkaird. All rights reserved.
//

#import "LDGeminiCase.h"

@implementation LDGeminiCase

+ (instancetype)createWithDictionary:(NSDictionary *)dictionary {
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

    return [[[self class] alloc] initWithFlag:dictionary[@"flag"] andCaseId:dictionary[@"caseId"]];
}

+ (NSArray *)createWithArray:(NSArray *)array {
    NSMutableArray *ret = [[NSMutableArray alloc] initWithCapacity:[array count]];
    for (NSDictionary *dic in array) {
        if (![dic isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        id instance = [self createWithDictionary:dic];
        if (instance) {
            [ret addObject:instance];
        }
    }
    return [ret copy];
}

- (instancetype)initWithFlag:(id)flag andCaseId:(id)caseId {
    self = [super init];
    if (!caseId || !flag) {
        return nil;
    }
    NSString *caseIdString = nil;

    if ([caseId isKindOfClass:[NSString class]]) {
        caseIdString = [(NSString *)caseId copy];
    } else if ([caseId isKindOfClass:[NSNumber class]]) {
        caseIdString = [(NSNumber *)caseId stringValue];
    } else {
        caseIdString = [caseId description];
    }

    if (self) {
        _flag = flag;
        _caseId = caseIdString;
    }

    return self;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSNumber *caseId = [NSNumber numberWithInteger:[_caseId integerValue]];
    NSNumber *flag = [NSNumber numberWithInteger:[_flag integerValue]];
    dic[@"caseId"] = caseId;
    dic[@"flag"] = flag;

    return [dic copy];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.flag forKey:@"flag"];
    [aCoder encodeObject:self.caseId forKey:@"caseId"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.flag = [aDecoder decodeObjectForKey:@"flag"];
        self.caseId = [aDecoder decodeObjectForKey:@"caseId"];
    }
    return self;
}

@end
