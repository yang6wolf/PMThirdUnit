//
//  NLDLocationService.h
//  Pods
//
//  Created by 高振伟 on 16/11/1.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const NLDNotificationLocationUpload;

@interface NLDLocationService : NSObject

@property (nonatomic, assign, getter=isEnableLocation) BOOL enableLocation;

+ (instancetype)sharedService;

- (void)startUpdateLocationWithCompletionHandler:(void(^)(NSString *longitude, NSString *latitude, NSString *altitude))completionBlock;

@end

NS_ASSUME_NONNULL_END
