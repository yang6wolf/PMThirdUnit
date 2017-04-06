//
//  FBViewController.m
//  NeteaseLottery
//
//  Created by wangbo on 13-3-21.
//  Copyright (c) 2013年 netease. All rights reserved.
//

#import "NFBViewController.h"
#import "NFBMessageCell.h"
#import "FeedBackMessages.h"
#import "NFBAppearance.h"
#import "NFBUIFactory.h"
#import "NFBAppearanceProxy.h"
#import "NFBDefaultAppearance.h"
#import "NFBUtil.h"
#import "NFBNotifications.h"
#import "NFBManager.h"
#import "NFBUIInputToolbar.h"
#import "NFBMMHeaderView.h"
#import "NFBAutoReply.h"
#import "NFBEvaluationView.h"

@interface NFBViewController()<NFBUIInputToolbarDelegate,NFBMessageCellDelegate,UIGestureRecognizerDelegate,NFBEvaluationViewDelegate>
@property(nonatomic) CGRect containerFrame; //container的正常frame，当keyboard出现时，container的frame会变化
@property (nonatomic, assign) BOOL shouldShowKeyboard;

@end

@implementation NFBViewController {
    NFBMMHeaderView* headerView;
    NFBUIInputToolbar *inputToolBar;
}


#pragma mark controller life cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self isBeingPresented]||[self isMovingToParentViewController]) {
        [self updateLayout];
        [self scrollToBottomAnimated:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (CGRectIsEmpty(self.containerFrame)) {
        self.containerFrame = self.containerView.frame;
    }
}


#pragma mark override methods
- (void)setAppearance:(id<NFBAppearance>)appearance {
    [[NFBAppearanceProxy sharedAppearance] setCustomAppearance:appearance];
}


- (void)openUrl:(NSString*)url {
    //这里改为通过delegate告知外部处理
    if ([self.delegate respondsToSelector:@selector(NTFeedBackOpenUrlString:)]) {
        [self.delegate NTFeedBackOpenUrlString:url];
    }
}

- (void)onMessageArrayReloaded
{
    [self.tableView reloadData];
    [self performSelector:@selector(delayedScrollToBottomAnimated:) withObject:@YES afterDelay:0.1];
}

#pragma mark view creation
-(void) viewDidLoad{
    [super viewDidLoad];
    
    self.shouldShowKeyboard = YES;
    
    //增加头部视图，显示在线与否文案
    headerView = [[NFBMMHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.containerView.bounds.size.width, MM_HEADER_HEIGHT)];
    [self.containerView addSubview:headerView];

    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTable:)];
    recognizer.delegate = self;
    [self.tableView addGestureRecognizer:recognizer];
    [self.tableView.panGestureRecognizer addTarget:self action:@selector(scrollTable:)];
    
    inputToolBar = [[NFBUIInputToolbar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44.0f)];
    inputToolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    inputToolBar.delegate = self;
    [self.containerView addSubview:inputToolBar];
    
    if ([[NFBAppearanceProxy sharedAppearance] provideServiceEvaluation]) {
        UIBarButtonItem *serviceEvluation = [NFBUIFactory navigationBarItemWithTitle:nil
                                                                               image:[[NFBAppearanceProxy sharedAppearance] evaluationNavigationButtonImage]
                                                                              target:self
                                                                              action:@selector(serviceEvaluation:)];
        
        UIBarButtonItem *servicePhone = self.navigationItem.rightBarButtonItem;
        if (!servicePhone) {
            self.navigationItem.rightBarButtonItem = serviceEvluation;
        } else {
            self.navigationItem.rightBarButtonItems = @[servicePhone,serviceEvluation];
        }
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
	                                         selector:@selector(keyboardWillShow:)
	                                             name:UIKeyboardWillChangeFrameNotification
	                                           object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
	                                         selector:@selector(keyboardWillHide:)
	                                             name:UIKeyboardWillHideNotification
	                                           object:nil];
}


- (void)hideHeaderViewIfOneline {
    if ([NFBAutoReplySession sharedSession].isOnline
        &&!headerView.hidden) {
        headerView.hidden = YES;
        [self updateLayout];
    }
}

- (void)updateLayout {
    if (headerView.hidden) {
        self.tableView.frame = CGRectMake(0, 0, CGRectGetWidth(self.containerView.frame), CGRectGetHeight(self.containerView.frame)-CGRectGetHeight(inputToolBar.frame));
    } else {
        self.tableView.frame = CGRectMake(0, CGRectGetHeight(headerView.frame),
                                      CGRectGetWidth(self.containerView.frame),
                                      CGRectGetHeight(self.containerView.frame)-CGRectGetHeight(headerView.frame)-CGRectGetHeight(inputToolBar.frame));
    }
    inputToolBar.frame = CGRectMake(0, CGRectGetMaxY(self.tableView.frame),  CGRectGetWidth(self.containerView.frame), CGRectGetHeight(inputToolBar.frame));
}

