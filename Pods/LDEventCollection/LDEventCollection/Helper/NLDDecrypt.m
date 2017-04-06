//
//  NLDDecrypt.m
//  Pods
//
//  Created by 高振伟 on 16/10/19.
//
//

#import "NLDDecrypt.h"
#include <CommonCrypto/CommonCryptor.h>
#import "NLDBase64Code.h"

@implementation NLDDecrypt

+ (NSData *)decryptPostData:(NSData *)data
{
    NSMutableData *decryptData = [NSMutableData dataWithCapacity:128];
    
    char * unBase64Buffer = malloc([data length]+1);
    size_t unBase64BufferLength = [data length]+1;
    NLDBase64DecodeData([data bytes],[data length],unBase64Buffer,&unBase64BufferLength);
    unBase64Buffer[unBase64BufferLength] = 0;
    
    char * decryptBuffer = malloc([data length]+1);
    size_t decryptBufferLength = 0;
    
    char key[24] = "^1Q2W3E!!E3W2Q1^^1Q2W3E!";
    CCCryptorStatus status = CCCrypt(kCCDecrypt,kCCAlgorithm3DES , kCCOptionECBMode, key, kCCKeySize3DES,NULL, unBase64Buffer, unBase64BufferLength, decryptBuffer, unBase64BufferLength, &decryptBufferLength);
    if (status==kCCSuccess) {
        int padlength = decryptBuffer[decryptBufferLength-1];
        [decryptData appendBytes:decryptBuffer length:decryptBufferLength-padlength];
    }
    free(unBase64Buffer);
    free(decryptBuffer);
    return decryptData;
}

@end
