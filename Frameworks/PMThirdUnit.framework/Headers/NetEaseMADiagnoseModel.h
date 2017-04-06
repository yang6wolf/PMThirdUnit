//
//  NetEaseMADiagnoseModel.h
//  MobileAnalysis
//
//  Created by 高振伟 on 16/9/5.
//
//

#import <Foundation/Foundation.h>

@interface NetEaseMADiagnoseModel : NSObject

@property (nonatomic, copy) NSString *tag;
@property (nonatomic, strong) NSDate *expiredDate;

- (instancetype)initWithDictionary:(NSDictionary *)dic;

@end
