//
//  ImageLookerViewController.m
//  NeteaseLottery
//
//  Created by wangbo on 12-10-1.
//
//

#import "NFBImageLookerViewController.h"
#import "NFBImageLoaderView.h"
#import "NFBDataBackupPool.h"
#import "NFBUtil.h"
#import "NFBUIFactory.h"

@implementation NFBImageLookerViewController
@synthesize lookermode;
@synthesize imageArray = _imageArray;
@synthesize delegate = _delegate;

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [NFBUtil alertView:@"保存成功"];
}


- (void)loadImage:(UIImage *)image {
    CGAffineTransform transform = CGAffineTransformMakeScale(0.5, 0.5);
    lookerView.transform = transform;
    [UIView commitAnimations];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [lookerView loadImage:image];
    
    transform = CGAffineTransformMakeScale(1, 1);
    lookerView.transform = transform;
    [UIView commitAnimations];
    [lookerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(taped:)]];
    [self.view bringSubviewToFront:navigationBar];
}

- (void)loadSmallImage:(UIImage *)image fullUrl:(NSString *)imageUrl {
    CGAffineTransform transform = CGAffineTransformMakeScale(0.5, 0.5);
    lookerView.transform = transform;
    [UIView commitAnimations];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [lookerView.imageView loadImageUrl:imageUrl];
    
    transform = CGAffineTransformMakeScale(1, 1);
    lookerView.transform = transform;
    [UIView commitAnimations];
    [lookerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(taped:)]];
    [self.view bringSubviewToFront:navigationBar];
    
    [self reSetView];
}

- (void)loadImageArray:(NSArray *)array selected:(NSUInteger)index {
    _imageArray = [NSMutableArray arrayWithArray:array];
    [_scrollView removeFromSuperview];
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.view.bounds.size.height)];
    _scrollView.contentSize = CGSizeMake(_scrollView.bounds.size.width*[array count], _scrollView.bounds.size.height);
    _scrollView.pagingEnabled = YES;
    _scrollView.scrollEnabled = YES;
    _scrollView.delegate = self;
    _scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_scrollView];
    for (int i =0;i<[array count]; i++) {
        NFBImageLookerView *lview = [[NFBImageLookerView alloc] initWithFrame:CGRectMake(10+SCREEN_WIDTH*i, 0, 300, self.view.bounds.size.height)];
        lview.userInteractionEnabled = YES;
        //lview.contentMode = UIViewContentModeScaleAspectFit;
        NSString *url = [array objectAtIndex:i];
        [lview loadImageUrl:url];
        [_scrollView addSubview:lview];
        [lview addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(taped:) ]];
    }
    displayPage = index;
    [_scrollView scrollRectToVisible:CGRectMake(_scrollView.frame.size.width*displayPage, 0, _scrollView.frame.size.width, _scrollView.frame.size.height) animated:NO];
    if ([_imageArray count] != 0) {
        navigationBar.topItem.title = [NSString stringWithFormat:@"%lu/%lu",(unsigned long)(displayPage+1),(unsigned long)[_imageArray count]];
    }else{
        navigationBar.topItem.title = @"没有照片";
    }
    //navigationBar.topItem.title = [NSString stringWithFormat:@"%d/%d",displayPage+1,[_imageArray count]];
    [self.view bringSubviewToFront:navigationBar];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor(scrollView.contentOffset.x/pageWidth);
    if (page==displayPage ||
        page<0 ||
        page>=[_imageArray count]) {
        return;
    }
	displayPage = page;
    if ([_imageArray count] != 0) {
        navigationBar.topItem.title = [NSString stringWithFormat:@"%lu/%lu",(unsigned long)displayPage+1,(unsigned long)[_imageArray count]];
    }else{
        navigationBar.topItem.title = @"没有照片";
    }
    
}

