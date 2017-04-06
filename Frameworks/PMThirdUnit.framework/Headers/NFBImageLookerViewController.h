//
//  ImageLookerViewController.h
//  NeteaseLottery
//
//  Created by wangbo on 12-10-1.
//
//

#import <Foundation/Foundation.h>
#import "NFBImageLookerView.h"

typedef enum ImageLookerMode{
    ImageLookerNormal,
    ImageLookerDelete
}ImageLookerMode;

@class NFBImageLookerViewController;
@protocol ImageLookerViewControllerDelegate <NSObject>

@optional
-(void) ImageLookerDidDismissed:(NFBImageLookerViewController *)controller;

@end

@interface NFBImageLookerViewController : UIViewController<UIScrollViewDelegate>{
    NFBImageLookerView *lookerView;
    
    UINavigationBar *navigationBar;
    
    NSMutableArray *_imageArray;
    
    NSUInteger displayPage;
    
    UIScrollView *_scrollView;
    
    __unsafe_unretained id<ImageLookerViewControllerDelegate> _delegate;
}

@property(nonatomic,strong) NSMutableArray  *imageArray;
@property(nonatomic,assign) ImageLookerMode lookermode;

@property(nonatomic,unsafe_unretained) id<ImageLookerViewControllerDelegate>delegate;

-(void)loadImage:(UIImage *)image;
-(void)loadImageArray:(NSArray *)array selected:(NSUInteger)index;
-(void)loadSmallImage:(UIImage *)image fullUrl:(NSString *)imageUrl;

-(id)initWithMode:(ImageLookerMode) mode;

@end
