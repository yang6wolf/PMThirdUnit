//
//  NLDRemotePageService.h
//  LDEventCollection
//
//  Created by 高振伟 on 17/3/28.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NLDRemotePageService : NSObject

@property(nonatomic, strong) NSString *appKey;
@property (nonatomic, strong, nullable) NSArray<NSString *> *screenShotPages;
@property (nonatomic, strong, nullable) NSArray<NSString *> *childViewControllers;

+ (instancetype)defaultService;

- (void)fetchScreenShotPages;

- (void)fetchChildViewControllers;

- (BOOL)isAlreadyUploadPage:(NSString *)pageName;

//- (nullable NSArray<NSString *> *)childViewControllers;

@end

NS_ASSUME_NONNULL_END
