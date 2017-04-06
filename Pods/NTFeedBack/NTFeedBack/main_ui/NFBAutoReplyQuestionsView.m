//
//  AutoReplyQuestionsView.m
//  NeteaseLottery
//
//  Created by bjzhangyuan on 13-12-18.
//  Copyright (c) 2013年 netease. All rights reserved.
//

#import "NFBAutoReplyQuestionsView.h"
#import "NFBViewController.h"
#import "NFBAppearanceProxy.h"
#import "NFBUtil.h"
#import "NFBQequestSession.h"

#define QUESTION_WIDTH (SCREEN_WIDTH - 120)
#define QUESTIONS_TITLE @"如您有以下问题，可直接点击了解:"

@implementation NFBAutoReplyQuestionsView{
    NSMutableArray* tapGesturesArray;
    NSMutableArray* questionsLblsArray;
    NSMutableArray* sepLineArray;
    UILabel* titleLbl;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        titleLbl = [[UILabel alloc] init];
        [self addSubview:titleLbl];
        
        sepLineArray = [NSMutableArray new];
    }
    return self;
}

+ (CGSize)sizeForContent:(NSArray*)questionArray font:(UIFont*)font {
    CGSize maxContentSize = CGSizeMake(QUESTION_WIDTH, INFINITY);
    CGSize totalContentSize = CGSizeZero;
    CGFloat verticalOffset = 10;
    totalContentSize.width = QUESTION_WIDTH;
    CGSize contentSize;
    
    for (NSString *question in questionArray) {
        if (![question isKindOfClass:[NSNull class]] && question != NULL && question.length > 0) {
            contentSize = [NFBUtil drawSizeOfString:question withFont:font constrainedToSize:maxContentSize];
            totalContentSize.height += contentSize.height;
        }
    }
    totalContentSize.height += [NFBUtil drawSizeOfString:QUESTIONS_TITLE withFont:font constrainedToSize:maxContentSize].height;
    totalContentSize.height += (verticalOffset*[questionArray count]);
    return totalContentSize;
}

-(CGSize)getContentSize:(NSString*)aQuestion font:(UIFont*)aFont{
    CGSize maxContentSize = CGSizeMake(QUESTION_WIDTH, INFINITY);
    CGSize contentSize = CGSizeZero;

    contentSize = [NFBUtil drawSizeOfString:aQuestion withFont:aFont constrainedToSize:maxContentSize];
    return contentSize;
}

-(void)setContent:(NSArray*)questionsArray font:(UIFont*)aFont color:(UIColor*)aColor {
    CGFloat previousContentBottomPos = 0.0f;
    CGFloat verticalOffset = 10;
    
    for(int i = 0;i < [questionsLblsArray count];i++){//条数是可定制的
        [[questionsLblsArray objectAtIndex:i] removeFromSuperview];
    }
    questionsLblsArray = [NSMutableArray array];
    [tapGesturesArray removeAllObjects];
    tapGesturesArray = [NSMutableArray array];
    
    [sepLineArray makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [sepLineArray removeAllObjects];
    
    titleLbl.backgroundColor = [UIColor clearColor];
    titleLbl.font = aFont;
    titleLbl.text = QUESTIONS_TITLE;
    titleLbl.textColor = [[NFBAppearanceProxy sharedAppearance]  answerTextColor];
    titleLbl.numberOfLines = 0;
    CGSize contentSize = [self getContentSize:QUESTIONS_TITLE font:aFont];
    titleLbl.frame = CGRectMake(0, previousContentBottomPos, contentSize.width, contentSize.height);
    previousContentBottomPos += (contentSize.height + verticalOffset);
    
    for (NSString *question in questionsArray) {
        if (![question isKindOfClass:[NSNull class]] && question != NULL && question.length > 0) {
            UILabel *questionLbl = [[UILabel alloc] init];
            [questionLbl setFont:aFont];
            [questionLbl setTextColor:aColor];
            questionLbl.numberOfLines = 0;
            questionLbl.textAlignment = NSTextAlignmentLeft;
            questionLbl.text = question;
            questionLbl.backgroundColor = [UIColor clearColor];
            [questionLbl setUserInteractionEnabled:YES];
            
            UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedOnLink:)];
            [questionLbl addGestureRecognizer:gesture];
            
            contentSize = [self getContentSize:question font:aFont];
            questionLbl.frame = CGRectMake(0, previousContentBottomPos,contentSize.width,contentSize.height);
            questionLbl.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            [self addSubview:questionLbl];
            
            //分割线
            CALayer *sepLayer = [CALayer layer];
            sepLayer.frame = CGRectMake(0, previousContentBottomPos + contentSize.height, QUESTION_WIDTH, 0.5);
            sepLayer.backgroundColor = [[NFBAppearanceProxy sharedAppearance] autoReplySepColor].CGColor;
            [self.layer addSublayer:sepLayer];
            [sepLineArray addObject:sepLayer];
            
            [questionsLblsArray addObject:questionLbl];
            [tapGesturesArray addObject:gesture];
            previousContentBottomPos += (contentSize.height + verticalOffset);
        }
    }
}
-(void)userTappedOnLink:(UIGestureRecognizer *)recognizer{
    NSUInteger index = [tapGesturesArray indexOfObject:recognizer];
    if( index != NSNotFound){
        [self.delegate autoReplyQuestionsView:self selectQuestion:index];
    }
}
@end
