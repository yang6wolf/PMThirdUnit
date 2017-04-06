//
//  DataBackupPool.h
//  YouHui
//
//  Created by  on 11-11-16.
//  Copyright (c) 2011年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NFBDataBackupPool : NSObject{
    
}

+(void)addData:(NSData*)data forKey:(NSString*)key expire:(NSString*)expire;
+(void)addData:(NSData *)data forKey:(NSString*)key;


+(NSData *)dataForKey:(NSString *)key;
+(BOOL) hasDataForKey:(NSString *)key;

@end
