//
//  MKBlockAdditions.h
//  UIKitCategoryAdditions
//
//  Created by Mugunth on 21/03/11.
//  Copyright 2011 Steinlogic All rights reserved.
//
#import <UIKit/UIKit.h>

typedef void (^VoidBlock)();

typedef void (^DismissBlock)(NSInteger buttonIndex);
typedef void (^CancelBlock)();
typedef void (^PhotoPickedBlock)(UIImage *chosenImage);

#define kPhotoActionSheetTag 10000