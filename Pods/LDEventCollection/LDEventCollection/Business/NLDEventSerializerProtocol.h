//
//  NLDEventSerializerProtocol.h
//  LDEventCollection
//
//  Created by SongLi on 5/24/16.
//  Copyright © 2016 netease. All rights reserved.
//

#pragma once

@class NLDDataEntity;
@protocol NLDEventSerializer <NSObject>

- (NSData *)dataWithObject:(NSDictionary *)entity;

- (NSData *)dataWithObjects:(NSArray<NSDictionary *> *)entityArray;

@end
