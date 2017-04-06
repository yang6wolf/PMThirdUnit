//
//  LDPMethodSwizz.h
//  LDPositioningDemo
//
//  Created by 高振伟 on 16/8/15.
//  Copyright © 2016年 wuxu. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  使用Block实现对类现有方法的替换
 *
 *  @return 成功返回YES，失败返回NO
 */
BOOL LDP_replaceMethodWithBlock(Class c, SEL origSEL, SEL newSEL, id block);