//
//  ZBActionSheet.m
//  YouHui
//
//  Created by huihu long on 12-4-17.
//  Copyright (c) 2012年 netease. All rights reserved.
//

#import "NFBActionSheet.h"

@implementation NFBActionSheet

@synthesize dismissBlock=_dismissBlock;

- (id)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {
    self = [super initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:otherButtonTitles,nil];
    if  (self) {
        if (otherButtonTitles) {
            va_list otherTitleArg;
            va_start(otherTitleArg, otherButtonTitles);
            NSString *title = va_arg(otherTitleArg, typeof(NSString*));
            while (title!=nil) {
                [self addButtonWithTitle:title];
                title = va_arg(otherTitleArg, typeof(NSString*));
            }  
            va_end(otherTitleArg);  
        } 
        NSUInteger cancelIndex = [self addButtonWithTitle:cancelButtonTitle];
        self.cancelButtonIndex = cancelIndex;
    }
    return self;
}

- (id)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle  andButtons:(NSArray*)buttons {
    self = [super initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    if  (self) {
        for (NSString* buttonText in buttons) {
            [self addButtonWithTitle:buttonText];
        }
        if (cancelButtonTitle) {
            NSUInteger cancelIndex = [self addButtonWithTitle:cancelButtonTitle];
            self.cancelButtonIndex = cancelIndex;
        }
    }
    return self;
}

- (void)setDismissBlock:(ActionSheetBlock)dismissBlock {
    _dismissBlock = [dismissBlock copy];
    self.delegate = self;
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (self.dismissBlock) {
        self.dismissBlock(buttonIndex);
    }
}

- (void)showInController:(UIViewController *)controller {
    if (controller.tabBarController.tabBar) {
        [self showFromTabBar:controller.tabBarController.tabBar];
    } else {
        [self showInView:controller.view];
    }
}

@end
