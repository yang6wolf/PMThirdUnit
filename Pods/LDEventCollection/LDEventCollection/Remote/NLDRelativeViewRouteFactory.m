//
//  NLDRelativeViewFactory.m
//  Pods
//
//  Created by 高振伟 on 16/8/13.
//
//

#import "NLDRelativeViewRouteFactory.h"
#import "NLDRelativeUnreuseViewRoute.h"
#import "NLDRelativeReuseViewRoute.h"

@implementation NLDRelativeViewRouteFactory

+ (id<NLDRelativeViewRoute>)relativeViewRouteWithDic:(NSDictionary *)dic
{
    id<NLDRelativeViewRoute> relativeViewRoute = nil;
    NSString *type = dic[@"type"];
    if ([type isEqualToString:@"0"]) {
        relativeViewRoute = [[NLDRelativeUnreuseViewRoute alloc] initWithDictionary:dic];
    } else if ([type isEqualToString:@"1"] || [type isEqualToString:@"2"]) {
        relativeViewRoute = [[NLDRelativeReuseViewRoute alloc] initWithDictionary:dic];
    }
    
    return relativeViewRoute;
}

@end
