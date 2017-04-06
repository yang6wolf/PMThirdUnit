//
//  NFBViewControllerBase.m
//  NTFeedBack
//
//  Created by  龙会湖 on 10/31/14.
//  Copyright (c) 2014 netease. All rights reserved.
//

#import "NFBViewControllerBase.h"
#import "NFBMessageCell.h"
#import "FeedBackMessages.h"
#import "NFBQequestSession.h"
#import "NFBMessageDB.h"
#import "NFBAutoReply.h"
#import "NFBAppearance.h"
#import "NFBUIFactory.h"
#import "NFBAppearanceProxy.h"
#import "NFBDefaultAppearance.h"
#import "NFBUtil.h"
#import "NFBNotifications.h"
#import "NFBManager.h"
#import "LDAssetsPickerController.h"
#import "NFBLatestImgV.h"
#import "NFBActionSheet.h"
#import "NFBConfig.h"

@interface NFBViewControllerBase()
@property(nonatomic,copy) NSString *imageName;//用于存储上一张图片的唯一标示符，避免重复发送。
@end

@implementation NFBViewControllerBase {
    UINavigationBar *_navigationBar;
    UIView *_containerView;
    UITableView * _tableView;
    
    
    NSMutableArray *_messageArray;
}



#pragma mark controller life cycle

-(id)init{
    if (self = [super init]) {
        [self configController];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self configController];
}

- (void)configController {
    self.hidesBottomBarWhenPushed = YES;
    if ([NFBUtil isIOS7]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [[NFBAppearanceProxy sharedAppearance] setDefaultAppearance:[[NFBDefaultAppearance alloc] init]];
}


-(void)dealloc{
    [[NFBQequestSession session] startPollMessage:NFBPollingMessageSlow];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self isBeingPresented]||[self isMovingToParentViewController]) {
        [NFBAutoReplySession sharedSession].shouldAutoReplyToCustomQuestion = YES;
    }
}


#pragma mark public methods
- (void)setAppearance:(id<NFBAppearance>)appearance {
    [[NFBAppearanceProxy sharedAppearance] setCustomAppearance:appearance];
}

- (void)sendTextMessage:(NSString*)textMessage {
    NSString *text =[textMessage stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([text length] == 0) {
        [NFBUtil alertView:@"不能发送空内容"];
        return;
    }
    [[NFBQequestSession session] sendMessageWithContent:text andImg:nil andTitle:nil];
    [self loadLastMessages];
}

- (void)selectAndSendImage {
    if ([[NFBAppearanceProxy sharedAppearance] enableSelectImageFromCamera]
        && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NFBActionSheet *sheet = [[NFBActionSheet alloc] initWithTitle:@"选择图片" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从手机相册选择", nil];
        sheet.dismissBlock = ^(NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                [self doSelectImageFromCamera];
            } else if (buttonIndex == 1) {
                [self doSelectImageFromAssets];
            }
        };
        [sheet showInController:self];
    } else {
        [self doSelectImageFromAssets];
    }
}


- (void)openUrl:(NSString*)url {
    //do nothing
}

- (void)onMessageArrayReloaded {
    
}


#pragma mark view creation
-(void) viewDidLoad{
    [super viewDidLoad];
    
    self.title = @"客服mm";
    self.navigationItem.titleView = [NFBUIFactory labelForNavTitle:self.title];
    self.view.backgroundColor  = [[NFBAppearanceProxy sharedAppearance] mainViewBackgroundColor];
    
    [self configNavigationBar];
    
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.sectionHeaderHeight = 5.0f;
    self.tableView.sectionFooterHeight = 5.0f;
    [self.containerView addSubview:self.tableView];

    NSInteger unReadCount = [[NFBQequestSession session] unreadNums];
    NSArray * recentMessages = [[NFBMessageDB  getInstance] tenMessageBeforeDate:nil];
    if (unReadCount>recentMessages.count) {
        unReadCount = recentMessages.count;
    }

     _messageArray = [[NSMutableArray alloc] init];
    [_messageArray addObjectsFromArray:[recentMessages subarrayWithRange:NSMakeRange(0,recentMessages.count-unReadCount)]];
    [_messageArray addObject:[[NFBAutoReplySession sharedSession] autoReplyQuestionsWithEntrance:self.entrance]];
    [_messageArray addObjectsFromArray:[recentMessages subarrayWithRange:NSMakeRange(recentMessages.count-unReadCount,unReadCount)]];


    //调整到_messageArray初始化消息下方，防止单例上一次请求的消息在第二次进入时候到来，导致崩溃
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification_:) name:NFBNewMessageArrived object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadNewAutoReplymessage:) name:NFBNewAutoReplyMessageArrived object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadNewAutoReplymessage:) name:NFBAutoReplyEvaluationMessageArrived object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification_:) name:NFBAutoReplySessionDidRefreshed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification_:) name:UIApplicationWillEnterForegroundNotification object:nil];


    [[NFBQequestSession session] setUnreadNums:0];
    [[NFBQequestSession session] startPollMessage:NFBPollingMessageFast];
    
    [[NFBAutoReplySession sharedSession] refreshAutoReplyMessages];
}

