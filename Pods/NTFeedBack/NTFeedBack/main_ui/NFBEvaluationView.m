//
//  NFBEvaluationView.m
//  Pods
//
//  Created by david on 16/4/14.
//
//

#import "NFBEvaluationView.h"
#import "HCSStarRatingView.h"
#import "NFBAppearanceProxy.h"
#import "NFBHttpRequest.h"
#import "NFBConfig.h"
#import "NFBManager.h"
#import "NFBAutoReply.h"
#import "NFBNotifications.h"

static NSString *const placeHolderText = @"请输入您的意见";
static NSInteger const wordLimit = 200;

@interface NFBEvaluationView ()<UITextViewDelegate>

@property (nonatomic, assign) BOOL committing;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) HCSStarRatingView *ratingView;

@end

@implementation NFBEvaluationView

- (instancetype)initWithFrame:(CGRect)frame
{
    CGRect scrFrame = [UIScreen mainScreen].bounds;
    if (self = [super initWithFrame:scrFrame]) {
        
        UIColor *contColor = [UIColor colorWithRed:0xf7/256.0 green:0xf7/256.0 blue:0xf7/256.0 alpha:1.0];
        UIColor *textColor = [UIColor colorWithRed:0x3c/256.0 green:0x3e/256.0 blue:0x45/256.0 alpha:1.0];
        
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self addGestureRecognizer:tap];
        
        UIView *contentView = [[UIView alloc] init];
        contentView.backgroundColor = contColor;
        contentView.layer.cornerRadius = 8.0;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textColor = textColor;
        titleLabel.font = [UIFont systemFontOfSize:18.0];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = @"请评价我们的服务";
        
        UILabel *subTitleLabel = [[UILabel alloc] init];
        subTitleLabel.textColor = textColor;
        subTitleLabel.font = [UIFont systemFontOfSize:15.0];
        subTitleLabel.text = @"服务评分:";
        
        _ratingView = [[HCSStarRatingView alloc] init];
        _ratingView.backgroundColor = [UIColor clearColor];
        _ratingView.emptyStarImage  = [[[NFBAppearanceProxy sharedAppearance] evaluationStarNormalButtonImage] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _ratingView.filledStarImage = [[[NFBAppearanceProxy sharedAppearance] evaluationStarSelectButtonImage] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _ratingView.tintColor = [[NFBAppearanceProxy sharedAppearance] evaluationStarTintColor];
        _ratingView.maximumValue = 5;
        _ratingView.minimumValue = 0;
        _ratingView.value = 0;
        _ratingView.allowsHalfStars = NO;
        
        _textView = [[UITextView alloc] init];
        _textView.delegate = self;
        _textView.layer.borderColor = [UIColor colorWithRed:0xdf/256.0 green:0xdf/256.0 blue:0xde/256.0 alpha:1.0].CGColor;
        _textView.layer.borderWidth = 0.5f;
        _textView.font = [UIFont systemFontOfSize:13.0];
        [self resetTextView];
        
        UIButton *cryptBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cryptBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [cryptBtn setTitleColor:textColor forState:UIControlStateNormal];
        [cryptBtn.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
        [cryptBtn setTitle:@"匿名评价" forState:UIControlStateNormal];
        [cryptBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        [cryptBtn setImage:[[NFBAppearanceProxy sharedAppearance] evaluationCryptNormalButtonImage] forState:UIControlStateNormal];
        [cryptBtn setImage:[[NFBAppearanceProxy sharedAppearance] evaluationCryptSelectButtonImage] forState:UIControlStateSelected];
        [cryptBtn addTarget:self action:@selector(changeStateAction:) forControlEvents:UIControlEventTouchUpInside];
        cryptBtn.selected = YES;
        
        UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        confirmBtn.layer.cornerRadius  = 5.f;
        confirmBtn.layer.masksToBounds = YES;
        confirmBtn.backgroundColor = [[NFBAppearanceProxy sharedAppearance] evaluationCommitButtonColor];
        [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [confirmBtn setTitle:@"提交" forState:UIControlStateNormal];
        [confirmBtn addTarget:self action:@selector(commitAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelBtn.layer.cornerRadius = 5.f;
        cancelBtn.layer.masksToBounds = YES;
        cancelBtn.layer.borderColor = [UIColor colorWithRed:0xd8/256.0 green:0xd8/256.0 blue:0xd8/256.0 alpha:1.0].CGColor;
        cancelBtn.layer.borderWidth = 0.5f;
        cancelBtn.backgroundColor = [UIColor colorWithRed:0xff/256.0 green:0xff/256.0 blue:0xff/256.0 alpha:1.0];
        [cancelBtn setTitleColor:textColor forState:UIControlStateNormal];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [contentView addSubview:titleLabel];
        [contentView addSubview:subTitleLabel];
        [contentView addSubview:_ratingView];
        [contentView addSubview:_textView];
        [contentView addSubview:cryptBtn];
        [contentView addSubview:confirmBtn];
        [contentView addSubview:cancelBtn];
        [self addSubview:contentView];
        
        //setupConstraints
        NSDictionary *viewsDict = NSDictionaryOfVariableBindings(contentView,titleLabel,subTitleLabel,_ratingView,_textView,cryptBtn,confirmBtn,cancelBtn);
        
        for (UIView *view in [viewsDict allValues]) {
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:0.08 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:0.84 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:320]];
        
        [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[titleLabel(60.0)][subTitleLabel]-15.0-[_ratingView(22.0)]-15.0-[_textView(90.0)]-10.0-[cryptBtn]-20.0-[cancelBtn(33.0)]-20.0-|" options:0 metrics:nil views:viewsDict]];
        [contentView addConstraint:[NSLayoutConstraint constraintWithItem:confirmBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cancelBtn attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
        [contentView addConstraint:[NSLayoutConstraint constraintWithItem:confirmBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:cancelBtn attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];

        [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[titleLabel]|" options:0 metrics:nil views:viewsDict]];
        [contentView addConstraint:[NSLayoutConstraint constraintWithItem:subTitleLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeRight multiplier:0.07/0.84 constant:0.0]];
        [contentView addConstraint:[NSLayoutConstraint constraintWithItem:subTitleLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeWidth multiplier:(1- 0.07*2/0.84) constant:0.0]];
        
        [contentView addConstraint:[NSLayoutConstraint constraintWithItem:_ratingView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeRight multiplier:0.14/0.84 constant:0.0]];
        [contentView addConstraint:[NSLayoutConstraint constraintWithItem:_ratingView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeWidth multiplier:(1- 0.14*2/0.84) constant:0.0]];
        
        [contentView addConstraint:[NSLayoutConstraint constraintWithItem:_textView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:subTitleLabel attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
        [contentView addConstraint:[NSLayoutConstraint constraintWithItem:_textView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:subTitleLabel attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
        
        [contentView addConstraint:[NSLayoutConstraint constraintWithItem:cryptBtn attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:subTitleLabel attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
        [contentView addConstraint:[NSLayoutConstraint constraintWithItem:cryptBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:subTitleLabel attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
        
        [contentView addConstraint:[NSLayoutConstraint constraintWithItem:cancelBtn attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:subTitleLabel attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
        [contentView addConstraint:[NSLayoutConstraint constraintWithItem:cancelBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeWidth multiplier:0.32/0.84 constant:0.0]];
        
        [contentView addConstraint:[NSLayoutConstraint constraintWithItem:confirmBtn attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeRight multiplier:(1- 0.07/0.84) constant:0.0]];
        [contentView addConstraint:[NSLayoutConstraint constraintWithItem:confirmBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeWidth multiplier:0.32/0.84 constant:0.0]];
    }
    return self;
}

#pragma mark - Public Methods

- (void)resetTextView
{
    self.textView.text = placeHolderText;
    self.textView.textColor = [UIColor lightGrayColor];
}

- (void)show
{
    if ([self.delegate respondsToSelector:@selector(viewWillMoveToSuper:)]) {
        [self.delegate viewWillMoveToSuper:self];
    }
    [[[UIApplication sharedApplication].delegate window] addSubview:self];
}

#pragma mark - Private Methods
- (void)tapAction:(UITapGestureRecognizer *)sender
{
    [self.textView resignFirstResponder];
}

- (void)commitAction:(id)sender
{
    if (self.committing) {
        return;
    }
    
    NSInteger rating = self.ratingView.value;
    if (!rating) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NFeedBackActionEventNotification object:nil userInfo:@{NFeedBackAlertMessageKey:@"请对我们的服务评分哦~"}];
        return;
    }
    
    [self.textView resignFirstResponder];

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"markValue"] = [NSString stringWithFormat:@"%ld",(long)rating];

    NSString *content = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    params[@"remark"] = content && [content length] ? content:@"";

    self.committing = YES;
    __weak typeof(&*self) weakself = self;
    [NFBHttpRequest startRequestWithUrl:[[NFBConfig sharedConfig].host stringByAppendingString:@"/service/kfmmScore.do"] params:params completionBlockWithSuccess:^(NSURLSessionDataTask *dataTask, id responseObject) {
        weakself.committing = NO;
        if (responseObject) {
            NSDictionary *resultJson = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            if ([resultJson[@"retCode"] integerValue] == 200) {
                FeedBackMessages *msg = [[NFBAutoReplySession sharedSession] createEvaluationMessage];
                [[NSNotificationCenter defaultCenter] postNotificationName:NFBAutoReplyEvaluationMessageArrived object:msg];
                [weakself cancelAction:nil];
            }
        }
        
    } failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
        weakself.committing = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:NFeedBackActionEventNotification object:nil userInfo:@{NFeedBackAlertMessageKey:@"网络不给力，请稍后再试"}];
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NFeedBackActionEventNotification object:nil userInfo:@{NFeedBackEvaluationCommitKey:@"客服评价提交"}];
}

- (void)cancelAction:(id)sender
{
    [self.textView resignFirstResponder];
    
    if ([self.delegate respondsToSelector:@selector(viewWillRemoveFromSuper:)]) {
        [self.delegate viewWillRemoveFromSuper:self];
    }
    
    [self removeFromSuperview];
}

- (void)changeStateAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
}

#pragma mark - TextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [UIView animateWithDuration:0.2 animations:^{
        CGRect bounds = self.bounds;
        bounds.origin.y += 80;
        self.bounds = bounds;
    }];
    
    if ([textView.text isEqualToString:placeHolderText]) {
        self.textView.text = @"";
        self.textView.textColor = [UIColor colorWithRed:0x3c/256.0 green:0x3e/256.0 blue:0x45/256.0 alpha:1.0];
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length > wordLimit)
    {
        textView.text = [textView.text substringToIndex:wordLimit];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [UIView animateWithDuration:0.2 animations:^{
        CGRect bounds = self.bounds;
        bounds.origin.y = 0;
        self.bounds = bounds;
    }];
    
    if ([textView.text isEqualToString:@""]) {
        [self resetTextView];
    }
}

@end
