/*
 LDAssetsPageViewController.m
 
 The MIT License (MIT)
 
 Copyright (c) 2013 Clement CN Tsang
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

#import "LDAssetsPageViewController.h"
#import "LDAssetItemViewController.h"
#import "LDAssetScrollView.h"
#import "NFBAppearanceProxy.h"
#import "NFBUIFactory.h"



@interface LDAssetsPageViewController ()
<UIPageViewControllerDataSource, UIPageViewControllerDelegate, LDAssetItemViewControllerDataSource>

@property (nonatomic, strong) NSArray *assets;
@property (nonatomic, assign, getter = isStatusBarHidden) BOOL statusBarHidden;

@end





@implementation LDAssetsPageViewController

- (id)initWithAssets:(NSArray *)assets
{
    self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                    navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                  options:@{UIPageViewControllerOptionInterPageSpacingKey:@30.f}];
    if (self)
    {
        self.assets                 = assets;
        self.dataSource             = self;
        self.delegate               = self;
        self.view.backgroundColor   = [UIColor whiteColor];
        if ([UIDevice currentDevice].systemVersion.integerValue>=7){
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupButtons];
    [self addNotificationObserver];
}

- (void)dealloc
{
    [self removeNotificationObserver];
}

- (BOOL)prefersStatusBarHidden
{
    return self.isStatusBarHidden;
}

- (void)setupButtons
{
    if ([[NFBAppearanceProxy sharedAppearance] navigationBackButtonImage]) {
        self.navigationItem.leftBarButtonItem = [NFBUIFactory navigationBarItemWithTitle:nil image:[[NFBAppearanceProxy sharedAppearance] navigationBackButtonImage] target:self action:@selector(popup:)];
    }
}

#pragma mark - Update Title

- (void)setTitleIndex:(NSInteger)index
{
    NSInteger count = self.assets.count;
    self.title      = [NSString stringWithFormat:NSLocalizedString(@"%ld of %ld", nil), index, count];
    self.navigationItem.titleView = [NFBUIFactory labelForNavTitle:self.title];
}


#pragma mark - Actions

- (void)popup:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Page Index

- (NSInteger)pageIndex
{
    return ((LDAssetItemViewController *)self.viewControllers[0]).pageIndex;
}

- (void)setPageIndex:(NSInteger)pageIndex
{
    NSInteger count = self.assets.count;
    
    if (pageIndex >= 0 && pageIndex < count)
    {
        LDAssetItemViewController *page = [LDAssetItemViewController assetItemViewControllerForPageIndex:pageIndex];
        page.dataSource = self;
        
        [self setViewControllers:@[page]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:NO
                      completion:NULL];
        
        [self setTitleIndex:pageIndex + 1];
    }
}


#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = ((LDAssetItemViewController *)viewController).pageIndex;
    
    if (index > 0)
    {
        LDAssetItemViewController *page = [LDAssetItemViewController assetItemViewControllerForPageIndex:(index - 1)];
        page.dataSource = self;
        
        return page;
    }
    
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger count = self.assets.count;
    NSInteger index = ((LDAssetItemViewController *)viewController).pageIndex;
    
    if (index < count - 1)
    {
        LDAssetItemViewController *page = [LDAssetItemViewController assetItemViewControllerForPageIndex:(index + 1)];
        page.dataSource = self;
        
        return page;
    }
    
    return nil;
}


#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed)
    {
        LDAssetItemViewController *vc   = (LDAssetItemViewController *)pageViewController.viewControllers[0];
        NSInteger index                 = vc.pageIndex + 1;
        
        [self setTitleIndex:index];
    }
}


#pragma mark - Notification Observer

- (void)addNotificationObserver
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
               selector:@selector(scrollViewTapped:)
                   name:LDAssetScrollViewTappedNotification
                 object:nil];
}

- (void)removeNotificationObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LDAssetScrollViewTappedNotification object:nil];
}


#pragma mark - Tap Gesture

- (void)scrollViewTapped:(NSNotification *)notification
{
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *)notification.object;
    
    if (gesture.numberOfTapsRequired == 1)
        [self toogleNavigationBar:gesture];
}


#pragma mark - Fade in / away navigation bar

- (void)toogleNavigationBar:(id)sender
{
	if (self.isStatusBarHidden)
		[self fadeNavigationBarIn];
    else
		[self fadeNavigationBarAway];
}

- (void)fadeNavigationBarAway
{
    self.statusBarHidden = YES;
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         if ([UIDevice currentDevice].systemVersion.integerValue>=7) {
                              [self setNeedsStatusBarAppearanceUpdate];
                         }
                        
                         [self.navigationController.navigationBar setAlpha:0.0f];
                         [self.navigationController setNavigationBarHidden:YES];
                         self.view.backgroundColor = [UIColor blackColor];
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

- (void)fadeNavigationBarIn
{
    self.statusBarHidden = NO;
    [self.navigationController setNavigationBarHidden:NO];
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         //[self setNeedsStatusBarAppearanceUpdate];
                         [self.navigationController.navigationBar setAlpha:1.0f];
                         self.view.backgroundColor = [UIColor whiteColor];
                     }];
}



#pragma mark - LDAssetItemViewControllerDataSource

- (ALAsset *)assetAtIndex:(NSUInteger)index;
{
    return [self.assets objectAtIndex:index];
}

@end
