//
//  NSTimer+NLDBlock.h
//  LDEventCollection
//
//  Created by SongLi on 5/31/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (NLDBlock)

+ (NSTimer *)NLD_timerWithTimeInterval:(NSTimeInterval)ti repeats:(BOOL)yesOrNo executeBlock:(void(^)(NSTimer *timer))block;

@end
