//
//  LDSPMessageObserver.h
//  Pods
//
//  Created by liubing on 8/6/15.
//
//

#import <Foundation/Foundation.h>

@class LDSPMessage;

@interface LDSPMessageObserver : NSObject

@property (nonatomic,weak) id target;
@property (nonatomic,copy) NSString *topic;
@property (nonatomic,copy) id block;

+ (instancetype)observerWithTarget:(id)target topic:(NSString *)topic block:(id)block;

@end
