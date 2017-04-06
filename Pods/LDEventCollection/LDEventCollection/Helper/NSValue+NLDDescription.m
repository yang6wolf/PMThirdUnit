//
//  NSValue+NLDDescription.m
//  LDEventCollection
//
//  Created by SongLi on 5/24/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import "NSValue+NLDDescription.h"

@implementation NSValue (NLDDescription)

- (nonnull NSString *)NLD_CGRectDescription
{
    CGRect rect = [self CGRectValue];
    return [NSString stringWithFormat:@"{%.2f, %.2f, %.2f, %.2f}", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height];
}

- (nonnull NSString *)NLD_CGPointDescription
{
    CGPoint point = [self CGPointValue];
    return [NSString stringWithFormat:@"(%.2f, %.2f)", point.x, point.y];
}

@end
