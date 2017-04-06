//
//  NSIndexPath+NLDDescription.m
//  LDEventCollection
//
//  Created by SongLi on 5/24/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import "NSIndexPath+NLDDescription.h"

@implementation NSIndexPath (NLDDescription)

- (nonnull NSString *)NLD_description
{
    return [NSString stringWithFormat:@"[%ld, %ld]", (long)self.section, (long)self.row];
}

@end
