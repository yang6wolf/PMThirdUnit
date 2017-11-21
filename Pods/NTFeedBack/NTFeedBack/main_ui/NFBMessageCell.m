//
//  FBMessageCell.m
//  NeteaseLottery
//
//  Created by wangbo on 13-3-21.
//  Copyright (c) 2013年 netease. All rights reserved.
//

#import "NFBMessageCell.h"
#import "NFBCopyLabel.h"
#import "NFBImageLoaderView.h"
#import "NFBAutoReplyQuestionsView.h"
#import "NFBDataBackupPool.h"
#import "NFBQequestSession.h"
#import "NFBAppearanceProxy.h"
#import "NFBUtil.h"
#import "NFBNotifications.h"
#import "NFBConfig.h"

#define kImageWidth   35
#define kImageHeight  35

#define kMaxMessageContentWidth (SCREEN_WIDTH - 120)

#define kMoreQuestion @"更多"


@interface NFBAutoReplyQuestionsCell()
@property (nonatomic, strong) NSArray *questions;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) NFBAutoReplyQuestionsView *questionsView;
@property (nonatomic, strong) UIImageView *bubbleImageView;
@property (nonatomic, strong) UIImageView *mmImageView;
@end

@implementation NFBAutoReplyQuestionsCell

+(UIFont *)messageFont{
	return [UIFont systemFontOfSize:16];
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.selectionStyle =  UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        self.questionsView = [[NFBAutoReplyQuestionsView alloc] initWithFrame:CGRectZero];
        self.questionsView.backgroundColor = [UIColor clearColor];
        self.questionsView.delegate = (id<NFBAutoReplyQuestionsViewDelegate>)self;
        
        self.mmImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 3, 48, 48)];
        self.mmImageView.layer.cornerRadius = [[NFBAppearanceProxy sharedAppearance] avatarCornerRadiusPersent] * self.mmImageView.frame.size.width;
        self.mmImageView.clipsToBounds = YES;
        [self.mmImageView setImage:[[NFBAppearanceProxy sharedAppearance] answerAvatarImage]];
        [self.contentView addSubview:self.mmImageView];
        
        self.bubbleImageView = [[UIImageView alloc] initWithImage:nil];
        self.bubbleImageView.userInteractionEnabled = YES;
    }
    return self;
}

+ (CGSize)sizeForContent:(NSArray *)questions {
    if ([NFBConfig sharedConfig].helpLink) {
       questions = [questions arrayByAddingObject:kMoreQuestion];
    }
    CGSize cellSize = [NFBAutoReplyQuestionsView sizeForContent:questions font:[self messageFont]];
    cellSize.width += 30;
    cellSize.height += 20;
    if (cellSize.height<40) {
        cellSize.height= 40;
    }
    return cellSize;
}

- (void)setWithContent:(NSArray *)aQuestions {
    CGFloat y=5;
    if ([NFBConfig sharedConfig].helpLink) {
        self.questions = [aQuestions arrayByAddingObject:kMoreQuestion];
    } else {
        self.questions = aQuestions;
    }
    [self.bubbleImageView setImage:[[NFBAppearanceProxy sharedAppearance] answerContentBackgroundImage]];
    CGSize size = [NFBAutoReplyQuestionsCell sizeForContent:aQuestions];
    self.bubbleImageView.frame = CGRectMake(60,y, size.width+5, size.height);
    [self.contentView addSubview:self.bubbleImageView];
    

    self.questionsView.hidden = NO;
    self.questionsView.frame = CGRectMake(25, 10, size.width-25, size.height-15);
    [self.questionsView setContent:self.questions font:[NFBAutoReplyQuestionsCell messageFont] color:[UIColor blueColor]];
    [self.bubbleImageView addSubview:self.questionsView];
}

- (void)autoReplyQuestionsView:(NFBAutoReplyQuestionsView*)questionView selectQuestion:(NSUInteger)index {
    if ([self.questions[index] isKindOfClass:[NSString class]] && [self.questions[index] isEqualToString:kMoreQuestion]) {
        [self.delegate messageCell:self didOpenLink:[NFBConfig sharedConfig].helpLink];
    } else {
        [[NFBQequestSession session] sendAutoReplayQuestion:self.questions[index]];
    }
}

@end


@interface NFBMessageCell()<ImageLoaderViewDelegate,UIGestureRecognizerDelegate>
@property (nonatomic, strong) NFBCopyLabel *contentLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIImageView *mmImageView;
@property (nonatomic, strong) UIImageView *bubbleImageView;
@property (nonatomic, strong) NFBImageLoaderView *contentImageView;
@property (nonatomic, strong) UIView  *statusView;
@property (nonatomic, strong) FeedBackMessages *message;
@property (nonatomic, strong) UIImageView *avatarView;
@end

