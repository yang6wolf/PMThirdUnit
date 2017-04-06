//
//  ImageLoaderView.h
//  YouHui
//
//  Created by  on 11-11-18.
//  Copyright (c) 2011年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@class NFBImageLoaderView;

@protocol ImageLoaderViewDelegate <NSObject>
@required
-(void) imageLoaderViewDidLoadImage:(NFBImageLoaderView *)loaderView;
@optional
-(void) imageLoaderViewLoadImageError:(NFBImageLoaderView *)loaderView;
@end

@interface NFBImageLoaderView : UIImageView{
    UIActivityIndicatorView * __unsafe_unretained _indicatorView;
    id<ImageLoaderViewDelegate> __unsafe_unretained _delegate;

    BOOL    _adjust;
    NSString *_imageUrl;
    UIImage *_backupImage;
    
    BOOL    _showBigImage;
    
    UITapGestureRecognizer *recognizer;
    
    NSURLSessionDataTask *dataTask;
    AFHTTPSessionManager *manager;
}

@property(nonatomic,unsafe_unretained) id<ImageLoaderViewDelegate> delegate;
@property(nonatomic,strong) UIImage  *backupImage;
@property(nonatomic,strong) NSString *imageUrl;

@property(nonatomic,assign) BOOL showProgress;
@property(nonatomic,assign) BOOL showBigImage;

@property (nonatomic, strong) UILabel *progressLabel;

//- (void)setImage:(UIImage *)image withUrl:(NSString*)url;
//- (BOOL)loadCachedImageAtUrl:(NSString *)urlString;
//- (void)loadImageUrl:(NSString *)urlString expire:(NSString *)expire;
-(void) loadImageUrl:(NSString *)urlString;

/**
 *  set upload progress info
 *
 *  @param progressMsg clear when nil
 */
- (void)setUploadProgress:(NSString *)progressMsg;

@end
