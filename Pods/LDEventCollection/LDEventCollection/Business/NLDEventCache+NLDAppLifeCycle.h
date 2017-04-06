//
//  NLDEventCache+NLDAppLifeCycle.h
//  LDEventCollection
//
//  Created by SongLi on 6/3/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import "NLDEventCache.h"

@interface NLDEventCache (NLDAppLifeCycle)

+ (void)NLD_swizzForAppTerminate;

/**
 *  监听NSUncaughtException
 */
- (void)setupUncaughtExceptionHandler;

@end
