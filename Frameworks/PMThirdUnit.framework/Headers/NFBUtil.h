//
//  NFBUtil.h
//  NTFeedBack
//
//  Created by  龙会湖 on 14-7-21.
//  Copyright (c) 2014年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface NFBUtil : NSObject
+ (BOOL)isIOS7;
+ (NSString*)getStringFromDictionary:(NSDictionary*)dictionary ofKey:(NSString*)key;
+ (NSInteger)getIntegerFromDictionary:(NSDictionary*)dictionary ofKey:(NSString *)key defaultValue:(NSInteger)defaultValue;
+ (NSString *)URLEncodedString:(NSString *)string;

+ (void)alertView:(NSString*)message;

+ (NSData *)imageToData:(UIImage *)image;
+ (NSDate *)dateFromString:(NSString*)dateString withFormat:(NSString*)format;
+ (NSString *)stringFromDate:(NSDate*)date withFormat:(NSString*)format;

+ (CGSize)drawSizeOfString:(NSString*)string withFont:(UIFont*)font constrainedToSize:(CGSize)size;

@end