- (void)configNavigationBar {
    if (self.navigationController) {
        _containerView = self.view;
    } else {
        [self.view addSubview:self.navigationBar];
        _containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH, CGRectGetHeight(self.view.frame)-44)];
        _containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:_containerView];
        
        NSInteger osMainVersion = [UIDevice currentDevice].systemVersion.integerValue;
        if (osMainVersion>=7) {
            _containerView.frame = CGRectMake(0, 64, SCREEN_WIDTH,  CGRectGetHeight(self.view.frame)-64);
        }
    }
    
    if (self.navigationController) {
        if ([[NFBAppearanceProxy sharedAppearance] navigationBackButtonImage]) {
            self.navigationItem.leftBarButtonItem = [NFBUIFactory navigationBarItemWithTitle:nil
                                                                               image:[[NFBAppearanceProxy sharedAppearance] navigationBackButtonImage]
                                                                              target:self
                                                                              action:@selector(popNFBController)];
        }
    } else {
        self.navigationItem.leftBarButtonItem = [NFBUIFactory navigationBarItemWithTitle:@"关闭"
                                                                           image:nil
                                                                          target:self
                                                                          action:@selector(dismissNFBController)];
    }
    
    
    if ([[NFBAppearanceProxy sharedAppearance] provideServicePhone]) {
        NSString *servicePhoneURL = [NSString stringWithFormat:@"tel:%@", [NFBConfig sharedConfig].servicePhone];
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:servicePhoneURL]]) {
            self.navigationItem.rightBarButtonItem = [NFBUIFactory navigationBarItemWithTitle:@"客服电话"
                                                                                        image:nil
                                                                                       target:self
                                                                                       action:@selector(servicePhone:)];
        }
    }
}

- (UINavigationBar*)navigationBar {
    if (!self.navigationController&&!_navigationBar) {
        if ([NFBUtil isIOS7]) {
            _navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH, 64.0f)];
        } else {
            _navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH, 44.0f)];
        }
        [_navigationBar pushNavigationItem:self.navigationItem animated:NO];
    }
    return _navigationBar;
}


#pragma mark notifications
- (void)receiveNotification_:(NSNotification*)note {
    if ([note.name isEqualToString:NFBNewMessageArrived]) {
        [self loadLastMessages];
    } else if ([note.name isEqualToString:NFBAutoReplySessionDidRefreshed]) {
        NSUInteger autoReplyQuestionIndex = [_messageArray indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return [obj isKindOfClass:[NSArray class]];
        }];
        
        NSArray *autoReplyQuestions = [[NFBAutoReplySession sharedSession] autoReplyQuestionsWithEntrance:self.entrance];
        if (autoReplyQuestionIndex!=NSNotFound&&autoReplyQuestions) {
            [_messageArray replaceObjectAtIndex:autoReplyQuestionIndex withObject:autoReplyQuestions];
            [self.tableView reloadData];
        }
    } else if ([note.name isEqualToString:UIApplicationWillEnterForegroundNotification]) {
        [[NFBAutoReplySession sharedSession] refreshAutoReplyMessages];
    }
}

- (void)popNFBController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dismissNFBController {
    [[self presentingViewController] dismissViewControllerAnimated:YES
                                                        completion:nil];
}

- (void)loadLastMessages{
    NSDate *lastDate = [NSDate dateWithTimeIntervalSince1970:10000];
    if(_messageArray.count > 0){
        for(int k = (int)(_messageArray.count-1); k >= 0; k--){
            id object = [_messageArray objectAtIndex:k];
            if ([object isKindOfClass:[FeedBackMessages class]]) {
                FeedBackMessages *message = (FeedBackMessages *)object;
                if (message.msgid != nil) {
                    lastDate = message.time;
                    break;
                }
            }//if
        }//for
    }

    NSArray *array  = [[NFBMessageDB getInstance] messagesAfterDate:lastDate];
    //NSLog(@"lastDate==%@, array=%@", lastDate, array);
    for(FeedBackMessages *newMessage in array){
        if([_messageArray indexOfObject:newMessage] == NSNotFound){
            [_messageArray addObject:newMessage];
        }
    }

    [[NFBQequestSession session] setUnreadNums:0];
    [self onMessageArrayReloaded];
}

- (void)loadNewAutoReplymessage:(NSNotification *) notification{
    FeedBackMessages *message = (FeedBackMessages *)notification.object;
    [_messageArray addObject:message];

    //保证只要点击autoReply消息，未读消息就算读过了
    [[NFBQequestSession session] setUnreadNums:0];
    [self onMessageArrayReloaded];
}


#pragma mark input tool bar delegate

- (void)doSelectImageFromCamera {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.delegate = (id <UINavigationControllerDelegate, UIImagePickerControllerDelegate>) self;
    [self presentViewController:picker animated:YES completion:nil];
}

