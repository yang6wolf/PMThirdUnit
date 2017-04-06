//
//  MAUtils.m
//  MobileAnalysis
//
//  Created by zhang jie on 13-4-22.
//  Copyright (c) 2013年 zhang jie. All rights reserved.
//
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <CommonCrypto/CommonDigest.h>
#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <CommonCrypto/CommonCryptor.h>
#import "zlib.h"
#import "NetEaseMAUtils.h"
#import "Reachability.h"
#import "NeteaseMANetworkManager.h"


@implementation NSString (NetEaseMAMd5HexDigest)

- (NSString *)neteasema_md5HexDigest {
    const char* str = [self UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5(str, (CC_LONG)strlen(str), result);
    NSMutableString *returnHashSum = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for (int i=0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [returnHashSum appendFormat:@"%02x", result[i]];
    }
	return returnHashSum;
}
@end

@implementation NetEaseMaUtils

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Methods

// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
// Accidentally munged during previous update. Fixed thanks to erica sadun & mlamb.
+ (NSString *)macaddress{
    
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return outstring;
}


+ (NSString *)deviceIdBasedOnMacAddress{
    static NSString *uniqueId = nil;
    if (uniqueId==nil) {
        uniqueId = [[NSUserDefaults standardUserDefaults] objectForKey:@"random_device_id"];
        if (uniqueId==nil) {
            NSString *macaddress = [self macaddress];
            uniqueId= [macaddress neteasema_md5HexDigest];
            
            if (uniqueId==nil) {
                srandom([[NSDate date] timeIntervalSince1970]);
                uniqueId = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", (Byte)random(), (Byte)random(), (Byte)random(), (Byte)random(), (Byte)random(), (Byte)random()];
                [[NSUserDefaults standardUserDefaults] setObject:uniqueId forKey:@"random_device_id"];
            }
        }
    }
    return uniqueId;
}


+ (NSString *)getOldDeviceId {
    NSString *version = [UIDevice currentDevice].systemVersion;
    NSInteger osMainVersion = version.integerValue;
    if (osMainVersion==6) {
        return [self deviceIdBasedOnMacAddress];
    }
    return nil;
}

/*!
 @method getAppVersion
 @abstract Gets the pretty string for this application's version.
 @return The application's version as a pretty string
 */
+ (NSString *)getAppVersion {
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)getBuildVersion {
    NSMutableString *OSPre=[[NSMutableString alloc]initWithString:@"iOS"];
    NSString *osVersion=[[UIDevice currentDevice] systemVersion];
	[OSPre appendString:osVersion];
    return OSPre;
}


/*!
 @method getDeviceModel
 @abstract Gets the device model string.
 @return a platform string identifying the device
 */
+ (NSString *)getDeviceModel {
    //SDK的方法渠道的信息有限，使用新的方法，可以区分iphone4[iPhone3,1]和iphone4s[iPhone4,1]
	//return [[UIDevice currentDevice] model];
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    if (!platform) {
        platform = @"未知";
    }
    return platform;
}

/*!
 @method getSystemVersion
 @abstract Gets the device model string.
 @return a platform string identifying the device
 */
+ (NSString *)getSystemVersion {
	return [[UIDevice currentDevice] systemVersion];
}

+ (NSString *)getResolution
{
    CGRect rect_screen = [[UIScreen mainScreen] bounds];
    CGFloat scale_screen = [UIScreen mainScreen].scale;
    CGSize size_screen = rect_screen.size;
    NSInteger w=(NSInteger)(size_screen.width)*(NSInteger)scale_screen;
    NSInteger h=(NSInteger)(size_screen.height)*(NSInteger)scale_screen;
    
    return [NSString stringWithFormat:@"%ld*%ld",(long)w,(long)h];
}

+ (NSString *)createUUIDString {
    CFUUIDRef uuid_ref= CFUUIDCreate(NULL);
    
    CFStringRef uuid_string_ref = CFUUIDCreateString(NULL,uuid_ref);
    NSString *uuid_string = (__bridge NSString*)uuid_string_ref;
    
    CFRelease(uuid_string_ref);
    CFRelease(uuid_ref);
    
    return uuid_string;
}

@end

@implementation NSDictionary (NetEaseMADictionary)

- (long long)neteasema_longlongValueForKey:(NSString *)key defaultValue:(long long)defaultValue
{
    NSObject *object = [self objectForKey:key];
    if (object==nil||object==[NSNull null]) {
        return defaultValue;
    }
    if ([object respondsToSelector:@selector(longLongValue)]) {
        return [(id)object longLongValue];
    }
    return defaultValue;
}


- (NSString *)neteasema_stringValueForKey:(NSString *)key {
    NSObject *object = [self objectForKey:key];
    if (object==nil||object==[NSNull null]) {
        return @"";
    }
    if ([object isKindOfClass:[NSString class]]) {
        return (NSString*)object;
    }
    return [NSString stringWithFormat:@"%@",object];
}
@end



@implementation NSMutableDictionary (NetEaseMAMutableDictionary)

-(void)neteasema_setLongLong:(long long)value forKey:(id)key
{
    [self setValue:[NSNumber numberWithLongLong:value]
            forKey:key];
}

@end


@implementation NetEaseMaUtils(Encrypt)

// 加密方法
+(NSString*)encrypt:(NSData *)textData gkey:(Byte *)gkey gIv:(Byte *)gIv
{
    Byte *textByte=(Byte *)[textData bytes];
    NSInteger textByteLen=[textData length];
    NSInteger bufferPtrSize = (textByteLen + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    void *bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset(bufferPtr, 0x0, bufferPtrSize);
    
    CCCryptorStatus ccStatus;
    size_t movedBytes = 0;
    
    ccStatus = CCCrypt(kCCEncrypt,
                       kCCAlgorithm3DES,
                       kCCOptionPKCS7Padding,
                       gkey,
                       kCCKeySize3DES,
                       gIv,
                       textByte,
                       textByteLen,
                       bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    
    if (ccStatus == kCCSuccess) {
        
        
        NSData *data = [NSData dataWithBytes:bufferPtr length:movedBytes];
        if(bufferPtr)
        {
            free(bufferPtr);
            bufferPtr=NULL;
        }
        
        NSString *result = [NetEaseMaUtils stringByEncodingDataBase64:data];
        return result;
    }else{
        if(bufferPtr)
        {
            free(bufferPtr);
            bufferPtr=NULL;
        }
        
        return nil;
    }
}

// 解密方法
+ (NSData *)decrypt:(NSString *)encryptText gkey:(Byte *)gkey gIv:(Byte *)gIv{
    NSData *encryptData = [NetEaseMaUtils decodeDataBase64:[encryptText dataUsingEncoding:NSUTF8StringEncoding]];
    NSInteger bufferPtrSize = ([encryptData length] + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    void *bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset(bufferPtr, 0x0, bufferPtrSize);
    
    CCCryptorStatus ccStatus;
    size_t movedBytes = 0;
    
    ccStatus = CCCrypt(kCCDecrypt,
                       kCCAlgorithm3DES,
                       kCCOptionPKCS7Padding,
                       gkey,
                       kCCKeySize3DES,
                       gIv,
                       [encryptData bytes],
                       [encryptData length],
                       bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    
    if (ccStatus == kCCSuccess) {
        
        NSData *data = [NSData dataWithBytes:bufferPtr length:movedBytes];
        if(bufferPtr)
        {
            free(bufferPtr);
            bufferPtr=NULL;
        }
        
        
        return data;
    }else{
        if(bufferPtr)
        {
            free(bufferPtr);
            bufferPtr=NULL;
        }
        
        return nil;
    }
    
}

static Byte *transformedEncryptKey = NULL;

static Byte staticEncryptKey[24] = { 0xef, 0x2b, 0xcc, 0xdc, 0x9b, 0x3b, 0xf7, 0x2a,
    0x68, 0xad, 0xeb, 0xc1, 0x7d, 0x40, 0x66, 0xb8, 0x72, 0xe3, 0x78, 0x2f,
    0x5e, 0x7, 0x77, 0xd5 };

static Byte encryptVector[8] = { 0x7, 0x77, 0xd5, 0xc1, 0x7d, 0x40, 0x66, 0xb8 };


+ (void)resetEncyptKeyWithAppId:(NSString *)appid
{
    if (!transformedEncryptKey) {
        transformedEncryptKey=(Byte *)malloc(sizeof(Byte)*24);
    }
    NSData* bytes = [appid dataUsingEncoding:NSUTF8StringEncoding];
    Byte *B = (Byte *)[bytes bytes];
    NSInteger length=[bytes length];
    
    for (int i = 0; i < 24; i++)
    {
        switch (i% 3)
        {
            case 0:
                transformedEncryptKey[i] = (Byte) (staticEncryptKey[i] ^ B[i%length]);
                break;
            case 1:
                transformedEncryptKey[i] = (Byte) (staticEncryptKey[i] & B[i%length]);
                break;
            case 2:
                transformedEncryptKey[i] = (Byte) (staticEncryptKey[i] | B[i%length]);
                break;
        }
    }
}


//将文本先压缩再3des加密
+ (NSString *)zipAndEncrypt:(NSData *)data
{
    NSString *result=nil;
    
    if(data.length>0&&transformedEncryptKey&&encryptVector)
    {
        NSData *zipData=[NetEaseMaUtils gzipData:data];
        result=[NetEaseMaUtils encrypt:zipData gkey:transformedEncryptKey gIv:encryptVector];
    }
    return result;
}

@end

@implementation NetEaseMaUtils(GZip)

+(NSData*) gzipData: (NSData*)pUncompressedData
{
    if (!pUncompressedData || [pUncompressedData length] == 0)
    {
        NETEASE_LOG(@"%s: Error: Can't compress an empty or null NSData object.", __func__);
        return nil;
    }
    
    z_stream zlibStreamStruct;
    zlibStreamStruct.zalloc    = Z_NULL; // Set zalloc, zfree, and opaque to Z_NULL so
    zlibStreamStruct.zfree     = Z_NULL; // that when we call deflateInit2 they will be
    zlibStreamStruct.opaque    = Z_NULL; // updated to use default allocation functions.
    zlibStreamStruct.total_out = 0; // Total number of output bytes produced so far
    zlibStreamStruct.next_in   = (Bytef*)[pUncompressedData bytes]; // Pointer to input bytes
    zlibStreamStruct.avail_in  = (unsigned int)[pUncompressedData length]; // Number of input bytes left to process
    
    int initError = deflateInit2(&zlibStreamStruct, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY);
    if (initError != Z_OK)
    {
        NSString *errorMsg = nil;
        switch (initError)
        {
            case Z_STREAM_ERROR:
                errorMsg = @"Invalid parameter passed in to function.";
                break;
            case Z_MEM_ERROR:
                errorMsg = @"Insufficient memory.";
                break;
            case Z_VERSION_ERROR:
                errorMsg = @"The version of zlib.h and the version of the library linked do not match.";
                break;
            default:
                errorMsg = @"Unknown error code.";
                break;
        }
        NETEASE_LOG(@"%s: deflateInit2() Error: \"%@\" Message: \"%s\"", __func__, errorMsg, zlibStreamStruct.msg);
        //[errorMsg release];
        return nil;
    }
    
    // Create output memory buffer for compressed data. The zlib documentation states that
    // destination buffer size must be at least 0.1% larger than avail_in plus 12 bytes.
    NSMutableData *compressedData = [NSMutableData dataWithLength:[pUncompressedData length] * 1.01 + 12];
    
    int deflateStatus;
    do
    {
        // Store location where next byte should be put in next_out
        zlibStreamStruct.next_out = [compressedData mutableBytes] + zlibStreamStruct.total_out;
        
        // Calculate the amount of remaining free space in the output buffer
        // by subtracting the number of bytes that have been written so far
        // from the buffer's total capacity
        zlibStreamStruct.avail_out = (unsigned int)([compressedData length] - zlibStreamStruct.total_out);
        deflateStatus = deflate(&zlibStreamStruct, Z_FINISH);
        
    } while ( deflateStatus == Z_OK );
    
    // Check for zlib error and convert code to usable error message if appropriate
    if (deflateStatus != Z_STREAM_END)
    {
        NSString *errorMsg = nil;
        switch (deflateStatus)
        {
            case Z_ERRNO:
                errorMsg = @"Error occured while reading file.";
                break;
            case Z_STREAM_ERROR:
                errorMsg = @"The stream state was inconsistent (e.g., next_in or next_out was NULL).";
                break;
            case Z_DATA_ERROR:
                errorMsg = @"The deflate data was invalid or incomplete.";
                break;
            case Z_MEM_ERROR:
                errorMsg = @"Memory could not be allocated for processing.";
                break;
            case Z_BUF_ERROR:
                errorMsg = @"Ran out of output buffer for writing compressed bytes.";
                break;
            case Z_VERSION_ERROR:
                errorMsg = @"The version of zlib.h and the version of the library linked do not match.";
                break;
            default:
                errorMsg = @"Unknown error code.";
                break;
        }
        NETEASE_LOG(@"%s: zlib error while attempting compression: \"%@\" Message: \"%s\"", __func__, errorMsg, zlibStreamStruct.msg);
        
        
        // Free data structures that were dynamically created for the stream.
        deflateEnd(&zlibStreamStruct);
        
        return nil;
    }
    // Free data structures that were dynamically created for the stream.
    deflateEnd(&zlibStreamStruct);
    [compressedData setLength: zlibStreamStruct.total_out];
    NETEASE_LOG(@"%s: Compressed file from %.2f KB to %.2f KB", __func__, [pUncompressedData length]/1024.0f, [compressedData length]/1024.0f);
    
    return compressedData;
}

+(NSData *)ungzipData:(NSData *)compressedData
{
    if ([compressedData length] == 0)
        return compressedData;
    
    unsigned full_length = (unsigned int)[compressedData length];
    unsigned half_length = (unsigned int)[compressedData length] / 2;
    
    NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
    BOOL done = NO;
    int status;
    
    z_stream strm;
    strm.next_in = (Bytef *)[compressedData bytes];
    strm.avail_in = (unsigned int)[compressedData length];
    strm.total_out = 0;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    if (inflateInit2(&strm, (15+32)) != Z_OK)
        return nil;
    
    while (!done) {
        // Make sure we have enough room and reset the lengths.
        if (strm.total_out >= [decompressed length]) {
            [decompressed increaseLengthBy: half_length];
        }
        strm.next_out = [decompressed mutableBytes] + strm.total_out;
        strm.avail_out = (unsigned int)([decompressed length] - strm.total_out);
        // Inflate another chunk.
        status = inflate (&strm, Z_SYNC_FLUSH);
        if (status == Z_STREAM_END) {
            done = YES;
        } else if (status != Z_OK) {
            break;
        }
    }
    
    if (inflateEnd (&strm) != Z_OK)
        return nil;
    // Set real length.
    if (done) {
        [decompressed setLength: strm.total_out];
        return [NSData dataWithData: decompressed];
    }
    return nil;
}

@end


@implementation NetEaseMaUtils(Base64)

static const char *kBase64EncodeChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
static const char kBase64PaddingChar = '=';
static const char kBase64InvalidChar = 99;


static const char kBase64DecodeChars[] = {
    // This array was generated by the following code:
    // #include <sys/time.h>
    // #include <stdlib.h>
    // #include <string.h>
    // main()
    // {
    //   static const char Base64[] =
    //     "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    //   char *pos;
    //   int idx, i, j;
    //   printf("    ");
    //   for (i = 0; i < 255; i += 8) {
    //     for (j = i; j < i + 8; j++) {
    //       pos = strchr(Base64, j);
    //       if ((pos == NULL) || (j == 0))
    //         idx = 99;
    //       else
    //         idx = pos - Base64;
    //       if (idx == 99)
    //         printf(" %2d,     ", idx);
    //       else
    //         printf(" %2d/*%c*/,", idx, j);
    //     }
    //     printf("\n    ");
    //   }
    // }
    99,      99,      99,      99,      99,      99,      99,      99,
    99,      99,      99,      99,      99,      99,      99,      99,
    99,      99,      99,      99,      99,      99,      99,      99,
    99,      99,      99,      99,      99,      99,      99,      99,
    99,      99,      99,      99,      99,      99,      99,      99,
    99,      99,      99,      62/*+*/, 99,      99,      99,      63/*/ */,
    52/*0*/, 53/*1*/, 54/*2*/, 55/*3*/, 56/*4*/, 57/*5*/, 58/*6*/, 59/*7*/,
    60/*8*/, 61/*9*/, 99,      99,      99,      99,      99,      99,
    99,       0/*A*/,  1/*B*/,  2/*C*/,  3/*D*/,  4/*E*/,  5/*F*/,  6/*G*/,
    7/*H*/,  8/*I*/,  9/*J*/, 10/*K*/, 11/*L*/, 12/*M*/, 13/*N*/, 14/*O*/,
    15/*P*/, 16/*Q*/, 17/*R*/, 18/*S*/, 19/*T*/, 20/*U*/, 21/*V*/, 22/*W*/,
    23/*X*/, 24/*Y*/, 25/*Z*/, 99,      99,      99,      99,      99,
    99,      26/*a*/, 27/*b*/, 28/*c*/, 29/*d*/, 30/*e*/, 31/*f*/, 32/*g*/,
    33/*h*/, 34/*i*/, 35/*j*/, 36/*k*/, 37/*l*/, 38/*m*/, 39/*n*/, 40/*o*/,
    41/*p*/, 42/*q*/, 43/*r*/, 44/*s*/, 45/*t*/, 46/*u*/, 47/*v*/, 48/*w*/,
    49/*x*/, 50/*y*/, 51/*z*/, 99,      99,      99,      99,      99,
    99,      99,      99,      99,      99,      99,      99,      99,
    99,      99,      99,      99,      99,      99,      99,      99,
    99,      99,      99,      99,      99,      99,      99,      99,
    99,      99,      99,      99,      99,      99,      99,      99,
    99,      99,      99,      99,      99,      99,      99,      99,
    99,      99,      99,      99,      99,      99,      99,      99,
    99,      99,      99,      99,      99,      99,      99,      99,
    99,      99,      99,      99,      99,      99,      99,      99,
    99,      99,      99,      99,      99,      99,      99,      99,
    99,      99,      99,      99,      99,      99,      99,      99,
    99,      99,      99,      99,      99,      99,      99,      99,
    99,      99,      99,      99,      99,      99,      99,      99,
    99,      99,      99,      99,      99,      99,      99,      99,
    99,      99,      99,      99,      99,      99,      99,      99,
    99,      99,      99,      99,      99,      99,      99,      99,
    99,      99,      99,      99,      99,      99,      99,      99
};

static BOOL IsSpace(unsigned char c) {
    // we use our own mapping here because we don't want anything w/ locale
    // support.
    static BOOL kSpaces[256] = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 1,  // 0-9
        1, 1, 1, 1, 0, 0, 0, 0, 0, 0,  // 10-19
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 20-29
        0, 0, 1, 0, 0, 0, 0, 0, 0, 0,  // 30-39
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 40-49
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 50-59
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 60-69
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 70-79
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 80-89
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 90-99
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 100-109
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 110-119
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 120-129
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 130-139
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 140-149
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 150-159
        1, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 160-169
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 170-179
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 180-189
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 190-199
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 200-209
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 210-219
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 220-229
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 230-239
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // 240-249
        0, 0, 0, 0, 0, 1,              // 250-255
    };
    return kSpaces[c];
}


static NSUInteger CalcEncodedLength(NSUInteger srcLen, BOOL padded) {
    NSUInteger intermediate_result = 8 * srcLen + 5;
    NSUInteger len = intermediate_result / 6;
    if (padded) {
        len = ((len + 3) / 4) * 4;
    }
    return len;
}

static NSUInteger GuessDecodedLength(NSUInteger srcLen) {
    return (srcLen + 3) / 4 * 3;
}


+(NSData *)encodeDataBase64:(NSData *)data {
    return [self baseEncode:[data bytes]
                     length:[data length]
                    charset:kBase64EncodeChars
                     padded:YES];
}

+(NSString *)stringByEncodingDataBase64:(NSData *)data {
    NSString *result = nil;
    NSData *converted = [self baseEncode:[data bytes]
                                  length:[data length]
                                 charset:kBase64EncodeChars
                                  padded:YES];
    if (converted) {
        result = [[NSString alloc] initWithData:converted
                                       encoding:NSASCIIStringEncoding];
    }
    return result;
}

+(NSData *)baseEncode:(const void *)bytes
               length:(NSUInteger)length
              charset:(const char *)charset
               padded:(BOOL)padded {
    // how big could it be?
    NSUInteger maxLength = CalcEncodedLength(length, padded);
    // make space
    NSMutableData *result = [NSMutableData data];
    [result setLength:maxLength];
    // do it
    NSUInteger finalLength = [self baseEncode:bytes
                                       srcLen:length
                                    destBytes:[result mutableBytes]
                                      destLen:[result length]
                                      charset:charset
                                       padded:padded];
    if (finalLength) {
        NSAssert(finalLength == maxLength, @"how did we calc the length wrong?");
    } else {
        // shouldn't happen, this means we ran out of space
        result = nil;
    }
    return result;
}

+(NSUInteger)baseEncode:(const char *)srcBytes
                 srcLen:(NSUInteger)srcLen
              destBytes:(char *)destBytes
                destLen:(NSUInteger)destLen
                charset:(const char *)charset
                 padded:(BOOL)padded {
    if (!srcLen || !destLen || !srcBytes || !destBytes) {
        return 0;
    }
    
    char *curDest = destBytes;
    const unsigned char *curSrc = (const unsigned char *)(srcBytes);
    
    // Three bytes of data encodes to four characters of cyphertext.
    // So we can pump through three-byte chunks atomically.
    while (srcLen > 2) {
        // space?
        NSAssert(destLen >= 4, @"our calc for encoded length was wrong");
        curDest[0] = charset[curSrc[0] >> 2];
        curDest[1] = charset[((curSrc[0] & 0x03) << 4) + (curSrc[1] >> 4)];
        curDest[2] = charset[((curSrc[1] & 0x0f) << 2) + (curSrc[2] >> 6)];
        curDest[3] = charset[curSrc[2] & 0x3f];
        
        curDest += 4;
        curSrc += 3;
        srcLen -= 3;
        destLen -= 4;
    }
    
    // now deal with the tail (<=2 bytes)
    switch (srcLen) {
        case 0:
            // Nothing left; nothing more to do.
            break;
        case 1:
            // One byte left: this encodes to two characters, and (optionally)
            // two pad characters to round out the four-character cypherblock.
            NSAssert(destLen >= 2, @"our calc for encoded length was wrong");
            curDest[0] = charset[curSrc[0] >> 2];
            curDest[1] = charset[(curSrc[0] & 0x03) << 4];
            curDest += 2;
            destLen -= 2;
            if (padded) {
                NSAssert(destLen >= 2, @"our calc for encoded length was wrong");
                curDest[0] = kBase64PaddingChar;
                curDest[1] = kBase64PaddingChar;
                curDest += 2;
            }
            break;
        case 2:
            // Two bytes left: this encodes to three characters, and (optionally)
            // one pad character to round out the four-character cypherblock.
            NSAssert(destLen >= 3, @"our calc for encoded length was wrong");
            curDest[0] = charset[curSrc[0] >> 2];
            curDest[1] = charset[((curSrc[0] & 0x03) << 4) + (curSrc[1] >> 4)];
            curDest[2] = charset[(curSrc[1] & 0x0f) << 2];
            curDest += 3;
            destLen -= 3;
            if (padded) {
                NSAssert(destLen >= 1, @"our calc for encoded length was wrong");
                curDest[0] = kBase64PaddingChar;
                curDest += 1;
            }
            break;
    }
    // return the length
    return (curDest - destBytes);
}

+(NSData *)decodeDataBase64:(NSData *)data {
    return [self baseDecode:[data bytes]
                     length:[data length]
                    charset:kBase64DecodeChars
             requirePadding:YES];
}

+(NSData *)baseDecode:(const void *)bytes
               length:(NSUInteger)length
              charset:(const char *)charset
       requirePadding:(BOOL)requirePadding {
    // could try to calculate what it will end up as
    NSUInteger maxLength = GuessDecodedLength(length);
    // make space
    NSMutableData *result = [NSMutableData data];
    [result setLength:maxLength];
    // do it
    NSUInteger finalLength = [self baseDecode:bytes
                                       srcLen:length
                                    destBytes:[result mutableBytes]
                                      destLen:[result length]
                                      charset:charset
                               requirePadding:requirePadding];
    if (finalLength) {
        if (finalLength != maxLength) {
            // resize down to how big it was
            [result setLength:finalLength];
        }
    } else {
        // either an error in the args, or we ran out of space
        result = nil;
    }
    return result;
}

+(NSUInteger)baseDecode:(const char *)srcBytes
                 srcLen:(NSUInteger)srcLen
              destBytes:(char *)destBytes
                destLen:(NSUInteger)destLen
                charset:(const char *)charset
         requirePadding:(BOOL)requirePadding {
    if (!srcLen || !destLen || !srcBytes || !destBytes) {
        return 0;
    }
    
    int decode;
    NSUInteger destIndex = 0;
    int state = 0;
    char ch = 0;
    while (srcLen-- && (ch = *srcBytes++) != 0)  {
        if (IsSpace(ch))  // Skip whitespace
            continue;
        
        if (ch == kBase64PaddingChar)
            break;
        
        decode = charset[(unsigned int)ch];
        if (decode == kBase64InvalidChar)
            return 0;
        
        // Four cyphertext characters decode to three bytes.
        // Therefore we can be in one of four states.
        switch (state) {
            case 0:
                // We're at the beginning of a four-character cyphertext block.
                // This sets the high six bits of the first byte of the
                // plaintext block.
                NSAssert(destIndex < destLen, @"our calc for decoded length was wrong");
                destBytes[destIndex] = decode << 2;
                state = 1;
                break;
            case 1:
                // We're one character into a four-character cyphertext block.
                // This sets the low two bits of the first plaintext byte,
                // and the high four bits of the second plaintext byte.
                NSAssert((destIndex+1) < destLen, @"our calc for decoded length was wrong");
                destBytes[destIndex] |= decode >> 4;
                destBytes[destIndex+1] = (decode & 0x0f) << 4;
                destIndex++;
                state = 2;
                break;
            case 2:
                // We're two characters into a four-character cyphertext block.
                // This sets the low four bits of the second plaintext
                // byte, and the high two bits of the third plaintext byte.
                // However, if this is the end of data, and those two
                // bits are zero, it could be that those two bits are
                // leftovers from the encoding of data that had a length
                // of two mod three.
                NSAssert((destIndex+1) < destLen, @"our calc for decoded length was wrong");
                destBytes[destIndex] |= decode >> 2;
                destBytes[destIndex+1] = (decode & 0x03) << 6;
                destIndex++;
                state = 3;
                break;
            case 3:
                // We're at the last character of a four-character cyphertext block.
                // This sets the low six bits of the third plaintext byte.
                NSAssert(destIndex < destLen, @"our calc for decoded length was wrong");
                destBytes[destIndex] |= decode;
                destIndex++;
                state = 0;
                break;
        }
    }
    
    // We are done decoding Base-64 chars.  Let's see if we ended
    //      on a byte boundary, and/or with erroneous trailing characters.
    if (ch == kBase64PaddingChar) {               // We got a pad char
        if ((state == 0) || (state == 1)) {
            return 0;  // Invalid '=' in first or second position
        }
        if (srcLen == 0) {
            if (state == 2) { // We run out of input but we still need another '='
                return 0;
            }
            // Otherwise, we are in state 3 and only need this '='
        } else {
            if (state == 2) {  // need another '='
                while ((ch = *srcBytes++) && (srcLen-- > 0)) {
                    if (!IsSpace(ch))
                        break;
                }
                if (ch != kBase64PaddingChar) {
                    return 0;
                }
            }
            // state = 1 or 2, check if all remain padding is space
            while ((ch = *srcBytes++) && (srcLen-- > 0)) {
                if (!IsSpace(ch)) {
                    return 0;
                }
            }
        }
    } else {
        // We ended by seeing the end of the string.
        
        if (requirePadding) {
            // If we require padding, then anything but state 0 is an error.
            if (state != 0) {
                return 0;
            }
        } else {
            // Make sure we have no partial bytes lying around.  Note that we do not
            // require trailing '=', so states 2 and 3 are okay too.
            if (state == 1) {
                return 0;
            }
        }
    }
    
    // If then next piece of output was valid and got written to it means we got a
    // very carefully crafted input that appeared valid but contains some trailing
    // bits past the real length, so just toss the thing.
    if ((destIndex < destLen) &&
        (destBytes[destIndex] != 0)) {
        return 0;
    }
    
    return destIndex;
}

@end



@implementation NetEaseMaUtils(Telephony)

+ (NSString*)getNetworkStatus {
    NSString *ret= nil;
    NetworkStatus status = [NeteaseMANetworkManager networkStatus];
    switch(status)
    {
        case ReachableViaWiFi:
        {
            NETEASE_LOG(@"The internet is working via WIFI.");
            ret =@"wifi";
            break;
        }
        case ReachableViaWWAN:
        {
            NETEASE_LOG(@"The internet is working via WWAN.");
            ret =@"wwan";
            CTTelephonyNetworkInfo *info=[[CTTelephonyNetworkInfo alloc] init];
            if ([info respondsToSelector:@selector(currentRadioAccessTechnology)]) {
                ret = info.currentRadioAccessTechnology;
                if ([ret hasPrefix:@"CTRadioAccessTechnology"]) {
                    ret = [ret substringFromIndex:[@"CTRadioAccessTechnology" length]];
                }
            }
            break;
        }
        default:
            break;
    }
    if (ret.length==0) {
        ret = @"unkown";
    }
    return ret;
}

+ (NSString *)getTeleOperator {
    CTTelephonyNetworkInfo *info=[[CTTelephonyNetworkInfo alloc] init];
    NSString *code = info.subscriberCellularProvider.mobileNetworkCode;
    NSString *result = nil;
    if ([code isEqualToString:@"00"] || [code isEqualToString:@"02"] || [code isEqualToString:@"07"]) {
        result=@"cm";
    } else if ([code isEqualToString:@"01"] || [code isEqualToString:@"06"]) {
        result=@"cu";
    } else if ([code isEqualToString:@"03"] || [code isEqualToString:@"05"]) {
        result=@"ct";
    }
    return result;
}


@end