@implementation NFBMessageCell

+(UIFont *)messageFont{
	return [UIFont systemFontOfSize:16];
}

+ (CGSize)messageContentSize:(FeedBackMessages *)message constrainedToWidth:(CGFloat)maxContentWidth {
    NFBRTLabel *tmpLabel =  [[NFBCopyLabel alloc] initWithFrame:CGRectMake(0, 0, maxContentWidth, 0)];
    tmpLabel.font = [NFBMessageCell messageFont];
    //这里先去掉html标签，再加上
    NSString *contentString = message.content;
    NSString *newStr = [self checkAddHTMLTag:contentString];
    tmpLabel.text = newStr;
    [tmpLabel setNeedsDisplay];
    return CGSizeMake(tmpLabel.optimumSize.width, tmpLabel.optimumSize.height);
}

+ (CGSize)sizeForMessage:(FeedBackMessages *)message{
    CGSize cellSize = CGSizeMake(0, 0);
    //NSLog(@"imageUrl %@",message.imgUrl);
    
    if ([message.imgUrl length] != 0) {
        if ([message.content length] != 0) {
            CGSize contentSize = [self messageContentSize:message constrainedToWidth:kMaxMessageContentWidth];
            cellSize.height += contentSize.height;
            cellSize.width = kMaxMessageContentWidth;
        }
        CGSize size;
        UIImage *image = [UIImage imageWithData:[NFBDataBackupPool dataForKey:message.imgUrl]];
        if(image == nil) {
            cellSize.width = kMaxMessageContentWidth;
            cellSize.height += kMaxMessageContentWidth*0.75;
        } else {
            if (cellSize.width !=0 ) {
                size = image.size;
                if (cellSize.width < 100) {
                    cellSize.width = 100;
                }
                CGFloat imageheight = cellSize.width*size.height/size.width;
                cellSize.height += imageheight;
            } else {
                size = image.size;
                if (size.height > size.width*2) {
                    CGFloat imageheight = 200;
                    cellSize.width = imageheight*size.width/size.height;
                    cellSize.height += imageheight;
                } else {
                    cellSize.width = 100;
                    cellSize.height += cellSize.width*size.height/size.width;
                }
            }
        }
        
        cellSize.width += 25;
        cellSize.height += 20;
    } else if ([message.content length] != 0) {
        cellSize = [self messageContentSize:message constrainedToWidth:kMaxMessageContentWidth];
        if (cellSize.width > kMaxMessageContentWidth-10.0f) {
            cellSize.width = kMaxMessageContentWidth;
        }
        cellSize.width += 25;
        cellSize.height += 20;
    }
    return cellSize;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle =  UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        self.contentLabel = [[NFBCopyLabel alloc] initWithFrame:CGRectZero];
        self.contentLabel.delegate = (id<NFBRTLabelDelegate>)self;
        self.contentLabel.font = [NFBMessageCell messageFont];
        self.contentLabel.textColor = [[NFBAppearanceProxy sharedAppearance] questionTextColor];
        self.contentLabel.backgroundColor = [UIColor clearColor];
        
        self.mmImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 3, 48, 48)];
        self.mmImageView.layer.cornerRadius = [[NFBAppearanceProxy sharedAppearance] avatarCornerRadiusPersent] * self.mmImageView.frame.size.width;
        self.mmImageView.clipsToBounds = YES;
        [self.mmImageView setImage:[[NFBAppearanceProxy sharedAppearance] answerAvatarImage]];
        [self.contentView addSubview:self.mmImageView];
        
        self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-125, 10, 100, 18)];
        self.dateLabel.backgroundColor = [UIColor clearColor];
        self.dateLabel.font = [UIFont systemFontOfSize:10];
        self.dateLabel.textAlignment = NSTextAlignmentRight;
        self.dateLabel.textColor = [[NFBAppearanceProxy sharedAppearance] dateTextColor];
        [self.contentView addSubview:self.dateLabel];
        
        self.bubbleImageView = [[UIImageView alloc] initWithImage:nil];
        self.bubbleImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(taped:)];
        recognizer.delegate = self;
        [self.bubbleImageView addGestureRecognizer:recognizer];
        
        self.statusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [self.contentView addSubview:self.statusView];
        
        self.contentImageView = [[NFBImageLoaderView alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
        self.contentImageView.userInteractionEnabled = YES;
        self.contentImageView.showBigImage = YES;
        self.contentImageView.showProgress = YES;
        self.contentImageView.delegate = self;
        self.contentImageView.backupImage = [[NFBAppearanceProxy sharedAppearance] placeHolderImage];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)taped:(UIGestureRecognizer *)recognizer {
    if ([[_message isOut] boolValue]) {
        if ([_message.status intValue] == FBMessageSTSendFailed) {
            _message.status = [NSNumber numberWithInt:FBMessageSTResend];
            [[NFBQequestSession session] sendMessage:_message];
            [self setWithMessage:_message];
        }
    }
    //删掉了之前点击cell中的label直接调用openUrl的delegate的代码
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    //return NO;
    return YES;
}

- (UITableView *)detectTableView {
	UIResponder *responder = [self nextResponder];
	while (responder) {
		if ([responder isKindOfClass:[UITableView class]]) {
			return (UITableView *)responder;
		}
		responder = [responder nextResponder];
	}
	return nil;
}

- (void)imageLoaderViewDidLoadImage:(NFBImageLoaderView *)loaderView {
    [[self detectTableView] reloadData];
}
     
- (void)imageLoaderViewLoadImageError:(NFBImageLoaderView *)loaderView {
    self.dateLabel.text = @"图片加载失败";
    self.dateLabel.textColor = [[NFBAppearanceProxy sharedAppearance] failTextColor];
}


- (void)messageStatusChanged:(NSNotification *)notification {
    FeedBackMessages *message = (FeedBackMessages *)notification.object;
    if (message != _message) {
        return;
    }
    [self setWithMessage:_message];
}

- (void)setWithMessage:(FeedBackMessages *)message {
    _message = message;
    CGFloat y=5;
    
    [self.contentLabel removeFromSuperview];
    self.contentImageView.image = nil;
    self.contentImageView.imageUrl = nil;
    [self.contentImageView removeFromSuperview];
    
    [self.contentView addSubview:self.bubbleImageView];
    if (message.content) {
        NSString *newStr = [[self class] removeHTMLTag:message.content];
        newStr = [[self class] checkAddHTMLTag:newStr];
        self.contentLabel.text = newStr;
        [self.bubbleImageView addSubview:self.contentLabel];
    }
    if ([message.imgUrl length] != 0) {
        [self.contentImageView loadImageUrl:message.imgUrl];
        [self.bubbleImageView addSubview:self.contentImageView];
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self name:NFeedBackMessageStatusChanged object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NFeedBackMessageUploadProgressChanged object:nil];
    
    CGSize size = [NFBMessageCell sizeForMessage:message];
    if ([[message isOut] boolValue]) {
        self.mmImageView.frame = CGRectMake(SCREEN_WIDTH-60, 1, 48, 48);
        [self.mmImageView setImage:[[NFBAppearanceProxy sharedAppearance] defaultAvatar]];
        [[NFBAppearanceProxy sharedAppearance] configAvatarImageView:self.mmImageView];
        [self.bubbleImageView setImage:[[NFBAppearanceProxy sharedAppearance] questionContentBackgroundImage]];
        CGFloat bubbleX = self.mmImageView.hidden ? SCREEN_WIDTH - size.width - 15: SCREEN_WIDTH - size.width - 15 - 48;
        self.bubbleImageView.frame = CGRectMake(bubbleX, y, size.width+5, size.height);
        if ([message.imgUrl length] != 0) {
            self.contentImageView.frame = CGRectMake(10, 10, size.width-25, size.height-20);
        } else{
            self.contentLabel.frame = CGRectMake(10, 10, size.width-20, size.height-20);
        }
    } else {
        self.mmImageView.frame = CGRectMake(12, 5, 48, 48);
        [self.mmImageView setImage:[[NFBAppearanceProxy sharedAppearance] answerAvatarImage]];
        [self.bubbleImageView setImage:[[NFBAppearanceProxy sharedAppearance] answerContentBackgroundImage]];
        self.bubbleImageView.frame = CGRectMake(60, y, size.width+5, size.height);
        if ([message.imgUrl length] != 0) {
            CGSize contentSize = [NFBMessageCell messageContentSize:message constrainedToWidth:kMaxMessageContentWidth];
            self.contentLabel.frame = CGRectMake(20, 7.5, size.width-25, contentSize.height);
            self.contentImageView.frame = CGRectMake(20, 12.5+contentSize.height, size.width-25, size.height-contentSize.height-20);
        } else if (message.content) {
            self.contentLabel.frame = CGRectMake(20, 10, size.width-25, size.height-20);
        }
    }
    [self refreshDataLabelStatusWithMessage:message];
}

- (void)refreshDataLabelStatusWithMessage:(FeedBackMessages*)message {
    self.dateLabel.textColor = [[NFBAppearanceProxy sharedAppearance] dateTextColor];
    self.dateLabel.frame = CGRectMake(SCREEN_WIDTH-125, CGRectGetMaxY(self.bubbleImageView.frame)+3, 100, 15);
    self.dateLabel.text = [NFBUtil stringFromDate:message.time withFormat:@"MM-dd HH:mm"];
    self.statusView.frame = CGRectMake(CGRectGetMinX(self.bubbleImageView.frame) - 23, CGRectGetMaxY(self.bubbleImageView.frame)-30, 19, 19);
    
    for (UIView *view in self.statusView.subviews) {
        [view removeFromSuperview];
    }
    
    [self.contentImageView setUploadProgress:nil];
    if (([message.status intValue] == FBMessageSTSending) || ([message.status intValue] == FBMessageSTResend)) {
        if ([[NFBQequestSession session] isMessageSending:message]) {
            
            UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithFrame:self.statusView.bounds];
            indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
            [self.statusView addSubview:indicator];
            [indicator startAnimating];
            self.statusView.hidden = NO;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageStatusChanged:) name:NFeedBackMessageStatusChanged object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageStatusChanged:) name:NFeedBackMessageUploadProgressChanged object:nil];
            if ([message.status intValue] == FBMessageSTResend) {
                self.dateLabel.text = @"正在重新发送...";
            }
            
            if ([NFBQequestSession session].uploadProgresses[message.imgUrl]) {
                NSNumber *progressNum = (NSNumber *)[NFBQequestSession session].uploadProgresses[message.imgUrl];
                [self.contentImageView setUploadProgress:[NSString stringWithFormat:@"%lu%%", (unsigned long)progressNum.unsignedIntegerValue]];
            }
        } else {
            message.status = [NSNumber numberWithInt:FBMessageSTSendFailed];
        }
    }
    
    if ([message.status intValue] == FBMessageSTSendFailed) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.statusView.bounds];
        [imageView setImage:[[NFBAppearanceProxy sharedAppearance] warningImage]];
        [self.statusView addSubview:imageView];
        self.statusView.hidden = NO;
        self.dateLabel.textColor = [[NFBAppearanceProxy sharedAppearance] failTextColor];
        self.dateLabel.text = @"发送失败,点击重试";
        [self.contentImageView setUploadProgress:@"发送失败"];
    }
    
    self.contentImageView.showBigImage = ([message.status intValue] != FBMessageSTSendFailed);
    
    if (![[message isOut] boolValue]) {
        self.statusView.hidden = YES;
        //时间对齐
//        if (CGRectGetMaxX(self.bubbleImageView.frame)-90 > 60) {
//            dataLabel.frame = CGRectMake(CGRectGetMaxX(self.bubbleImageView.frame)-90, CGRectGetMaxY(self.bubbleImageView.frame), 80, 18);
//        }else{
//            dataLabel.frame = CGRectMake(60, CGRectGetMaxY(self.bubbleImageView.frame), 80, 18);
//        }
        self.dateLabel.text = [NFBUtil stringFromDate:message.time withFormat:@"MM-dd HH:mm"];
    }
}

