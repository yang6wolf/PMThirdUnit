//
//  ZBTimer.h
//
//  Created by Long Huihu on 13-4-15.
//  Copyright (c) 2013年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  ZBTimer对象避免timer引起的循环引用,在使用timer的controller类里面创建该对象，通过fireBlock来执行动作，controller的dealloc方法里面
 *  调用ZBTimer的invalidate方法
 */
@interface NFBTimer : NSObject
@property(nonatomic,readonly) NSTimeInterval interval;
@property(nonatomic,readonly) NSTimeInterval ellapsedInterval;
@property(nonatomic,readonly) NSUInteger ellapsedTicks;
@property(nonatomic,strong) NSDate *startDate;
+ (NFBTimer*)timerWithInterval:(NSTimeInterval)interval repeats:(BOOL)repeats onFire:(void (^)())fireBlock;
- (void)invalidate;
- (BOOL)isValid;
@end
