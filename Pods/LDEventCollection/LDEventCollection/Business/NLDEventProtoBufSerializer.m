//
//  NLDEventProtoBufSerializer.m
//  Pods
//
//  Created by SongLi on 6/3/16.
//
//

#import "NLDEventProtoBufSerializer.h"
#import "PBGeneratedMessageBuilder+NLDEvent.h"
#import "GeneratedMessageBuilder.h"

@implementation NLDEventProtoBufSerializer

- (NSData *)dataWithObject:(NSDictionary *)entity
{
    PBGeneratedMessageBuilder *messageBuilder = [PBGeneratedMessageBuilder messageBuilderWithEventDict:entity];
    NSData *data = [[messageBuilder build] data];
    int32_t totalLength = (int32_t)data.length + 4 + 2;
    NLDProtoBufMessageType type = [messageBuilder messageType];
    NSMutableData *d = [NSMutableData dataWithLength:totalLength];
    
    //转为大端序
    totalLength = CFSwapInt32HostToBig(totalLength);
    type = CFSwapInt16HostToBig(type);
    
    [d appendBytes:&totalLength length:sizeof(totalLength)];
    [d appendBytes:&type length:sizeof(type)];
    [d appendData:data];
    return d.copy;
}

- (NSData *)dataWithObjects:(NSArray<NSDictionary *> *)entityArray
{
    NSMutableData *d = [NSMutableData data];
    [entityArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PBGeneratedMessageBuilder *messageBuilder = [PBGeneratedMessageBuilder messageBuilderWithEventDict:obj];
        PBGeneratedMessage *message = [messageBuilder buildPartial];
        NSData *data = [message data];
        int32_t totalLength = (int32_t)data.length + 4 + 2;
        NLDProtoBufMessageType type = [messageBuilder messageType];
        
        //转为大端序
        totalLength = CFSwapInt32HostToBig(totalLength);
        type = CFSwapInt16HostToBig(type);
        
        [d appendBytes:&totalLength length:sizeof(totalLength)];
        [d appendBytes:&type length:sizeof(type)];
        [d appendData:data];
    }];
    return d.copy;
}

@end
