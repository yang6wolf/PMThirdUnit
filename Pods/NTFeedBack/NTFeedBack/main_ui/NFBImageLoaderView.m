//
//  ImageLoaderView.m
//  YouHui
//
//  Created by  on 11-11-18.
//  Copyright (c) 2011年 netease. All rights reserved.
//
#import "NFBImageLoaderView.h"
#import "NFBDataBackupPool.h"
#import "NFBImageLookerViewController.h"
#import "NFBUtil.h"

@interface NFBImageLoaderView ()

@property (nonatomic, assign) NSUInteger downloadProgress;

@end

@implementation NFBImageLoaderView
@synthesize delegate = _delegate;
@synthesize imageUrl=_imageUrl;
@synthesize backupImage=_backupImage;
@synthesize showProgress=_showProgress;
@synthesize showBigImage = _showBigImage;

+ (UIImage*)cachedImageAtUrl:(NSString*)url {
	NSData *data = [NFBDataBackupPool dataForKey:url];
    if (data) {
        return [UIImage imageWithData:data];
    }
	return nil;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentMode = UIViewContentModeScaleAspectFit;
        self.backgroundColor = [UIColor redColor];
    }
    return self;
}

- (UIActivityIndicatorView*)indicatorView {
    if (!_indicatorView) {
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((self.bounds.size.width-30)/2, (self.bounds.size.height-30)/2, 30, 30)];
        indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [self addSubview:indicatorView];
        _indicatorView = indicatorView;
        [_indicatorView startAnimating];
    }
    return _indicatorView;
}

- (void)loadImageUrl:(NSString *)url {
    UIImage *cachedImage = [NFBImageLoaderView cachedImageAtUrl:url];
    if (cachedImage) {
        [self setImage:cachedImage withUrl:url];
        return;
    }
    
    self.showBigImage = NO;
    __weak NFBImageLoaderView *weakself = self;
    
    manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFImageResponseSerializer serializer];
    dataTask = [manager GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        CGFloat progress = (CGFloat)downloadProgress.completedUnitCount/(CGFloat)downloadProgress.totalUnitCount * 100.0f;
        //warning iOS6上存在问题
        weakself.downloadProgress = MAX(weakself.downloadProgress, (unsigned long)progress);
        [weakself setUploadProgress:[NSString stringWithFormat:@"%lu%%", (unsigned long)weakself.downloadProgress]];
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [weakself setUploadProgress:nil];
        if ([responseObject isKindOfClass:[UIImage class]]) {
            weakself.image = responseObject;
            if (weakself.image) {
                weakself.imageUrl = url;
                [NFBDataBackupPool addData:[NFBUtil imageToData:responseObject] forKey:url expire:nil];
                weakself.showBigImage = YES;
            }
        }
        [weakself.delegate imageLoaderViewDidLoadImage:weakself];
        [weakself doFinishDownload];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error.code == NSURLErrorCancelled) {
            return;
        }
        if (weakself.delegate && [weakself.delegate respondsToSelector:@selector(imageLoaderViewLoadImageError:)]) {
            [weakself.delegate imageLoaderViewLoadImageError:weakself];
        }
        [weakself doFinishDownload];
    }];
}

-(void)showBigImage:(UIGestureRecognizer *)recognizer{
    NFBImageLookerViewController *controller = [[NFBImageLookerViewController alloc] init];
    
    UIResponder *responder = self;
    while (responder&&![responder isKindOfClass:[UIViewController class]]) {
        responder = [responder nextResponder];
    }
    [(UIViewController*)responder presentViewController:controller animated:YES completion:nil];
    [controller loadSmallImage:self.image fullUrl:self.imageUrl];
}

-(void)setShowBigImage:(BOOL)showBigImage{
    _showBigImage = showBigImage;
    if (_showBigImage) {
        recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showBigImage:)];
        [self addGestureRecognizer:recognizer];
        self.userInteractionEnabled = YES;
    }else{
        [self removeGestureRecognizer:recognizer];
        self.userInteractionEnabled = NO;
    }
}

-(void)setBackupImage:(UIImage *)backupImage {
    if (_backupImage==backupImage) {
        return;
    }
    if (self.image==_backupImage) {
        [super setImage:backupImage];
    }
    _backupImage = backupImage;
}

-(void)setImage:(UIImage *)image withUrl:(NSString*)url
{
    self.image = image;
    self.imageUrl = url;
    
    CGFloat width = self.image.size.width;
    CGFloat height = self.image.size.height;
    CGFloat ratio = width/height;
    if (ratio > CGRectGetWidth([UIScreen mainScreen].bounds)/CGRectGetHeight([UIScreen mainScreen].bounds)) {
        width = CGRectGetWidth(self.frame);
        height = roundf(CGRectGetWidth(self.frame) / ratio);
        self.frame = CGRectMake(0, (CGRectGetHeight(self.frame)-height)/2, width, height);
    }
    else {
        height = CGRectGetHeight(self.frame);
        width = roundf(CGRectGetHeight(self.frame) * ratio);
        self.frame = CGRectMake((CGRectGetWidth(self.frame)-width)/2, 0, width, height);
    }
}

-(void)setImage:(UIImage *)image {
    [super setImage:image];
    if (self.image==nil) {
        [super setImage:_backupImage];
    }
}

- (void)doFinishDownload {
    self.downloadProgress = 0;
    [_indicatorView removeFromSuperview];
    _indicatorView = nil;
}

- (void)setUploadProgress:(NSString *)progressMsg {
    if (progressMsg && self.showProgress) {
        if (!self.progressLabel) {
            self.backgroundColor = [UIColor redColor];
            self.progressLabel = [[UILabel alloc] initWithFrame:self.bounds];
            self.progressLabel.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0.6];
            self.progressLabel.textColor = [UIColor whiteColor];
            self.progressLabel.textAlignment = NSTextAlignmentCenter;
            self.progressLabel.font = [UIFont systemFontOfSize:16];
            [self addSubview:self.progressLabel];
        }
        self.progressLabel.text = progressMsg;
        [self bringSubviewToFront:self.progressLabel];
    } else {
        [self.progressLabel removeFromSuperview];
        self.progressLabel = nil;
    }
}

- (void)dealloc {
    if (manager && dataTask) {
        [dataTask cancel];
        [manager setDownloadTaskDidFinishDownloadingBlock:nil];
    }
    
}

@end
