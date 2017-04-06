//
//  ImageLookerView.m
//  NeteaseLottery
//
//  Created by 王 波 on 12-9-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NFBImageLookerView.h"

@implementation NFBImageLookerView
@synthesize imageView;

-(void) loadImage:(UIImage *)image{
    [imageView setImage:image];
}

-(void) loadImageUrl:(NSString *)urlString{
    [imageView loadImageUrl:urlString];
}

-(UIImage *)image{
    return imageView.image;
}

#pragma mark -
#pragma mark === UIScrollView Delegate ===
#pragma mark -
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
	return imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?(scrollView.bounds.size.width - scrollView.contentSize.width)/2 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?(scrollView.bounds.size.height - scrollView.contentSize.height)/2 : 0.0;
    imageView.center = CGPointMake(scrollView.contentSize.width/2 + offsetX,scrollView.contentSize.height/2 + offsetY);
}

#pragma mark -
#pragma mark === UITouch Delegate ===
#pragma mark -
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	UITouch *touch = [touches anyObject];
	
	if ([touch tapCount] == 2){
		CGFloat zs = self.zoomScale;
		zs = (zs == 1.0) ? 2.0 : 1.0;
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.3];
		self.zoomScale = zs;
		[UIView commitAnimations];
	}
}

-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.delegate = self;
        self.minimumZoomScale = 1.0;
        self.maximumZoomScale = 3.0;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        imageView = [[NFBImageLoaderView alloc] initWithFrame:self.bounds];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.backgroundColor = [UIColor clearColor];
        [self addSubview:imageView];
    }
    return self;
}

@end