+ (NSString *)removeHTMLTag:(NSString*)originStr {
    NSRange r;
    while ((r = [originStr rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        originStr = [originStr stringByReplacingCharactersInRange:r withString:@""];
    return originStr;
    
}

+ (NSString *)checkAddHTMLTag:(NSString *)originStr {
    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray *matches = [linkDetector matchesInString:originStr options:0 range:NSMakeRange(0, [originStr length])];
    NSInteger addLength = 0;
    NSString *outputString = originStr;
    for (NSTextCheckingResult *match in matches) {
        if ([match resultType] == NSTextCheckingTypeLink) {
            NSString *urlString = [originStr substringWithRange:match.range];
            if ([urlString rangeOfString:@"://"].location != NSNotFound) {
                NSString *replaceString = [NSString stringWithFormat:@"<a href='%@'>%@</a>",urlString,urlString];
                NSRange range = NSMakeRange(match.range.location + addLength, match.range.length);
                outputString = [outputString stringByReplacingCharactersInRange:range withString:replaceString];
                addLength += 15 + [urlString length];
            }
        }
    }
    return outputString;
}

#pragma mark NFBRTLabel delegate
- (void)rtLabel:(id)rtLabel didSelectLinkWithURL:(NSURL*)url
{
    [self.delegate messageCell:self didOpenLink:[url absoluteString]];
}

@end




