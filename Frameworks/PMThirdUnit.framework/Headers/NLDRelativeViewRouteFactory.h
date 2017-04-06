//
//  NLDRelativeViewFactory.h
//  Pods
//
//  Created by 高振伟 on 16/8/13.
//
//

#import <Foundation/Foundation.h>
#import "NLDRelativeViewRoute.h"

@interface NLDRelativeViewRouteFactory : NSObject

+ (id<NLDRelativeViewRoute>)relativeViewRouteWithDic:(NSDictionary *)dic;

@end
