//
//  NSMutableDictionary+NLDEventCollection.h
//  LDEventCollection
//
//  Created by SongLi on 5/18/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary<KeyType, ObjectType> (NLDEventCollection)

+ (nonnull instancetype)NLD_dictionary;

+ (nonnull instancetype)NLD_dictionaryWithView:(nullable UIView *)view;

- (void)NLD_setViewOrNil:(nullable UIView *)aView;

- (void)NLD_setButtonOrNil:(nullable NSObject *)aButton;

@end
