//
//  NFBDefaultAppearance.m
//  NTFeedBack
//
//  Created by  龙会湖 on 14-7-21.
//  Copyright (c) 2014年 netease. All rights reserved.
//

#import "NFBDefaultAppearance.h"

#define IS_IOS7             ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending)
@implementation NFBDefaultAppearance {
    NSBundle *_fbBundle;
}

- (id)init {
    if (self=[super init]) {
        NSBundle *bundle = [NSBundle bundleForClass:[NFBDefaultAppearance class]];
        NSString *bundlePath = [bundle pathForResource:@"feedback" ofType:@"bundle"];
        _fbBundle = [NSBundle bundleWithPath:bundlePath];
    }
    return self;
}

- (UIColor*)mainViewBackgroundColor {
    NSString *path = [_fbBundle pathForResource:@"mainTexture@2x" ofType:@"png"];
    return [UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:path]];
}

- (UIColor*)navigationTitleColor {
    return [UIColor darkTextColor];
}

- (UIColor*)navigationButtonTitleColor{
    return [UIColor darkTextColor];
}

- (UIFont*)navigationButtonTitleFont{
    return [UIFont systemFontOfSize:16.0f];
}

- (UIImage *)navigationBackButtonImage {
    NSString *path = [_fbBundle pathForResource:@"navigationBack@2x" ofType:@"png"];
    return [UIImage imageWithContentsOfFile:path];
}

- (UIImage*)headerOnlineBackgroundImage{
    NSString *path = [_fbBundle pathForResource:@"headerOnlineBackground@2x" ofType:@"png"];
    return [UIImage imageWithContentsOfFile:path];
}

- (UIImage*)headerOnlineImage{
    NSString *path = [_fbBundle pathForResource:@"headerOnlineIcon@2x" ofType:@"png"];
    return [UIImage imageWithContentsOfFile:path];
}

- (UIImage*)headerOfflineBackgroundImage{
    NSString *path = [_fbBundle pathForResource:@"headerOfflineBackground@2x" ofType:@"png"];
    return [UIImage imageWithContentsOfFile:path];
}

- (UIImage*)headerOfflineImage {
    NSString *path = [_fbBundle pathForResource:@"headerOfflineIcon@2x" ofType:@"png"];
    return [UIImage imageWithContentsOfFile:path];
}


- (UIColor*)answerTextColor{
    return [UIColor colorWithRed:0x4e/255.0f green:0x42/255.0f blue:0x34/255.0f alpha:1.0f];
}


- (UIColor*)questionTextColor{
    return nil;
}

- (UIColor*)dateTextColor{
    return [UIColor colorWithRed:0xd7/255.0f green:0xd4/255.0f blue:0xc8/255.0f alpha:1.0f];
}

- (UIColor*)failTextColor{
    return nil;
}

- (UIImage*)answerAvatarImage{
    NSString *path = [_fbBundle pathForResource:@"answerAvatar@2x" ofType:@"png"];
    return [UIImage imageWithContentsOfFile:path];
}

