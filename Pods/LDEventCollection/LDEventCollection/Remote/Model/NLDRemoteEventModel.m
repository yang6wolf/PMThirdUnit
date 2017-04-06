//
//  NLDRemoteEventModel.m
//  Pods
//
//  Created by 高振伟 on 16/8/8.
//
//

#import "NLDRemoteEventModel.h"
#import "NLDTargetViewRoute.h"
#import "NLDRelativeViewRouteFactory.h"

@implementation NLDRemoteEventModel

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
    
    self.targetViewRoute = [[NLDTargetViewRoute alloc] initWithDictionary:dict];
    
    /*
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj == [NSNull null]) {
            obj = nil;
        }
        
        if ([key isEqualToString:@"targetViewRoute"] && [obj isKindOfClass:[NSDictionary class]]) {
            self.targetViewRoute = [[NLDTargetViewRoute alloc] initWithDictionary:obj];
        } else if ([key isEqualToString:@"relativeViewRoute"] && [obj isKindOfClass:[NSDictionary class]]) {
            self.relativeViewRoute = [NLDRelativeViewRouteFactory relativeViewRouteWithDic:obj];
        }
    }];
     */
}

@end
