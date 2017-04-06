//
//  NLDRNPageManager.h
//  LDEventCollection
//
//  Created by 高振伟 on 16/12/23.
//  Copyright © 2016 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, RNPageEvent) {
    RNPageEventShow,
    RNPageEventHide
};

NS_ASSUME_NONNULL_BEGIN

@interface NLDRNPageManager : NSObject

+ (instancetype)defaultManager;

- (void)RN_viewWillAppearWithComponentName:(NSString *)componentName;

- (void)triggerPageEventWithType:(RNPageEvent)event componentName:(nullable NSString *)componentName;

@end

NS_ASSUME_NONNULL_END
