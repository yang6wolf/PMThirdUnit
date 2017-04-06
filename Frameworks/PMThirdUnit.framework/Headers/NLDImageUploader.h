//
//  NLDImageUploader.h
//  Pods
//
//  Created by 高振伟 on 16/6/14.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NLDImageUploaderDelegate  <NSObject>

- (void)presentAlertWithTitle:(NSString *)title message:(NSString *)message;

@end

typedef NS_ENUM(NSUInteger, NLDScreenshotType) {
    NLDAutoScreenshot,
    NLDManualScreenshot
};

@interface NLDImageUploader : NSObject

+ (instancetype)sharedUploader;

// 控制是否开启页面截图上传功能；默认为NO
@property(nonatomic, assign, getter=isEnableUpload) BOOL enableUpload;
@property(nonatomic, strong) NSString *appKey;
@property(nonatomic, copy) NSString *domain;
@property (nonatomic, weak) id<NLDImageUploaderDelegate> delegate;

- (void)uploadImage:(nonnull UIImage *)image fileName:(nonnull NSString *)fileName type:(NLDScreenshotType)type;

@end

NS_ASSUME_NONNULL_END
