//
//  NLDTargetViewRoute.m
//  Pods
//
//  Created by 高振伟 on 16/8/8.
//
//

#import "NLDTargetViewRoute.h"

@implementation NLDTargetViewRoute

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self parseDictionary:dict];
    }
    return self;
}

- (void)parseDictionary:(NSDictionary *)dict
{
    if (!dict) {
        return;
    }
    
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj == [NSNull null]) {
            obj = nil;
        }
        
        if ([key isEqualToString:@"viewName"]) {
            self.viewName = obj;
        } else if ([key isEqualToString:@"controllerName"]) {
            self.controllerName = obj;
        } else if ([key isEqualToString:@"windowName"]) {
            self.windowName = obj;
        } else if ([key isEqualToString:@"targetViewPaths"]) {
            self.fromControllerViewPaths = [obj componentsSeparatedByString:@"-"];
        } else if ([key isEqualToString:@"targetDepthPaths"]) {
            self.fromControllerDepthPaths = [obj componentsSeparatedByString:@"-"];
        } else if ([key isEqualToString:@"targetViewEvent"]) {
            self.targetViewEvent = obj;
        } else if ([key isEqualToString:@"propertyPath"]) {
            self.propertyPath = obj;
        } else if ([key isEqualToString:@"propertyKey"]) {
            self.propertyKey = obj;
        } else if ([key isEqualToString:@"subViewNumber"]) {
            self.subViewNumber = obj;
        } else if ([key isEqualToString:@"subViewClsName"]) {
            self.subViewClsName = obj;
        }
    }];
}

#pragma mark - isEqual

- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    }
    
    if ([other isKindOfClass:[self class]]) {
        return [self hash] == [other hash];
    }
    return NO;
}

- (NSUInteger)hash
{
    return ([self.viewName hash] ^
            [self.controllerName hash] ^
            [self.windowName hash] ^
            [self.fromControllerViewPaths hash] ^
            [self.fromControllerDepthPaths hash] ^
            [self.targetViewEvent hash] ^
            [self.propertyPath hash] ^
            [self.propertyKey hash] ^
            [self.subViewNumber hash] ^
            [self.subViewClsName hash]);
}

@end
