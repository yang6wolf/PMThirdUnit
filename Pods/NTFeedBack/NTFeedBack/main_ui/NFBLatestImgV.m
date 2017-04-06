//
//  NFBLatestImgV.m
//  NTFeedBack
//
//  Created by xuejiapeng on 8/12/14.
//  Copyright (c) 2014 netease. All rights reserved.
//

#import "NFBLatestImgV.h"
#import "NFBAppearanceProxy.h"

@implementation NFBLatestImgV

- (id)initWithFrame:(CGRect)frame andImgV:(UIImage*)img andButtonPressedBlock:(buttonPressedBlock)block {
    self = [super initWithFrame:frame];
    if (self) {

        //self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        UIButton *button = [[UIButton alloc] initWithFrame:frame];
        button.backgroundColor = [UIColor blackColor];
        button.alpha = 0.5;
        [button addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        UIImageView *backgroundImgV = [[UIImageView alloc] initWithFrame:CGRectMake(25,(self.bounds.size.height - 230)/2, 270, 230)];
        [backgroundImgV setUserInteractionEnabled:YES];
        backgroundImgV.image = [[NFBAppearanceProxy sharedAppearance] recentImgBackgroudImg];
        [self addSubview:backgroundImgV];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 270, 20)];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.text = @"您是要发送这张图片吗？";
        [backgroundImgV addSubview:label];
        
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(20, 40 , 230, 130)];
        imgV.image = img;
        imgV.contentMode = UIViewContentModeScaleAspectFit;
        [backgroundImgV addSubview:imgV];
        
        UIButton *okBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 185, 135, 40)];
        [okBtn setTitle:@"选择其他" forState:UIControlStateNormal];
        [okBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        okBtn.tag = 102;
        okBtn.backgroundColor = [UIColor clearColor];
        [okBtn addTarget:self action:@selector(okBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [backgroundImgV addSubview:okBtn];
        
        UIButton *chooseOtherBtn = [[UIButton alloc] initWithFrame:CGRectMake(135, 185, 135, 40)];
        [chooseOtherBtn setTitle:@"确认" forState:UIControlStateNormal];
        [chooseOtherBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        chooseOtherBtn.tag = 101;
        chooseOtherBtn.backgroundColor = [UIColor clearColor];
        [chooseOtherBtn addTarget:self action:@selector(chooseOtherBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [backgroundImgV addSubview:chooseOtherBtn];
        
        self.pressedBlock = block;
        
    }
    return self;
}

-(IBAction)okBtnPressed:(UIButton*)sender
{
    
   
    if (self.pressedBlock) {
        self.pressedBlock(sender.tag);
    }
    [self removeFromSuperview];
}

- (IBAction)chooseOtherBtnPressed:(UIButton*)sender{
    
    if (self.pressedBlock) {
        self.pressedBlock(sender.tag);
    }
    [self removeFromSuperview];
}

-(void)dismiss{
    [self removeFromSuperview];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
