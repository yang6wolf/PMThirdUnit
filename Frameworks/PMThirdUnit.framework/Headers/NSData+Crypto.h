//
//  NSData+Crypto.h
//  Pods
//
//  Created by xuguoxing on 14-9-19.
//
//  支持对NSData不同类型的加解密、对密钥进行编解码

#import <Foundation/Foundation.h>

@interface NSData (Crypto)

- (NSData *) lotteryMD5;

- (NSData *)AES256EncryptWithKeyInLottery:(NSString *)key;
- (NSData *)AES256DecryptWithKeyInLottery:(NSString *)key;

- (NSData *)Encode3DESWithKey:(NSString *)key;
- (NSData *)Decode3DESWithKey:(NSString *)key;


- (NSData *)EncodeRsa:(SecKeyRef)publicKey;
- (NSData *)DecodeRsa:(SecKeyRef)privateKey;


- (NSData *)getSignatureBytes:(SecKeyRef)prikey;
- (BOOL)verifySignature:(SecKeyRef)publicKey signature:(NSData *)sign ;

- (NSString *)base64Encoding;

- (NSString*)base16String;

@end


SecKeyRef getPublicKeyWithCert(NSData *certdata);
SecKeyRef getPublicKeywithRawKey(NSString *peerNode,NSData *derpckskey);
SecKeyRef getPrivateKeywithRawKey(NSData *pfxkeydata);