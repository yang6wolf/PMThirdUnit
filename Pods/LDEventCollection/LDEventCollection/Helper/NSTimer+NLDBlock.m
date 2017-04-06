//
//  NSTimer+NLDBlock.m
//  LDEventCollection
//
//  Created by SongLi on 5/31/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import "NSTimer+NLDBlock.h"

@implementation NSTimer (NLDBlock)

+ (NSTimer *)NLD_timerWithTimeInterval:(NSTimeInterval)ti repeats:(BOOL)yesOrNo executeBlock:(void(^)(NSTimer *timer))block
{
    NSTimer *timer = [self scheduledTimerWithTimeInterval:ti target:self selector:@selector(NLD_timerTimeUp:) userInfo:[block copy] repeats:yesOrNo];
    return timer;
}

+ (void)NLD_timerTimeUp:(NSTimer *)sender
{
    void(^block)(NSTimer *timer) = sender.userInfo;
    !block ?: block(sender);
}

@end