- (UIImage*)answerContentBackgroundImage{
    NSString *path = [_fbBundle pathForResource:@"answerContentBackground@2x" ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    return [image stretchableImageWithLeftCapWidth:26 topCapHeight:18];
}

- (UIImage*)questionContentBackgroundImage{
    NSString *path = [_fbBundle pathForResource:@"questionContentBackground@2x" ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    return [image stretchableImageWithLeftCapWidth:16 topCapHeight:18];
}

- (UIImage*)placeHolderImage{
    NSString *path = [_fbBundle pathForResource:@"placeHolderImage@2x" ofType:@"png"];
    return [UIImage imageWithContentsOfFile:path];
}

- (UIImage*)warningImage{
    NSString *path = [_fbBundle pathForResource:@"warning@2x" ofType:@"png"];
    return [UIImage imageWithContentsOfFile:path];
}


- (UIImage*)toolBarBackgroundImage{
    NSString *path = [_fbBundle pathForResource:@"inputbarBackground@2x" ofType:@"png"];
    return [UIImage imageWithContentsOfFile:path];
}

- (UIImage*)toolBarConfirmButtonImage{
    NSString *path = [_fbBundle pathForResource:@"inputConfirmButton@2x" ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    return [image stretchableImageWithLeftCapWidth:20 topCapHeight:15];
}

- (UIImage*)toolBarPlusButtonImage{
    NSString *path = [_fbBundle pathForResource:@"inputPlusButton@2x" ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    return [image stretchableImageWithLeftCapWidth:20 topCapHeight:15];
}

- (UIImage*)inputFieldImage{
    NSString *path = [_fbBundle pathForResource:@"inputField@2x" ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    return [image stretchableImageWithLeftCapWidth:25 topCapHeight:18];
}

- (UIImage*)imgPickerCheckedImage{
    
    NSString *path = IS_IOS7?[_fbBundle pathForResource:@"NTFBAssetsPickerChecked@2x" ofType:@"png"]:[_fbBundle pathForResource:@"NTFBAssetsPickerChecked~iOS6@2x" ofType:@"png"];
    return [UIImage imageWithContentsOfFile:path];
}

- (UIColor*)autoReplySepColor{
    return [UIColor lightGrayColor];
}

-(UIImage*)defaultAvatar{
    NSString *path = [_fbBundle pathForResource:@"userAvatar@2x" ofType:@"png"];
    return [UIImage imageWithContentsOfFile:path];
}

- (void)configAvatarImageView:(UIImageView *)avatarImageView {
    return;
}

- (CGFloat)avatarCornerRadiusPersent {
    return .5f;
}

-(UIImage*)selectedImgsCountBackgroundImg{
    NSString *path = [_fbBundle pathForResource:@"selected_count@2x" ofType:@"png"];
    return [UIImage imageWithContentsOfFile:path];
}

- (UIImage*)recentImgBackgroudImg{
    NSString *path = [_fbBundle pathForResource:@"recent_image_background@2x" ofType:@"png"];
    return [UIImage imageWithContentsOfFile:path];
}

- (UIImage*)imgPickerPreviewImage {
    NSString *path = [_fbBundle pathForResource:@"previewButton@2x" ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    return [image stretchableImageWithLeftCapWidth:20 topCapHeight:15];
}

- (UIImage*)imgPickerPreviewDisableImage {
    NSString *path = [_fbBundle pathForResource:@"previewDisableButton@2x" ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    return [image stretchableImageWithLeftCapWidth:20 topCapHeight:15];
}

- (BOOL)enableSelectImageFromCamera {
    return YES;
}

- (UIImage*)assetsPickerNavigationBarBackImage{
    return nil;
}

- (BOOL)enableAssetsPickerNavigationBarTranslucent{
    return YES;
}

- (BOOL)provideServicePhone
{
    return YES;
}

- (BOOL)provideServiceEvaluation
{
    return NO;
}

- (UIColor *)evaluationCommitButtonColor
{
    return [UIColor colorWithRed:0xd9/256.0 green:0x1d/256.0 blue:0x37/256.0 alpha:1.0];
}

- (UIColor *)evaluationStarTintColor
{
    return [UIColor colorWithRed:0xfb/256.0 green:0xca/256.0 blue:0x1f/256.0 alpha:1.0];
}

- (UIImage *)evaluationStarNormalButtonImage
{
    NSString *path = [_fbBundle pathForResource:@"starNormal@2x" ofType:@"png"];
    return [UIImage imageWithContentsOfFile:path];
}

- (UIImage *)evaluationStarSelectButtonImage
{
    NSString *path = [_fbBundle pathForResource:@"starSelect@2x" ofType:@"png"];
    return [UIImage imageWithContentsOfFile:path];
}

- (UIImage *)evaluationNavigationButtonImage
{
    NSString *path = [_fbBundle pathForResource:@"evaluationImage@2x" ofType:@"png"];
    return [UIImage imageWithContentsOfFile:path];
}

- (UIImage *)evaluationCryptNormalButtonImage
{
    NSString *path = [_fbBundle pathForResource:@"cryptNormal@2x" ofType:@"png"];
    return [UIImage imageWithContentsOfFile:path];
}

- (UIImage *)evaluationCryptSelectButtonImage
{
    NSString *path = [_fbBundle pathForResource:@"cryptSelect@2x" ofType:@"png"];
    return [UIImage imageWithContentsOfFile:path];
}

@end
