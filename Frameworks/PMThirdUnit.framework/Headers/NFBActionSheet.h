//
//  ZBActionSheet.h
//  YouHui
//
//  Created by huihu long on 12-4-17.
//  Copyright (c) 2012年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ActionSheetBlock)(NSInteger buttonIndex);

/**
 *  ZBActionSheet为UIActionSheet提供block支持
 */
@interface NFBActionSheet : UIActionSheet<UIActionSheetDelegate>

- (id)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;
- (id)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle  andButtons:(NSArray*)buttons;
@property(nonatomic,copy) ActionSheetBlock dismissBlock;
- (void)showInController:(UIViewController *)controller;
@end
