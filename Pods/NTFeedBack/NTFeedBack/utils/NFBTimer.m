//
//  ZBTimer.m
//  movie163
//
//  Created by Long Huihu on 13-4-15.
//  Copyright (c) 2013年 netease. All rights reserved.
//

#import "NFBTimer.h"

@implementation NFBTimer {
    NSTimer *_timer;
    NSTimeInterval _ellapsedInterval;
    void (^_fireBlock)();
}

+ (NFBTimer*)timerWithInterval:(NSTimeInterval)interval repeats:(BOOL)repeats onFire:(void (^)())fireBlock {
    NFBTimer *timerTarget = [[NFBTimer alloc] init];
    [timerTarget startTimerWithInterval:interval repeats:repeats onFire:fireBlock];
    return timerTarget;
}

- (NSTimeInterval)interval {
    return _timer.timeInterval;
}

- (void)startTimerWithInterval:(NSTimeInterval)interval repeats:(BOOL)repeats onFire:(void (^)())fireBlock {
    [_timer invalidate];
    _timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(timerFired) userInfo:nil repeats:repeats];
    _startDate = [NSDate date];
    _fireBlock = [fireBlock copy];
}

- (void)invalidate {
    [_timer invalidate];
}

- (BOOL)isValid {
    return [_timer isValid];
}

- (void)timerFired {
    if (_fireBlock) {
        _fireBlock();
    }
    _ellapsedInterval += _timer.timeInterval;
    _ellapsedTicks += 1;
}

@end
