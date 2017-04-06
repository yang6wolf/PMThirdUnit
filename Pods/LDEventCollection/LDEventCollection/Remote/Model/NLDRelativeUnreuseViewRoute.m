//
//  NLDRelativeViewRoute.m
//  Pods
//
//  Created by 高振伟 on 16/8/8.
//
//

#import "NLDRelativeUnreuseViewRoute.h"

@interface NLDRelativeUnreuseViewRoute ()

@property (nonatomic, assign) NLDRelativeViewType relativeViewType;
@property (nonatomic, copy) NSString *relativeViewPropertyPath;  // 用于通过kvc获取数据
@property (nonatomic, copy) NSString *relativeViewKey;           // 传递给后台数据时的key

@end

@implementation NLDRelativeUnreuseViewRoute

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
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
        
        self.relativeViewType = NLDRelativeViewUnreuseType;
        
        if ([key isEqualToString:@"viewName"]) {
            self.viewName = obj;
        } else if ([key isEqualToString:@"controllerName"]) {
            self.controllerName = obj;
        } else if ([key isEqualToString:@"windowName"]) {
            self.windowName = obj;
        } else if ([key isEqualToString:@"relativeViewPaths"]) {
            self.fromControllerViewPaths = [obj componentsSeparatedByString:@"-"];
        } else if ([key isEqualToString:@"relativeDepthPaths"]) {
            self.fromControllerDepthPaths = [obj componentsSeparatedByString:@"-"];
        } else if ([key isEqualToString:@"relativeViewPropertyPath"]) {
            self.relativeViewPropertyPath = obj;
        } else if ([key isEqualToString:@"relativeViewKey"]) {
            self.relativeViewKey = obj;
        }
    }];
}

#pragma mark - isEqual

- (BOOL)isEqual:(id)object
{
    if (object == self) {
        return YES;
    }
    
    if ([object isKindOfClass:[self class]]) {
        return [self hash] == [object hash];
    }
    return NO;
}

- (NSUInteger)hash
{
    return ([self.viewName hash] ^
            [self.controllerName hash] ^
            [self.windowName hash] ^
            [self.fromControllerViewPaths hash] ^
            [self.fromControllerDepthPaths hash]);
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    NLDRelativeUnreuseViewRoute *route = [[[self class] alloc] init];
    route.viewName = self.viewName;
    route.controllerName = self.controllerName;
    route.windowName = self.windowName;
    route.fromControllerViewPaths = [self.fromControllerViewPaths copy];
    route.fromControllerDepthPaths = [self.fromControllerDepthPaths copy];
    route.relativeViewPropertyPath = self.relativeViewPropertyPath;
    return route;
}

@end
