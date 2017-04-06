//
//  MAUtils.h
//  MobileAnalysis
//
//  Created by zhang jie on 13-4-22.
//  Copyright (c) 2013年 zhang jie. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef NETEASEMA_LOG
#  define NETEASE_LOG(...) NSLog(__VA_ARGS__)
#else
#  define NETEASE_LOG(...)
#endif


@interface NSString (NetEaseMAMd5HexDigest)
- (NSString*)neteasema_md5HexDigest;
@end

@interface NSDictionary (NetEaseMADictionary)
- (long long)neteasema_longlongValueForKey:(NSString *)key defaultValue:(long long)defaultValue;
- (NSString *)neteasema_stringValueForKey:(NSString *)key;
@end

@interface NSMutableDictionary (NetEaseMAMutableDictionary)
-(void)neteasema_setLongLong:(long long)value forKey:(id)key;
@end


@interface NetEaseMaUtils : NSObject
+ (NSString *)getOldDeviceId;
+ (NSString *)getAppVersion;
+ (NSString *)getBuildVersion;
+ (NSString *)getDeviceModel;
+ (NSString *)getSystemVersion;
+ (NSString *)getResolution;
+ (NSString *)createUUIDString;
@end

@interface NetEaseMaUtils(Encrypt)
+ (void)resetEncyptKeyWithAppId:(NSString *)appid;
+ (NSString *)zipAndEncrypt:(NSData *)data;
@end

@interface NetEaseMaUtils(GZip)
+(NSData*) gzipData: (NSData*)pUncompressedData;
+(NSData *)ungzipData:(NSData *)compressedData;
@end

@interface NetEaseMaUtils(Base64)
+(NSData *)encodeDataBase64:(NSData *)data;
+(NSString *)stringByEncodingDataBase64:(NSData *)data;
+(NSData *)decodeDataBase64:(NSData *)data;
@end

@interface NetEaseMaUtils(Telephony)
+ (NSString*)getNetworkStatus;
+ (NSString*)getTeleOperator;
@end


