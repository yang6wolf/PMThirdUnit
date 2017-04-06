
/*
 LDAssetsPickerController.m
 
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


#import "LDAssetsPickerController.h"
#import "NFBAppearanceProxy.h"
#import "NFBUtil.h"
#import "NFBUIFactory.h"
#import "LDAssetsPageViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "LDAssetsPickerCommon.h"

#define IS_IOS7             ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending)
#define kThumbnailLength    (SCREEN_WIDTH/4 - 2.0f)
#define kThumbnailSize      CGSizeMake(kThumbnailLength, kThumbnailLength)
#define kPopoverContentSize CGSizeMake(SCREEN_WIDTH, 480)


#pragma mark - Interfaces

@interface LDAssetsPickerController ()

@property (nonatomic, copy) NSArray *indexPathsForSelectedItems;

@end


@interface LDAssetsGroupViewController : UITableViewController

@end


@interface LDAssetsGroupViewController()

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *groups;

@end


@interface LDAssetsViewController : UICollectionViewController

@property (nonatomic, strong) ALAssetsGroup *assetsGroup;

@end

@interface LDAssetsViewController ()

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, assign) NSInteger numberOfPhotos;
@property (nonatomic, assign) NSInteger numberOfVideos;

@end


@interface LDAssetsGroupViewCell : UITableViewCell

- (void)bind:(ALAssetsGroup *)assetsGroup;

@end

@interface LDAssetsGroupViewCell ()

@property (nonatomic, strong) ALAssetsGroup *assetsGroup;

@end


@interface LDAssetsViewCell : UICollectionViewCell

- (void)bind:(ALAsset *)asset;

@end

@interface LDAssetsViewCell ()

@property (nonatomic, strong) ALAsset *asset;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *videoImage;
@property (nonatomic, assign) BOOL disabled;

@end


@interface LDAssetsSupplementaryView : UICollectionReusableView

@property (nonatomic, strong) UILabel *sectionLabel;

- (void)setNumberOfPhotos:(NSInteger)numberOfPhotos numberOfVideos:(NSInteger)numberOfVideos;

@end


@interface LDAssetsSupplementaryView ()

@end






#pragma mark - LDAssetsPickerController


@implementation LDAssetsPickerController
@dynamic delegate;

- (id)init
{
    LDAssetsGroupViewController *groupViewController = [[LDAssetsGroupViewController alloc] init];
    
    if (self = [super initWithRootViewController:groupViewController])
    {
        _maximumNumberOfSelections  = NSIntegerMax;
        _assetsFilter               = [ALAssetsFilter allAssets];
        _showsCancelButton          = YES;
        _showsEmptyGroups           = NO;
        _selectionFilter            = [NSPredicate predicateWithValue:YES];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
        if ([self respondsToSelector:@selector(setPreferredContentSize:)])
            [self setPreferredContentSize:kPopoverContentSize];
#else
        if ([self respondsToSelector:@selector(setContentSizeForViewInPopover:)])
            [self setContentSizeForViewInPopover:kPopoverContentSize];
#endif
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end




#pragma mark - LDAssetsGroupViewController

@implementation LDAssetsGroupViewController


- (id)init
{
    if (self = [super initWithStyle:UITableViewStylePlain])
    {
        self.title = @"相册";
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
        if ([self respondsToSelector:@selector(setPreferredContentSize:)])
            [self setPreferredContentSize:kPopoverContentSize];
#else
        if ([self respondsToSelector:@selector(setContentSizeForViewInPopover:)])
            [self setContentSizeForViewInPopover:kPopoverContentSize];
#endif
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.titleView = [NFBUIFactory labelForNavTitle:self.title];

    [self setupViews];
    [self setupButtons];
    [self localize];
    [self setupGroup];
}


#pragma mark - Rotation

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}


#pragma mark - Setup

- (void)setupViews
{
    self.tableView.rowHeight = kThumbnailLength + 12;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)setupButtons
{
    LDAssetsPickerController *picker = (LDAssetsPickerController *)self.navigationController;
    
    if (picker.showsCancelButton)
    {
        self.navigationItem.rightBarButtonItem = [NFBUIFactory navigationBarItemWithTitle:@"取消"
                                                                            image:nil
                                                                           target:self
                                                                           action:@selector(dismiss:)];
    }
}

- (void)localize
{
    self.title = NSLocalizedString(self.title, nil);
}

- (void)setupGroup
{
    if (!self.assetsLibrary)
        self.assetsLibrary = [self.class defaultAssetsLibrary];
    
    if (!self.groups)
        self.groups = [[NSMutableArray alloc] init];
    else
        [self.groups removeAllObjects];
    
    LDAssetsPickerController *picker = (LDAssetsPickerController *)self.navigationController;
    ALAssetsFilter *assetsFilter = picker.assetsFilter;
    
    ALAssetsLibraryGroupsEnumerationResultsBlock resultsBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        
        if (group)
        {
            [group setAssetsFilter:assetsFilter];
            if (group.numberOfAssets > 0 || picker.showsEmptyGroups)
                [self.groups addObject:group];
        }
        else
        {
            [self reloadData];
        }
    };
    
    
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        
        [self showNotAllowed];
        
    };
    
    // Enumerate Camera roll first
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                      usingBlock:resultsBlock
                                    failureBlock:failureBlock];
    
    // Then all other groups
    NSUInteger type =
    ALAssetsGroupLibrary | ALAssetsGroupAlbum | ALAssetsGroupEvent |
    ALAssetsGroupFaces | ALAssetsGroupPhotoStream;
    
    [self.assetsLibrary enumerateGroupsWithTypes:type
                                      usingBlock:resultsBlock
                                    failureBlock:failureBlock];
}


#pragma mark - Reload Data

- (void)reloadData
{
    if (self.groups.count == 0)
        [self showNoAssets];
    
    [self.tableView reloadData];
}


#pragma mark - ALAssetsLibrary

+ (ALAssetsLibrary *)defaultAssetsLibrary
{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}


#pragma mark - Not allowed / No assets

- (void)showNotAllowed
{
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
        [self setEdgesForExtendedLayout:UIRectEdgeLeft | UIRectEdgeRight | UIRectEdgeBottom];
    
    self.title              = nil;
    
    UIImageView *padlock    = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LDAssetsPickerLocked"]];
    padlock.translatesAutoresizingMaskIntoConstraints = NO;
    
    UILabel *title          = [UILabel new];
    title.translatesAutoresizingMaskIntoConstraints = NO;
    title.preferredMaxLayoutWidth = 304.0f;
    
    UILabel *message        = [UILabel new];
    message.translatesAutoresizingMaskIntoConstraints = NO;
    message.preferredMaxLayoutWidth = 304.0f;
    
    title.text              = NSLocalizedString(@"没有权限访问您的相册", nil);
    title.font              = [UIFont boldSystemFontOfSize:17.0];
    title.textColor         = [UIColor colorWithRed:129.0/255.0 green:136.0/255.0 blue:148.0/255.0 alpha:1];
    title.textAlignment     = NSTextAlignmentCenter;
    title.numberOfLines     = 5;
    
    message.text            = NSLocalizedString(@"请在隐私设置中打开相册访问权限", nil);
    message.font            = [UIFont systemFontOfSize:14.0];
    message.textColor       = [UIColor colorWithRed:129.0/255.0 green:136.0/255.0 blue:148.0/255.0 alpha:1];
    message.textAlignment   = NSTextAlignmentCenter;
    message.numberOfLines   = 5;
    
    [title sizeToFit];
    [message sizeToFit];
    
    UIView *centerView = [UIView new];
    centerView.translatesAutoresizingMaskIntoConstraints = NO;
    [centerView addSubview:padlock];
    [centerView addSubview:title];
    [centerView addSubview:message];
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(padlock, title, message);
    
    [centerView addConstraint:[NSLayoutConstraint constraintWithItem:padlock attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:centerView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [centerView addConstraint:[NSLayoutConstraint constraintWithItem:title attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:padlock attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [centerView addConstraint:[NSLayoutConstraint constraintWithItem:message attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:padlock attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [centerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[padlock]-[title]-[message]|" options:0 metrics:nil views:viewsDictionary]];
    
    UIView *backgroundView = [UIView new];
    [backgroundView addSubview:centerView];
    [backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:centerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:backgroundView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:centerView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:backgroundView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
    
    self.tableView.backgroundView = backgroundView;
}

- (void)showNoAssets
{
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
        [self setEdgesForExtendedLayout:UIRectEdgeLeft | UIRectEdgeRight | UIRectEdgeBottom];
    
    UILabel *title          = [UILabel new];
    title.translatesAutoresizingMaskIntoConstraints = NO;
    title.preferredMaxLayoutWidth = 304.0f;
    UILabel *message        = [UILabel new];
    message.translatesAutoresizingMaskIntoConstraints = NO;
    message.preferredMaxLayoutWidth = 304.0f;
    
    title.text              = NSLocalizedString(@"No Photos or Videos", nil);
    title.font              = [UIFont systemFontOfSize:26.0];
    title.textColor         = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1];
    title.textAlignment     = NSTextAlignmentCenter;
    title.numberOfLines     = 5;
    
    message.text            = NSLocalizedString(@"You can sync photos and videos onto your iPhone using iTunes.", nil);
    message.font            = [UIFont systemFontOfSize:18.0];
    message.textColor       = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1];
    message.textAlignment   = NSTextAlignmentCenter;
    message.numberOfLines   = 5;
    
    [title sizeToFit];
    [message sizeToFit];
    
    UIView *centerView = [UIView new];
    centerView.translatesAutoresizingMaskIntoConstraints = NO;
    [centerView addSubview:title];
    [centerView addSubview:message];
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(title, message);
    
    [centerView addConstraint:[NSLayoutConstraint constraintWithItem:title attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:centerView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [centerView addConstraint:[NSLayoutConstraint constraintWithItem:message attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:title attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [centerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[title]-[message]|" options:0 metrics:nil views:viewsDictionary]];
    
    UIView *backgroundView = [UIView new];
    [backgroundView addSubview:centerView];
    [backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:centerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:backgroundView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:centerView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:backgroundView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
    
    self.tableView.backgroundView = backgroundView;
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.groups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    LDAssetsGroupViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[LDAssetsGroupViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    [cell bind:[self.groups objectAtIndex:indexPath.row]];
    
    return cell;
}


#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kThumbnailLength + 12;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LDAssetsViewController *vc = [[LDAssetsViewController alloc] init];
    vc.assetsGroup = [self.groups objectAtIndex:indexPath.row];
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Actions
- (void)dismiss:(id)sender
{
    LDAssetsPickerController *picker = (LDAssetsPickerController *)self.navigationController;
    
    if ([picker.delegate respondsToSelector:@selector(assetsPickerControllerDidCancel:)])
        [picker.delegate assetsPickerControllerDidCancel:picker];
    
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end



#pragma mark - LDAssetsGroupViewCell

@implementation LDAssetsGroupViewCell


- (void)bind:(ALAssetsGroup *)assetsGroup
{
    self.assetsGroup            = assetsGroup;
    
    CGImageRef posterImage      = assetsGroup.posterImage;
    size_t height               = CGImageGetHeight(posterImage);
    float scale                 = height / kThumbnailLength;
    
    self.imageView.image        = [UIImage imageWithCGImage:posterImage scale:scale orientation:UIImageOrientationUp];
    self.textLabel.text         = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    self.detailTextLabel.text   = [NSString stringWithFormat:@"%ld", (long)[assetsGroup numberOfAssets]];
    self.accessoryType          = UITableViewCellAccessoryDisclosureIndicator;
}

- (NSString *)accessibilityLabel
{
    NSString *label = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    
    return [label stringByAppendingFormat:NSLocalizedString(@"%ld 张照片", nil), (long)[self.assetsGroup numberOfAssets]];
}

@end




#pragma mark - LDAssetsViewController

#define kAssetsViewCellIdentifier           @"AssetsViewCellIdentifier"
#define kAssetsSupplementaryViewIdentifier  @"AssetsSupplementaryViewIdentifier"

@implementation LDAssetsViewController
{
    UICollectionViewCell *_selectedCell;
    UILabel *_countLabel;
    UIToolbar *_toolBar;
    UIImageView *_backgroundImgV;
    UIButton *_doneButton;
    UIButton *_previewButton;
}

- (id)init
{
    self.layout                         = [[UICollectionViewFlowLayout alloc] init];
    self.layout.itemSize                = kThumbnailSize;
    self.layout.footerReferenceSize     = CGSizeMake(0, 50.0);
    self.layout.sectionInset            = UIEdgeInsetsMake(9.0, 0, 0, 0);
    self.layout.minimumInteritemSpacing = (LDIPhone6Plus) ? 0.5 : ( (LDIPhone6) ? 1.0 : 2.0 );
    self.layout.minimumLineSpacing      = (LDIPhone6Plus) ? 0.5 : ( (LDIPhone6) ? 1.0 : 2.0 );
    
    if (self = [super initWithCollectionViewLayout:self.layout])
    {
        self.collectionView.allowsMultipleSelection = YES;
        
        [self.collectionView registerClass:[LDAssetsViewCell class]
                forCellWithReuseIdentifier:kAssetsViewCellIdentifier];
        
        [self.collectionView registerClass:[LDAssetsSupplementaryView class]
                forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                       withReuseIdentifier:kAssetsSupplementaryViewIdentifier];
        
        if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
            [self setEdgesForExtendedLayout:UIRectEdgeNone];
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
        if ([self respondsToSelector:@selector(setPreferredContentSize:)])
            [self setPreferredContentSize:kPopoverContentSize];
#else
        if ([self respondsToSelector:@selector(setContentSizeForViewInPopover:)])
            [self setContentSizeForViewInPopover:kPopoverContentSize];
#endif
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupViews];
    [self setupButtons];
    [self addGestureRecognizer];
    [self resetViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupAssets];
    self.navigationItem.titleView = [NFBUIFactory labelForNavTitle:self.title];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //[self resetIndexPathsOfSelectedItem];
}


#pragma mark - Rotation

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    self.layout.itemSize             = kThumbnailSize;
    
    [self resetViews];
}


#pragma mark - Setup

- (void)setupViews
{
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor yellowColor];
    _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 44 - 44, self.view.bounds.size.width,  44)];
    if ([UIDevice currentDevice].systemVersion.intValue >=7) {
        _toolBar.barTintColor = [UIColor blackColor];
    } else{
        _toolBar.tintColor = [UIColor blackColor];
       
    }
    
    [self.view addSubview:_toolBar];
    
    _doneButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 70, 6, 60, 32)];
    [_doneButton setBackgroundImage:[[NFBAppearanceProxy sharedAppearance] toolBarConfirmButtonImage] forState:UIControlStateNormal];
    [_doneButton setTitle:@"发送" forState:UIControlStateNormal];
    [_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_doneButton addTarget:self action:@selector(finishPickingAssets:) forControlEvents:UIControlEventTouchUpInside];
    [_toolBar addSubview:_doneButton];
    
    _backgroundImgV = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 80, 2, 21, 21)];
    _backgroundImgV.hidden = YES;
    _backgroundImgV.image = [[NFBAppearanceProxy sharedAppearance] selectedImgsCountBackgroundImg];
    [_toolBar addSubview:_backgroundImgV];
    
    _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 75, 2, 21, 21)];
    _countLabel.textColor = [UIColor whiteColor];
    _countLabel.backgroundColor = [UIColor clearColor];
    _countLabel.hidden = YES;
    [_toolBar addSubview:_countLabel];
    
    _previewButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 6, 60, 32)];
    [_previewButton setTitle:@"预览" forState:UIControlStateNormal];
    [_previewButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    [_previewButton setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    [_previewButton setBackgroundImage:[[NFBAppearanceProxy sharedAppearance] imgPickerPreviewImage] forState:UIControlStateNormal];
    [_previewButton setBackgroundImage:[[NFBAppearanceProxy sharedAppearance] imgPickerPreviewDisableImage] forState:UIControlStateDisabled];
    [_previewButton addTarget:self action:@selector(showPrevController) forControlEvents:UIControlEventTouchUpInside];
    _previewButton.enabled = NO;
    [_toolBar addSubview:_previewButton];
}

- (void)setupButtons
{
    if ([[NFBAppearanceProxy sharedAppearance] navigationBackButtonImage]) {
        self.navigationItem.leftBarButtonItem = [NFBUIFactory navigationBarItemWithTitle:nil image:[[NFBAppearanceProxy sharedAppearance] navigationBackButtonImage] target:self action:@selector(popup:)];
    }

    self.navigationItem.rightBarButtonItem = [NFBUIFactory navigationBarItemWithTitle:@"取消"
                                                                        image:nil
                                                                       target:self
                                                                       action:@selector(dismiss:)];
}

- (void)setupAssets
{
    self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    self.numberOfPhotos = 0;
    self.numberOfVideos = 0;
    
    if (!self.assets)
        self.assets = [[NSMutableArray alloc] init];
    else
        //[self.assets removeAllObjects];
        return;
    
    ALAssetsGroupEnumerationResultsBlock resultsBlock = ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
        
        if (asset)
        {
            [self.assets addObject:asset];
            
            NSString *type = [asset valueForProperty:ALAssetPropertyType];
            
            if ([type isEqual:ALAssetTypePhoto])
                self.numberOfPhotos ++;
            if ([type isEqual:ALAssetTypeVideo])
                self.numberOfVideos ++;
        }
        
        else if (self.assets.count > 0)
        {
            [self.collectionView reloadData];
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.assets.count-1 inSection:0]
                                        atScrollPosition:UICollectionViewScrollPositionTop
                                                animated:YES];
        }
    };
    
    [self.assetsGroup enumerateAssetsUsingBlock:resultsBlock];
}

- (void)resetIndexPathsOfSelectedItem
{
    LDAssetsPickerController *vc = (LDAssetsPickerController *)self.navigationController;
    vc.indexPathsForSelectedItems = nil;
}

#pragma mark - Reset

- (void)resetViews {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 9.0) {
        _toolBar.frame =
        CGRectMake(0, CGRectGetHeight(self.view.bounds) - 44 - 44, CGRectGetWidth(self.view.bounds), 44);

    } else {
        _toolBar.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - 44 - 64, CGRectGetWidth(self.view.bounds), 44);
    }
    _doneButton.frame = CGRectMake(self.view.bounds.size.width - 70, 6, 60, 32);
    _backgroundImgV.frame = CGRectMake(self.view.bounds.size.width - 80, 2, 21, 21);
    _countLabel.frame = CGRectMake(self.view.bounds.size.width - 75, 2, 21, 21);
}

#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = kAssetsViewCellIdentifier;
    LDAssetsPickerController *picker = (LDAssetsPickerController *)self.navigationController;
    
    LDAssetsViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    ALAsset* asset = [self.assets objectAtIndex:indexPath.row];
    [cell bind:asset];
    cell.disabled = ! [picker.selectionFilter evaluateWithObject:asset];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    static NSString *viewIdentifiert = kAssetsSupplementaryViewIdentifier;
    
    LDAssetsSupplementaryView *view =
    [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:viewIdentifiert forIndexPath:indexPath];
    
    [view setNumberOfPhotos:self.numberOfPhotos numberOfVideos:self.numberOfVideos];
    
    return view;
}


#pragma mark - Collection View Delegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    LDAssetsPickerController *vc = (LDAssetsPickerController *)self.navigationController;
    ALAsset* asset = [self.assets objectAtIndex:indexPath.row];
    BOOL selectable = [vc.selectionFilter evaluateWithObject:asset];
    
    return (selectable && collectionView.indexPathsForSelectedItems.count < vc.maximumNumberOfSelections);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedCell = [collectionView cellForItemAtIndexPath:indexPath];
    LDAssetsPickerController *vc = (LDAssetsPickerController *)self.navigationController;
    vc.indexPathsForSelectedItems = collectionView.indexPathsForSelectedItems;
    
    if ([vc.delegate respondsToSelector:@selector(assetsPickerController:didSelectItemAtIndexPath:)])
        [vc.delegate assetsPickerController:vc didSelectItemAtIndexPath:indexPath];
    
    [self setTitleWithSelectedIndexPaths:collectionView.indexPathsForSelectedItems];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    LDAssetsPickerController *vc = (LDAssetsPickerController *)self.navigationController;
    vc.indexPathsForSelectedItems = collectionView.indexPathsForSelectedItems;
    
    if ([vc.delegate respondsToSelector:@selector(assetsPickerController:didDeselectItemAtIndexPath:)])
        [vc.delegate assetsPickerController:vc didDeselectItemAtIndexPath:indexPath];
    
    [self setTitleWithSelectedIndexPaths:collectionView.indexPathsForSelectedItems];
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    LDAssetsPickerController *vc = (LDAssetsPickerController *)self.navigationController;
    
    if ([vc.delegate respondsToSelector:@selector(assetsPickerController:didHighlightItemAtIndexPath:)])
        [vc.delegate assetsPickerController:vc didHighlightItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    LDAssetsPickerController *vc = (LDAssetsPickerController *)self.navigationController;
    
    if ([vc.delegate respondsToSelector:@selector(assetsPickerController:didUnhighlightItemAtIndexPath:)])
        [vc.delegate assetsPickerController:vc didUnhighlightItemAtIndexPath:indexPath];
}


#pragma mark - Title

- (void)setTitleWithSelectedIndexPaths:(NSArray *)indexPaths
{
    // Reset title to group name
    if (indexPaths.count == 0)
    {
        self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
        _countLabel.hidden = YES;
        _backgroundImgV.hidden = YES;
        _previewButton.enabled = NO;
        return;
    }
    
    _previewButton.enabled = YES;
    
    BOOL photosSelected = NO;
    BOOL videoSelected  = NO;
    
    for (NSIndexPath *indexPath in indexPaths)
    {
        ALAsset *asset = [self.assets objectAtIndex:indexPath.item];
        
        if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypePhoto])
            photosSelected  = YES;
        
        if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo])
            videoSelected   = YES;
        
        if (photosSelected && videoSelected)
            break;
    }
    
    NSString *format;
    
    if (photosSelected && videoSelected)
        format = NSLocalizedString(@"%ld Items Selected", nil);
    
    else if (photosSelected)
        format = (indexPaths.count > 1) ? NSLocalizedString(@"已选择%ld张", nil) : NSLocalizedString(@"已选择%ld张", nil);
    
    else if (videoSelected)
        format = (indexPaths.count > 1) ? NSLocalizedString(@"%ld Videos Selected", nil) : NSLocalizedString(@"%ld Video Selected", nil);
    
    //self.title = [NSString stringWithFormat:format, (long)indexPaths.count];
    _countLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)indexPaths.count ];
    _countLabel.hidden = NO;
    _backgroundImgV.hidden = NO;

    
}


#pragma mark - Actions

- (void)finishPickingAssets:(id)sender
{
    NSMutableArray *assets = [[NSMutableArray alloc] init];
    
    for (NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems)
    {
        ALAsset *asset = [self.assets objectAtIndex:indexPath.item];
        if(asset.defaultRepresentation) {
            [assets addObject:asset];
        }
    }
    
    LDAssetsPickerController *picker = (LDAssetsPickerController *)self.navigationController;
    
    if ([picker.delegate respondsToSelector:@selector(assetsPickerController:didFinishPickingAssets:)])
        [picker.delegate assetsPickerController:picker didFinishPickingAssets:assets];
}

- (void)popup:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dismiss:(id)sender
{
    LDAssetsPickerController *picker = (LDAssetsPickerController *)self.navigationController;
    
    if ([picker.delegate respondsToSelector:@selector(assetsPickerControllerDidCancel:)])
        [picker.delegate assetsPickerControllerDidCancel:picker];
    
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Gesture Recognizer

- (void)addGestureRecognizer
{
    UILongPressGestureRecognizer *longPress =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pushPageViewController:)];
    
    [self.collectionView addGestureRecognizer:longPress];
}


#pragma mark - Push Assets Page View Controller

- (void)pushPageViewController:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan)
    {
        CGPoint point           = [longPress locationInView:self.collectionView];
        NSIndexPath *indexPath  = [self.collectionView indexPathForItemAtPoint:point];
        
        LDAssetsPageViewController *vc = [[LDAssetsPageViewController alloc] initWithAssets:self.assets];
        vc.pageIndex = indexPath.item;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)showPrevController
{
    NSMutableArray *assets = [[NSMutableArray alloc] init];
    
    for (NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems)
    {
        ALAsset *asset = [self.assets objectAtIndex:indexPath.item];
        if(asset.defaultRepresentation) {
            [assets addObject:asset];
        }
    }
    
//    NSIndexPath *indexPath = [self.collectionView indexPathForCell:_selectedCell];
    LDAssetsPageViewController *vc = [[LDAssetsPageViewController alloc] initWithAssets:assets];
    vc.pageIndex = 0;//indexPath.item;
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end



#pragma mark - LDAssetsViewCell

@implementation LDAssetsViewCell

static UIFont *titleFont = nil;

static CGFloat titleHeight;
static UIImage *videoIcon;
static UIColor *titleColor;
static UIImage *checkedIcon;
static UIColor *selectedColor;
static UIColor *disabledColor;

+ (void)initialize
{
    titleFont       = [UIFont systemFontOfSize:12];
    titleHeight     = 20.0f;
    videoIcon       = [UIImage imageNamed:@"LDAssetsPickerVideo"];
    titleColor      = [UIColor whiteColor];
    checkedIcon     = [[NFBAppearanceProxy sharedAppearance] imgPickerCheckedImage];
    selectedColor   = [UIColor colorWithWhite:1 alpha:0.3];
    disabledColor   = [UIColor colorWithWhite:1 alpha:0.9];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.opaque                     = YES;
        self.isAccessibilityElement     = YES;
        self.accessibilityTraits        = UIAccessibilityTraitImage;
    }
    
    return self;
}

- (void)bind:(ALAsset *)asset
{
    self.asset  = asset;
    self.image  = [UIImage imageWithCGImage:asset.thumbnail];
    self.type   = [asset valueForProperty:ALAssetPropertyType];
    
    if ([self.type isEqual:ALAssetTypeVideo])
    {
        //self.title = [NSDate timeDescriptionOfTimeInterval:[[asset valueForProperty:ALAssetPropertyDuration] doubleValue]];
    }
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self setNeedsDisplay];
}


// Draw everything to improve scrolling responsiveness

- (void)drawRect:(CGRect)rect
{
    // Image
    [self.image drawInRect:CGRectMake(0, 0, kThumbnailLength, kThumbnailLength)];
    
    // Video title
    if ([self.type isEqual:ALAssetTypeVideo])
    {
        // Create a gradient from transparent to black
        CGFloat colors [] = {
            0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.8,
            0.0, 0.0, 0.0, 1.0
        };
        
        CGFloat locations [] = {0.0, 0.75, 1.0};
        
        CGColorSpaceRef baseSpace   = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient      = CGGradientCreateWithColorComponents(baseSpace, colors, locations, 2);
        
        CGContextRef context    = UIGraphicsGetCurrentContext();
        
        CGFloat height          = rect.size.height;
        CGPoint startPoint      = CGPointMake(CGRectGetMidX(rect), height - titleHeight);
        CGPoint endPoint        = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
        
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, kCGGradientDrawsBeforeStartLocation);
        
        CGGradientRelease(gradient);
        CGColorSpaceRelease(baseSpace);
    
        [titleColor set];
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;

        CGSize titleSize        = [self.title sizeWithAttributes:@{ NSFontAttributeName:titleFont }];
        [self.title drawInRect:CGRectMake(rect.size.width - titleSize.width - 2 , startPoint.y + (titleHeight - 12) / 2, kThumbnailLength, MAXFLOAT)
                withAttributes:@{ NSFontAttributeName:titleFont, NSParagraphStyleAttributeName:paragraphStyle }];
#else
        CGSize titleSize        = [self.title sizeWithFont:titleFont];
        [self.title drawAtPoint:CGPointMake(rect.size.width - titleSize.width - 2 , startPoint.y + (titleHeight - 12) / 2)
                       forWidth:kThumbnailLength
                       withFont:titleFont
                       fontSize:12
                  lineBreakMode:NSLineBreakByTruncatingTail
             baselineAdjustment:UIBaselineAdjustmentAlignCenters];
#endif
        
        
        
        [videoIcon drawAtPoint:CGPointMake(2, startPoint.y + (titleHeight - videoIcon.size.height) / 2)];
    }
    
    if (self.disabled)
    {
        CGContextRef context    = UIGraphicsGetCurrentContext();
		CGContextSetFillColorWithColor(context, disabledColor.CGColor);
		CGContextFillRect(context, rect);
    }
    
    else if (self.selected)
    {
        CGContextRef context    = UIGraphicsGetCurrentContext();
		CGContextSetFillColorWithColor(context, selectedColor.CGColor);
		CGContextFillRect(context, rect);
        
        [checkedIcon drawAtPoint:CGPointMake(CGRectGetMaxX(rect) - checkedIcon.size.width, CGRectGetMaxY(rect) - checkedIcon.size.height)];
    }
}


- (NSString *)accessibilityLabel
{
    ALAssetRepresentation *representation = self.asset.defaultRepresentation;
    
    NSMutableArray *labels          = [[NSMutableArray alloc] init];
    NSString *type                  = [self.asset valueForProperty:ALAssetPropertyType];
    NSDate *date                    = [self.asset valueForProperty:ALAssetPropertyDate];
    CGSize dimension                = representation.dimensions;
    
    
    // Type
    if ([type isEqual:ALAssetTypeVideo])
        [labels addObject:NSLocalizedString(@"Video", nil)];
    else
        [labels addObject:NSLocalizedString(@"Photo", nil)];
    
    // Orientation
    if (dimension.height >= dimension.width)
        [labels addObject:NSLocalizedString(@"Portrait", nil)];
    else
        [labels addObject:NSLocalizedString(@"Landscape", nil)];
    
    // Date
    NSDateFormatter *df             = [[NSDateFormatter alloc] init];
    df.locale                       = [NSLocale currentLocale];
    df.dateStyle                    = NSDateFormatterMediumStyle;
    df.timeStyle                    = NSDateFormatterShortStyle;
    df.doesRelativeDateFormatting   = YES;
    
    [labels addObject:[df stringFromDate:date]];
    
    return [labels componentsJoinedByString:@", "];
}


@end


#pragma mark - LDAssetsSupplementaryView

@implementation LDAssetsSupplementaryView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        _sectionLabel               = [[UILabel alloc] initWithFrame:CGRectInset(self.bounds, 8.0, 8.0)];
        _sectionLabel.font          = [UIFont systemFontOfSize:18.0];
        _sectionLabel.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:_sectionLabel];
    }
    
    return self;
}

- (void)setNumberOfPhotos:(NSInteger)numberOfPhotos numberOfVideos:(NSInteger)numberOfVideos
{
    NSString *title;
    
    if (numberOfVideos == 0)
        title = [NSString stringWithFormat:NSLocalizedString(@"%ld 张照片", nil), (long)numberOfPhotos];
    else if (numberOfPhotos == 0)
        title = [NSString stringWithFormat:NSLocalizedString(@"%ld Videos", nil), (long)numberOfVideos];
    else
        title = [NSString stringWithFormat:NSLocalizedString(@"%ld Photos, %ld Videos", nil), (long)numberOfPhotos, (long)numberOfVideos];
    
    self.sectionLabel.text = title;
}

@end
