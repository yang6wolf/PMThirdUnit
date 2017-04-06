//
//  NFBLatestImgV.h
//  NTFeedBack
//
//  Created by xuejiapeng on 8/12/14.
//  Copyright (c) 2014 netease. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^buttonPressedBlock)(NSInteger buttonTag);
@interface NFBLatestImgV : UIView


@property (nonatomic,copy) buttonPressedBlock pressedBlock;

- (id)initWithFrame:(CGRect)frame andImgV:(UIImage*)img andButtonPressedBlock:(buttonPressedBlock)block;


@end
