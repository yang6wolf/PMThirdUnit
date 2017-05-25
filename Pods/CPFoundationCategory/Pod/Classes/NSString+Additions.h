//
//  NSString+Additions.h
//  Pods
//
//  Created by xuguoxing on 14-9-19.
//
//  url字符串编解码、url的参数字典、md5加密等

#import <Foundation/Foundation.h>


@interface NSString (Additions)


- (BOOL)isEmptyOrWhitespace;

- (NSString *)URLEncodedString ;

- (NSString*)URLDecodedString;

- (NSData *)base16Data;

- (NSString*)md5String;

- (NSDictionary *)urlParamsDecodeDictionary;

- (BOOL)isAllChinese;

- (BOOL)containsChinese;

@end
