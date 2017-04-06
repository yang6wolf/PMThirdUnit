//
//  NSData+Crypto.m
//  Pods
//
//  Created by xuguoxing on 14-9-19.
//
//

#import "NSData+Crypto.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import "NSString+Additions.h"

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

@implementation NSData (Crypto)

- (NSData*) lotteryMD5{
    const char* str = self.bytes;
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)self.length, result);
    NSData *data = [NSData dataWithBytes:result length:CC_MD5_DIGEST_LENGTH];
    
    return data;
}

- (NSData *)AES256EncryptWithKeyInLottery:(NSString *)key {
	// 'key' should be 32 bytes for AES256, will be null-padded otherwise
	unsigned char keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
	bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
	// fetch key data
	//[key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
	
    NSData *keyData = [key base16Data];
    [keyData getBytes:keyPtr length:[keyData length]];
    
	NSUInteger dataLength = [self length];
	//See the doc: For block ciphers, the output size will always be less than or
	//equal to the input size plus the size of one block.
	//That's why we need to add the size of one block here
	size_t bufferSize = dataLength + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);
	size_t numBytesEncrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionECBMode + kCCOptionPKCS7Padding,keyPtr, kCCKeySizeAES128,
										  NULL /* initialization vector (optional) */,
										  [self bytes], dataLength, /* input */
										  buffer, bufferSize, /* output */
										  &numBytesEncrypted);
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
        //NSLog(@"numBytesEncrypted %d",numBytesEncrypted);
		return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
	}
	
	free(buffer); //free the buffer;
	return nil;
}

- (NSData *)AES256DecryptWithKeyInLottery:(NSString *)key {
	// 'key' should be 32 bytes for AES256, will be null-padded otherwise
	unsigned char keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
	bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
	
    NSData *keyData = [key base16Data];
    [keyData getBytes:keyPtr length:[keyData length]];
    
	NSUInteger dataLength = [self length];
	
	//See the doc: For block ciphers, the output size will always be less than or
	//equal to the input size plus the size of one block.
	//That's why we need to add the size of one block here
	size_t bufferSize = dataLength + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);
	
	size_t numBytesDecrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionECBMode + kCCOptionPKCS7Padding,
										  keyPtr, kCCKeySizeAES128,
										  NULL /* initialization vector (optional) */,
										  [self bytes], dataLength, /* input */
										  buffer, bufferSize, /* output */
										  &numBytesDecrypted);
	
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
	}
	
	free(buffer); //free the buffer;
	return nil;
}

- (NSData *)Encode3DESWithKey:(NSString *)key; {
    
	char keyPtr[kCCKeySize3DES+1]; // room for terminator (unused)
	bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
	
	// fetch key data
	[key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
	
	NSUInteger dataLength = [self length];
	
	//See the doc: For block ciphers, the output size will always be less than or
	//equal to the input size plus the size of one block.
	//That's why we need to add the size of one block here
	size_t bufferSize = dataLength + kCCBlockSize3DES;
	void *buffer = malloc(bufferSize);
	
	size_t numBytesDecrypted = 0;
    
	CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithm3DES, kCCOptionPKCS7Padding|kCCOptionECBMode,
                                          keyPtr, kCCKeySize3DES,
                                          NULL /* initialization vector (optional) */,
                                          [self bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesDecrypted);
	
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
        NSData *returnData = [NSData dataWithBytes:(const void *)buffer length:(NSUInteger)numBytesDecrypted];
        free(buffer);
        return returnData;
        
	}
	free(buffer); //free the buffer;
	return nil;
}

- (NSData *)Decode3DESWithKey:(NSString *)key {
	// 'key' should be 32 bytes for AES256, will be null-padded otherwise
	char keyPtr[kCCKeySize3DES+1]; // room for terminator (unused)
	bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
	
	// fetch key data
	[key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
	
	NSUInteger dataLength = [self length];
	
	//See the doc: For block ciphers, the output size will always be less than or
	//equal to the input size plus the size of one block.
	//That's why we need to add the size of one block here
	size_t bufferSize = dataLength + kCCBlockSize3DES;
	void *buffer = malloc(bufferSize);
	
	size_t numBytesDecrypted = 0;
    
	CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithm3DES, kCCOptionPKCS7Padding|kCCOptionECBMode,
                                          keyPtr, kCCKeySize3DES,
                                          NULL /* initialization vector (optional) */,
                                          [self bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesDecrypted);
	
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
	}
	
	free(buffer); //free the buffer;
	return nil;
}