-(void)cancel{
    if ([self.delegate respondsToSelector:@selector(ImageLookerDidDismissed:)]) {
        [self.delegate ImageLookerDidDismissed:self];
    }
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

-(void)delete{
    if([_imageArray count] != 0){
        
        [_imageArray removeObjectAtIndex:displayPage];
        if (displayPage == [_imageArray count]) {
            displayPage = [_imageArray count]-1;
        }
    }
    if ([_imageArray count] == 0) {
        [self loadImageArray:_imageArray selected:0];
    }else{
        if (displayPage == 0) {
            [self loadImageArray:_imageArray selected:displayPage]; 
        }else{
            [self loadImageArray:_imageArray selected:displayPage];
        }
    }
}

- (void)save {
    if (lookerView.superview) {
        UIImageWriteToSavedPhotosAlbum(lookerView.image,self,@selector(image:didFinishSavingWithError:contextInfo:),nil);
    } else {
        UIImage *image = [UIImage imageWithData:[NFBDataBackupPool dataForKey:[_imageArray objectAtIndex:displayPage]]];
        UIImageWriteToSavedPhotosAlbum(image,self,@selector(image:didFinishSavingWithError:contextInfo:),nil);
    }
    
}

- (void)taped:(UIGestureRecognizer *)recognizer {
    if (navigationBar.superview) {
        [navigationBar removeFromSuperview];
        if ([NFBUtil isIOS7]) {
            [UIApplication sharedApplication].statusBarHidden = YES;
        }
        self.view.backgroundColor = [UIColor blackColor];
    }else{
        [self.view addSubview:navigationBar];
        if ([NFBUtil isIOS7]) {
            [UIApplication sharedApplication].statusBarHidden = NO;
        }
        self.view.backgroundColor = [UIColor whiteColor];
    }
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    if ([NFBUtil isIOS7]) {
        navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.bounds), 64.0)];
    } else{
        navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.bounds), 44.0)];
    }
    
    [navigationBar setBarStyle:UIBarStyleDefault];
    [navigationBar setTranslucent:YES];
    navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UINavigationItem *aNavigationItem = [[UINavigationItem alloc] initWithTitle:@""];
    aNavigationItem.leftBarButtonItem = [NFBUIFactory navigationBarItemWithTitle:@"关闭"
                                                                           image:nil
                                                                          target:self
                                                                          action:@selector(cancel)];

    if (self.lookermode == ImageLookerNormal) {
        aNavigationItem.rightBarButtonItem = [NFBUIFactory navigationBarItemWithTitle:@"保存" image:nil target:self action:@selector(save)];
    } else {
        aNavigationItem.rightBarButtonItem = [NFBUIFactory navigationBarItemWithTitle:@"删除" image:nil target:self action:@selector(delete)];
        UIButton *delBt = (UIButton *)aNavigationItem.rightBarButtonItem.customView;
        [delBt setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
    
    [navigationBar setItems:[NSArray arrayWithObject:aNavigationItem]];
    
    [[self view] addSubview:navigationBar];
    
    lookerView = [[NFBImageLookerView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    lookerView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:lookerView];
}

-(void)dealloc{
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
    _scrollView.delegate = nil;
}

-(id)initWithMode:(ImageLookerMode) mode{
    if (self = [super init]) {
        self.lookermode = mode;
    }
    return self;
}

#pragma mark 设备方向

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                        duration:(NSTimeInterval)duration {
    [self reSetViewOnOrientation:toInterfaceOrientation];
}

- (void)reSetView {
    [self reSetViewOnOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void)reSetViewOnOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)
        || [UIDevice currentDevice].systemVersion.integerValue >= 7) {//iOS7及以上，frame已经更新
        CGFloat width = CGRectGetWidth(self.view.frame);
        CGFloat height = CGRectGetHeight(self.view.frame);
        lookerView.frame = CGRectMake(0, 0, width, height);
        [self setWidth:CGRectGetWidth(self.view.frame) forNavigationBar:navigationBar];
        lookerView.zoomScale = 1.0f;
        lookerView.contentSize = CGSizeMake(width, height);
        
        CGFloat imageWidth = 0;
        CGFloat imageHeight = 0;
        if (lookerView.imageView.image != NULL) {
            imageWidth = lookerView.imageView.image.size.width;
            imageHeight = lookerView.imageView.image.size.height;
        } else {
            imageWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
            imageHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
        }
        CGFloat ratio = imageWidth/imageHeight;
        if (ratio >= CGRectGetWidth([UIScreen mainScreen].bounds)/CGRectGetHeight([UIScreen mainScreen].bounds)) {
            imageWidth = width;
            imageHeight = roundf(width / ratio);
            lookerView.imageView.frame = CGRectMake(0, (height-imageHeight)/2, imageWidth, imageHeight);
        } else {
            imageHeight = height;
            imageWidth = roundf(height * ratio);
            lookerView.imageView.frame = CGRectMake((width-imageWidth)/2, 0, imageWidth, imageHeight);
        }
    } else {
        CGFloat width = CGRectGetWidth(self.view.frame);
        CGFloat height = CGRectGetHeight(self.view.frame);
        lookerView.frame = CGRectMake(0, 0, height, width);
        [self setWidth:CGRectGetHeight(self.view.frame) forNavigationBar:navigationBar];
        lookerView.zoomScale = 1.0f;
        lookerView.contentSize = CGSizeMake(height, width);
        
        CGFloat imageWidth = 0;
        CGFloat imageHeight = 0;
        if (lookerView.imageView.image != NULL) {
            imageWidth = lookerView.imageView.image.size.width;
            imageHeight = lookerView.imageView.image.size.height;
        } else {
            imageWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
            imageHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
        }
        CGFloat ratio = imageWidth/imageHeight;
        if (ratio >= CGRectGetHeight([UIScreen mainScreen].bounds)/CGRectGetWidth([UIScreen mainScreen].bounds)) {
            imageWidth = height;
            imageHeight = roundf(height / ratio);
            lookerView.imageView.frame = CGRectMake(0, (width-imageHeight)/2, imageWidth, imageHeight);
        } else {
            imageHeight = width;
            imageWidth = roundf(width * ratio);
            lookerView.imageView.frame = CGRectMake((height-imageWidth)/2, 0, imageWidth, imageHeight);
        }
    }
}

- (void)setWidth:(CGFloat)width forNavigationBar:(UINavigationBar *)navBar {
    CGRect frame = navBar.frame;
    frame.size.width = width;
    navBar.frame = frame;
}

@end
