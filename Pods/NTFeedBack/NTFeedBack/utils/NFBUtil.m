//
//  NFBUtil.m
//  NTFeedBack
//
//  Created by  龙会湖 on 14-7-21.
//  Copyright (c) 2014年 netease. All rights reserved.
//

#import "NFBUtil.h"

@implementation NFBUtil

+ (BOOL)isIOS7 {
    NSInteger osMainVersion = [UIDevice currentDevice].systemVersion.integerValue;
    return (osMainVersion>=7);
}

+ (NSString*)getStringFromDictionary:(NSDictionary *)dictionary ofKey:(NSString *)key
{
    NSObject *object = [dictionary objectForKey:key];
    if (object==nil||object==[NSNull null]) {
        return @"";
    }
    if ([object isKindOfClass:[NSString class]]) {
        return (NSString*)object;
    }
    return [NSString stringWithFormat:@"%@",object];
}

+ (NSInteger)getIntegerFromDictionary:(NSDictionary*)dictionary ofKey:(NSString *)key defaultValue:(NSInteger)defaultValue
{
    NSObject *object = [dictionary objectForKey:key];
    
    if (object == nil || object == [NSNull null]) {
        return defaultValue;
    }
    
    if ([object respondsToSelector:@selector(integerValue)]) {
        return [(id)object integerValue];
    }
    return defaultValue;
}


+ (NSString *)URLEncodedString:(NSString *)string
{
    return (__bridge_transfer NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)[string mutableCopy], NULL, CFSTR("￼=,!$&'()*+;@?\n\"<>#\t :/"), kCFStringEncodingUTF8);
}

+ (void)alertView:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}

+ (NSData *)imageToData:(UIImage *)image {
    NSData *data = UIImageJPEGRepresentation(image, 1);
    if (data == nil) {
        data = UIImagePNGRepresentation(image);
    }
    return data;
}

+ (NSDate *)dateFromString:(NSString*)dateString withFormat:(NSString*)format {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter dateFromString:dateString];
}

+ (NSString *)stringFromDate:(NSDate*)date withFormat:(NSString*)format {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:date];
}

+ (CGSize)drawSizeOfString:(NSString*)string withFont:(UIFont*)font constrainedToSize:(CGSize)size {
    if ([self isIOS7]) {
        return [string boundingRectWithSize:size
                             options:NSStringDrawingUsesLineFragmentOrigin
                                 attributes:@{NSFontAttributeName:font}
                             context:nil].size;
    } else {
        return [string sizeWithFont:font constrainedToSize:size];
    }
}

@end
