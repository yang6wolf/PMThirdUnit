//
//  LDGeminiCase.h
//  LDGeminiSDKiOS
//
//  Created by wangkaird on 2016/10/13.
//  Copyright © 2016年 wangkaird. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface LDGeminiCase : NSObject<NSCoding>

@property (nonatomic, strong) NSNumber *flag;
@property (nonatomic, strong) NSString *caseId;

+ (nullable instancetype)createWithDictionary:(NSDictionary *)dictionary;
+ (NSArray *)createWithArray:(NSArray *)array;
- (nullable instancetype)initWithFlag:(id)flag andCaseId:(id)caseId;
- (NSDictionary *)toDictionary;

@end
NS_ASSUME_NONNULL_END;
