//
//  FBUIStyle.h
//  NTFeedBack
//
//  Created by  龙会湖 on 14-7-21.
//  Copyright (c) 2014年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NFBAppearance<NSObject>
@optional
- (UIColor*)mainViewBackgroundColor;
- (UIColor*)navigationTitleColor;
- (UIColor*)navigationButtonTitleColor;
- (UIFont*)navigationButtonTitleFont;
- (UIImage *)navigationBackButtonImage;

- (UIImage*)headerOnlineBackgroundImage;
- (UIImage*)headerOnlineImage;
- (UIImage*)headerOfflineBackgroundImage;
- (UIImage*)headerOfflineImage;

- (UIColor*)answerTextColor;
- (UIColor*)questionTextColor;
- (UIColor*)dateTextColor;
- (UIColor*)failTextColor;
- (UIImage*)answerAvatarImage;
- (UIImage*)answerContentBackgroundImage;
- (UIImage*)questionContentBackgroundImage;
- (UIImage*)placeHolderImage;
- (UIImage*)warningImage;
- (UIColor*)autoReplySepColor;
- (UIImage*)defaultAvatar;
- (void)configAvatarImageView:(UIImageView *)avatarImageView;
- (CGFloat)avatarCornerRadiusPersent; //返回值为宽度的百分比

- (UIImage*)toolBarBackgroundImage;
- (UIImage*)toolBarConfirmButtonImage;
- (UIImage*)toolBarPlusButtonImage;
- (UIImage*)inputFieldImage;
- (UIImage*)imgPickerCheckedImage;
- (UIImage*)selectedImgsCountBackgroundImg;
- (UIImage*)recentImgBackgroudImg;
- (UIImage*)imgPickerPreviewImage;
- (UIImage*)imgPickerPreviewDisableImage;

- (BOOL)enableSelectImageFromCamera; //选择图片是否支持拍照的开关

// 定制LDAssetsPickerController的navigationBar
- (UIImage*)assetsPickerNavigationBarBackImage;
- (BOOL)enableAssetsPickerNavigationBarTranslucent;

//客服评价
- (BOOL)provideServicePhone;
- (BOOL)provideServiceEvaluation;
- (UIColor *)evaluationCommitButtonColor;
- (UIColor *)evaluationStarTintColor;
- (UIImage *)evaluationStarNormalButtonImage;
- (UIImage *)evaluationStarSelectButtonImage;
- (UIImage *)evaluationNavigationButtonImage;
- (UIImage *)evaluationCryptNormalButtonImage;
- (UIImage *)evaluationCryptSelectButtonImage;

@end