#pragma mark input tool bar delegate
-(void)inputButtonPressed:(NSString *)inputText{
    [self sendTextMessage:inputText];
}

-(void)imageButtonPressed{
    [self selectAndSendImage];
}

-(void)inputToolbarHeightChanged:(CGFloat)height{
    [self updateLayout];
    [self scrollToBottomAnimated:NO];
}


- (void)scrollToBottomAnimated:(BOOL)animated {
    NSInteger numRows = [self.tableView numberOfRowsInSection:0];
    if (numRows > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(numRows - 1) inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}


- (void)delayedScrollToBottomAnimated:(NSNumber *)animated {
	[self scrollToBottomAnimated:[animated boolValue]];
}


-(void) tapTable:(UIGestureRecognizer*)recognizer{
    [inputToolBar resignFirstResponder];
}

- (void)scrollTable:(UIGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (!headerView.hidden && [NFBAutoReplySession sharedSession].isOnline) {
            [UIView animateWithDuration:0.3 animations:^{
                [self hideHeaderViewIfOneline];
            }];
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    // 过滤掉UIButton，也可以是其他类型
    if ( [touch.view isKindOfClass:[UIButton class]]){
        return NO;
    }
    return YES;
}

#pragma mark evaluation view
-(void)serviceEvaluation:(id)sender
{
    [inputToolBar resignFirstResponder];
    NFBEvaluationView *evaluationView = [[NFBEvaluationView alloc] init];
    evaluationView.delegate = self;
    [evaluationView show];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NFeedBackActionEventNotification object:nil userInfo:@{NFeedBackEvaluationKey:@"客服评价"}];
}

- (void)viewWillMoveToSuper:(NFBEvaluationView *)evaluationView
{
    self.shouldShowKeyboard = NO;
}

- (void)viewWillRemoveFromSuper:(NFBEvaluationView *)evaluationView
{
    self.shouldShowKeyboard = YES;
}

#pragma mark tableView datasource&delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)sender numberOfRowsInSection:(NSInteger)sectionIndex {
	return [self.messageArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [self.messageArray objectAtIndex:indexPath.row];
    if ([object isKindOfClass:[FeedBackMessages class]]) {
        FeedBackMessages *message = (FeedBackMessages *)object;
        CGSize cellSize = [NFBMessageCell sizeForMessage:message];
        return cellSize.height+25;
    } else if ([object isKindOfClass:[NSArray class]]){
        CGSize cellSize = [NFBAutoReplyQuestionsCell sizeForContent:object];
        return cellSize.height+25;
    }
    return 0.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [self.messageArray objectAtIndex:indexPath.row];
    if ([object isKindOfClass:[FeedBackMessages class]]) {
        static NSString *CellIdentifier = @"FBMessageCell";
        NFBMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil){
            cell = [[NFBMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.delegate = self;
        }
        
        FeedBackMessages *message = (FeedBackMessages *)object;
        [cell setWithMessage:message];
        return cell;
    } else if ([object isKindOfClass:[NSArray class]]) {
        static NSString *CellIdentifier = @"FBHintMessageCell";
        NFBAutoReplyQuestionsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil){
            cell = [[NFBAutoReplyQuestionsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.delegate = self;
        }
        [cell setWithContent:object];
        return cell;
    }
    return nil;
}


#pragma mark NFBMessageCellDelegate
- (void)messageCell:(UITableViewCell *)cell didOpenLink:(NSString *)link {
    [self openUrl:link];
}

#pragma mark keyboard Notifications
- (void)keyboardWillShow:(NSNotification *)notification {
    if (!self.shouldShowKeyboard) {
        return;
    }
	NSTimeInterval animationDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyBoardFrame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:animationDuration animations:^{
        CGRect oldFrame = self.containerFrame;
        oldFrame.size.height -= keyBoardFrame.size.height;
        self.containerView.frame = oldFrame;
        [self hideHeaderViewIfOneline];
        [self updateLayout];
    }];
    [self scrollToBottomAnimated:YES];
}

- (void)hideKeyboard:(id)sender{
	[inputToolBar resignFirstResponder];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if (!self.shouldShowKeyboard) {
        return;
    }
    NSTimeInterval animationDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:animationDuration animations:^{
        self.containerView.frame = self.containerFrame;
        [self updateLayout];
    }];
}


@end


