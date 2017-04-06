//
//  NLDManualTool.h
//  Pods
//
//  Created by wangkaird on 2016/10/20.
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface NLDManualTool : NSObject

+ (instancetype)sharedManualTool;

- (void)setBaseWindow:(UIWindow *)window;
- (void)hiddenManualTool;
- (void)showManualTool;

@end
NS_ASSUME_NONNULL_END
