//
//  NSString+NLDAddition.h
//  LDEventCollection
//
//  Created by SongLi on 6/2/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NLDAddition)

- (nullable NSString *)NLD_md5String;

+ (nullable NSString *)NLD_RandomUUIDString;

- (nonnull NSString *)NLD_removeSwiftModule;

@end
