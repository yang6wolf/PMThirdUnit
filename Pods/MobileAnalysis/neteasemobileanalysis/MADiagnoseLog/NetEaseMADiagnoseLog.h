//
//  NetEaseMADiagnoseLog.h
//  MobileAnalysis
//
//  Created by 高振伟 on 16/9/5.
//  
//

#import <Foundation/Foundation.h>

@interface NetEaseMADiagnoseLog : NSObject

+ (instancetype)sharedInstance;

- (void)setupDiagnose:(NSArray *)params;

- (void)addDiagnoseLog:(NSString *)log tag:(NSString *)tag;

@end
