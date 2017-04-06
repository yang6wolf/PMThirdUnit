//
//  NSObject+MethodSwizzle.h
//  LDEventCollection
//
//  Created by 高振伟 on 16/10/5.
//  Copyright © 2016 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (MethodSwizzle)

+ (BOOL)NLD_swizzSelector:(SEL)originSelector referProtocol:(Protocol *)referToProtocol newSel:(SEL)newSelector usingBlock:(id)block;

+ (void)NLD_swizzStaticSel:(SEL)origSelector newSel:(SEL)newSelector;

@end
