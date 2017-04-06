//
//  NSThread+NLDCallStackExtension.h
//  LDEventCollection
//
//  Created by SongLi on 5/11/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSThread (NLDCallStackExtension)

/**
 *  当前函数调用栈(不包括isInternalMethodCallAtIndex调用)的第index层的调用是从Cocoa框架调起的(不是由开发人员调起的)
 *  @param  index   index从0开始，不计本方法(isInternalMethodCallAtIndex:)调用层，index不要大于254。
 *  @return 如果是由Cocoa框架调起的则返回YES，如果是由开发人员调起的则返回NO
 */
+ (BOOL)isInternalMethodCallAtIndex:(NSInteger)index;

@end