-(NSData *)EncodeRsa:(SecKeyRef)publicKey
{
    size_t cipherBufferSize = 0;
	size_t keyBufferSize = 0;
	
    
	NSData * cipher = nil;
	uint8_t * cipherBuffer = NULL;
	
	// Calculate the buffer sizes.
	cipherBufferSize = SecKeyGetBlockSize(publicKey);
	keyBufferSize = [self length];
	
    /*
     if (kTypeOfWrapPadding == kSecPaddingNone) {
     LOGGING_FACILITY( keyBufferSize <= cipherBufferSize, @"Nonce integer is too large and falls outside multiplicative group." );
     } else {
     LOGGING_FACILITY( keyBufferSize <= (cipherBufferSize - 11), @"Nonce integer is too large and falls outside multiplicative group." );
     }
     */
    
	// Allocate some buffer space. I don't trust calloc.
	cipherBuffer = malloc( cipherBufferSize * sizeof(uint8_t) );
	memset((void *)cipherBuffer, 0x0, cipherBufferSize);
	
	// Encrypt using the public key.
    SecKeyEncrypt(publicKey,
                  kSecPaddingPKCS1,
                  (const uint8_t *)[self bytes],
                  keyBufferSize,
                  cipherBuffer,
                  &cipherBufferSize
                  );
	
	// Build up cipher text blob.
	cipher = [NSData dataWithBytes:(const void *)cipherBuffer length:(NSUInteger)cipherBufferSize];
	
	if (cipherBuffer)
    {
        free(cipherBuffer);
    }
	return cipher;
    
    
}



- (NSData *)DecodeRsa:(SecKeyRef)privateKey
{
	size_t cipherBufferSize = 0;
	size_t keyBufferSize = 0;
	
	NSData * key = nil;
	uint8_t * keyBuffer = NULL;
	
	//LOGGING_FACILITY( privateKey != NULL, @"No private key found in the keychain." );
	
	// Calculate the buffer sizes.
	cipherBufferSize = SecKeyGetBlockSize(privateKey);
	keyBufferSize = [self length];
	
	//LOGGING_FACILITY( keyBufferSize <= cipherBufferSize, @"Encrypted nonce is too large and falls outside multiplicative group." );
	
	// Allocate some buffer space. I don't trust calloc.
	keyBuffer = malloc( keyBufferSize * sizeof(uint8_t) );
	memset((void *)keyBuffer, 0x0, keyBufferSize);
	
	// Decrypt using the private key.
    SecKeyDecrypt(privateKey,
                  kSecPaddingPKCS1,
                  (const uint8_t *) [self bytes],
                  cipherBufferSize,
                  keyBuffer,
                  &keyBufferSize
                  );
		
	// Build up plain text blob.
	key = [NSData dataWithBytes:(const void *)keyBuffer length:(NSUInteger)keyBufferSize];
	
	if (keyBuffer)
    {
        free(keyBuffer);
    }
	
	return key;
}





- (NSData *)getSignatureBytes:(SecKeyRef)prikey
{
    
	NSData * signedHash = nil;
	
	uint8_t * signedHashBytes = NULL;
	size_t signedHashBytesSize = 0;
	
    
	signedHashBytesSize = SecKeyGetBlockSize(prikey);
	
	// Malloc a buffer to hold signature.
	signedHashBytes = malloc( signedHashBytesSize * sizeof(uint8_t) );
	memset((void *)signedHashBytes, 0x0, signedHashBytesSize);
	
	// Sign the SHA1 hash.
    SecKeyRawSign(	prikey,
                  kSecPaddingPKCS1,
                  (const uint8_t *)[[self lotteryMD5] bytes],
                  CC_MD5_DIGEST_LENGTH,
                  (uint8_t *)signedHashBytes,
                  &signedHashBytesSize
                  );
    
	// Build up signed SHA1 blob.
	signedHash = [NSData dataWithBytes:(const void *)signedHashBytes length:(NSUInteger)signedHashBytesSize];
	
	if (signedHashBytes) free(signedHashBytes);
	
	return signedHash;
}


- (BOOL)verifySignature:(SecKeyRef)publicKey signature:(NSData *)sig {
	size_t signedHashBytesSize = 0;
	OSStatus sanityCheck = noErr;
	
	// Get the size of the assymetric block.
	signedHashBytesSize = SecKeyGetBlockSize(publicKey);
	
	sanityCheck = SecKeyRawVerify(	publicKey,
                                  kSecPaddingPKCS1,
                                  (const uint8_t *)[[self lotteryMD5] bytes],
                                  CC_MD5_DIGEST_LENGTH,
                                  (const uint8_t *)[sig bytes],
                                  signedHashBytesSize
								  );
	
	return (sanityCheck == noErr) ? YES : NO;
}


- (NSString *)base64Encoding;
{
	if ([self length] == 0)
		return @"";
    
    char *characters = malloc((([self length] + 2) / 3) * 4);
	if (characters == NULL)
		return nil;
	NSUInteger length = 0;
	
	NSUInteger i = 0;
	while (i < [self length])
	{
		char buffer[3] = {0,0,0};
		short bufferLength = 0;
		while (bufferLength < 3 && i < [self length])
			buffer[bufferLength++] = ((char *)[self bytes])[i++];
		
		//  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
		characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
		characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
		if (bufferLength > 1)
			characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
		else characters[length++] = '=';
		if (bufferLength > 2)
			characters[length++] = encodingTable[buffer[2] & 0x3F];
		else characters[length++] = '=';
	}
	
	return [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES] ;
}

-(NSString*)base16String{
    NSMutableString *str = [NSMutableString string];
    const unsigned char  *chrs = (const unsigned char *)[self bytes];
    for (int i=0; i<[self length]; i++) {
        [str appendFormat:@"%02X",chrs[i]];
    }
    return str;
}

@end
