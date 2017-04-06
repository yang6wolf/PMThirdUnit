//
//  ImageLookerView.h
//  NeteaseLottery
//
//  Created by 王 波 on 12-9-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NFBImageLoaderView.h"

@interface NFBImageLookerView : UIScrollView<UIScrollViewDelegate>{
    NFBImageLoaderView *imageView;
}

@property(nonatomic,strong) NFBImageLoaderView *imageView;

-(void) loadImage:(UIImage *)image;
-(void) loadImageUrl:(NSString *)urlString;
-(UIImage *)image;

@end