-(void)doSelectImageFromAssets {
    __block UIImage *lastestImg = nil;
    
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                 usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                     if (nil != group) {
                                         
                                         // be sure to filter the group so you only get photos
                                         [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                                         if (!group.numberOfAssets) { //相册为空
                                             [self showImagePicker];
                                         } else{
                                             [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:group.numberOfAssets - 1] options:0 usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                                 if (nil != result) {
                                                     NSTimeInterval timeInterval =  [[NSDate date] timeIntervalSinceDate:[result valueForProperty:ALAssetPropertyDate]];
                                                     lastestImg =[UIImage imageWithCGImage:result.defaultRepresentation.fullScreenImage];
                                                     *stop = YES;
                                                     if (timeInterval < 30 && ![result.defaultRepresentation.filename isEqualToString:self.imageName]) {
                                                         NFBLatestImgV *lastestV = [[NFBLatestImgV alloc] initWithFrame:self.view.bounds andImgV:lastestImg andButtonPressedBlock:^(NSInteger buttonTag){
                                                             if (buttonTag == 101) {//okBtn pressed
                                                                 
                                                                 lastestImg = [self scaleAndRotateImage:lastestImg];
                                                                 [[NFBQequestSession session] sendMessageWithContent:nil andImg:lastestImg andTitle:nil];
                                                                 [self loadLastMessages];
                                                             }
                                                             
                                                             if (buttonTag == 102) { //chooseOther pressed
                                                                 [self showImagePicker];
                                                             }
                                                         }];
                                                         self.imageName = result.defaultRepresentation.filename;
                                                         [self.view addSubview:lastestV];
                                                     } else{
                                                         [self showImagePicker];
                                                     }
                                                 }
                                             }];
                                         }
                                         *stop = NO;
                                     }
                                     
                                 } failureBlock:^(NSError *error) {
                                     NSLog(@"error: %@", error);
                                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"此应用程序没有权限来访问您的照片或视频" message:@"您可以在“隐私设置”中启用访问" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                                     [alert show];
                                 }];
}

-(void)showImagePicker
{
    if ([UIDevice currentDevice].systemVersion.integerValue >= 6) { //6.0及以上使用多选图片，6.0以下单选
        LDAssetsPickerController *picker = [[LDAssetsPickerController alloc] init];
        picker.maximumNumberOfSelections = 5;
        picker.assetsFilter = [ALAssetsFilter allAssets];
        picker.showsCancelButton = YES;
        picker.delegate = (id <UINavigationControllerDelegate, LDAssetsPickerControllerDelegate>)self;

        if([[NFBAppearanceProxy sharedAppearance] assetsPickerNavigationBarBackImage] != nil){
            [picker.navigationBar setBackgroundImage:[[NFBAppearanceProxy sharedAppearance] assetsPickerNavigationBarBackImage] forBarMetrics:UIBarMetricsDefault];
        }
        [picker.navigationBar setTranslucent:[[NFBAppearanceProxy sharedAppearance] enableAssetsPickerNavigationBarTranslucent]];
        
        [self presentViewController:picker animated:YES completion:nil];
    } else{
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        picker.delegate = (id <UINavigationControllerDelegate, UIImagePickerControllerDelegate>) self;
        [self presentViewController:picker animated:YES completion:nil];
        
    }
    
}


#pragma mark tableView datasource&delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)sender numberOfRowsInSection:(NSInteger)sectionIndex {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 0.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}


#pragma mark NFBMessageCellDelegate
- (void)messageCell:(UITableViewCell *)cell didOpenLink:(NSString *)link {
    [self openUrl:link];
}

#pragma mark 电话

-(void)servicePhone:(id)sender
{
    NSString *phoneString = [NSString stringWithFormat:@"拨打热线 %@",[NFBConfig sharedConfig].servicePhone];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:(id<UIActionSheetDelegate>)self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:phoneString
                                                    otherButtonTitles:nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        NSString *servicePhoneURL = [NSString stringWithFormat:@"tel:%@", [NFBConfig sharedConfig].servicePhone];
        NSURL *phoneUrl = [NSURL URLWithString:servicePhoneURL];
        [[UIApplication sharedApplication] openURL:phoneUrl];
    }
}


#pragma mark image picker delegate
//多选图片回调
- (void)assetsPickerController:(LDAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    for (ALAsset *imgSet in assets) {
        UIImage *img=[UIImage imageWithCGImage:imgSet.defaultRepresentation.fullScreenImage];
        img = [self scaleAndRotateImage:img];
        [[NFBQequestSession session] sendMessageWithContent:nil andImg:img andTitle:nil];
    }
    
    [self loadLastMessages];
}

//单选图片回调
- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    UIImage *img= (UIImage*)[info objectForKey:UIImagePickerControllerOriginalImage];
    img = [self scaleAndRotateImage:img];
    [[NFBQequestSession session] sendMessageWithContent:nil andImg:img andTitle:nil];
    [picker dismissViewControllerAnimated:YES completion:^{
        [self loadLastMessages];
    }];
    
    
}

- (UIImage *)scaleAndRotateImage:(UIImage*)originImg {
    
    int kMaxResolution = 480; // Or whatever
    
    CGImageRef imgRef = originImg.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = roundf(bounds.size.width / ratio);
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = roundf(bounds.size.height * ratio);
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = originImg.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}




@end
