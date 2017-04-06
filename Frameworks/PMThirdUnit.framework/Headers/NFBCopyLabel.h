//
//  YCCopyMenuLabel.h
//  TestResponder
//
//  Created by li shiyong on 12-4-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NFBRTLabel.h"
@interface NFBCopyLabel :NFBRTLabel <UIGestureRecognizerDelegate>{
    UITapGestureRecognizer       *tapGesture;
    UILongPressGestureRecognizer *longGesture;
}

@end
