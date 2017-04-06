//
//  LDSPMessage.h
//  Pods
//
//  Created by liubing on 8/6/15.
//
//

#import <Foundation/Foundation.h>

@interface LDSPMessage : NSObject

@property (nonatomic,copy) NSString *topic;
@property (nonatomic,strong) NSData *body;

@end
