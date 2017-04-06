//
//  MMHeaderView.m
//  NeteaseLottery
//
//  Created by bjzhangyuan on 13-12-18.
//  Copyright (c) 2013年 netease. All rights reserved.
//

#import "NFBMMHeaderView.h"
#import "NFBAutoReply.h"
#import "NFBAppearanceProxy.h"
#import "NFBNotifications.h"
#import "NFBUtil.h"

#define NOTICE_CONTENT_SIZE CGSizeMake(SCREEN_WIDTH - 90, 80)
#define NOTICE_NORMAL_HEIGHT 60

@interface NFBMMHeaderView ()

@end

@implementation NFBMMHeaderView{
    UIImageView* bgView;
    UIImageView* avatarView;
    
    UILabel *noticeLbl;
    UIFont *font;
    UIColor *fontColor;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        bgView = [[UIImageView alloc] initWithImage:[[NFBAppearanceProxy sharedAppearance] headerOnlineBackgroundImage]];
        bgView.frame = CGRectMake(0, 0, frame.size.width, MM_HEADER_HEIGHT);
        [self addSubview:bgView];
        
        avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 60, 60)];
        avatarView.layer.cornerRadius = [[NFBAppearanceProxy sharedAppearance] avatarCornerRadiusPersent] * avatarView.frame.size.width;
        avatarView.clipsToBounds = YES;
        [self addSubview:avatarView];
        
        font = [UIFont systemFontOfSize:13];
        fontColor = [UIColor colorWithRed:0.125f green:0.125f blue:0.124f alpha:1.0f];
        noticeLbl = [[UILabel alloc] initWithFrame:CGRectMake(80, 5, NOTICE_CONTENT_SIZE.width,NOTICE_NORMAL_HEIGHT)];
        noticeLbl.backgroundColor = [UIColor clearColor];
        noticeLbl.font = font;
        noticeLbl.textColor = fontColor;
        noticeLbl.textAlignment = NSTextAlignmentLeft;
        noticeLbl.lineBreakMode = NSLineBreakByWordWrapping;
        noticeLbl.numberOfLines = 0;
        [bgView addSubview:noticeLbl];
        
        [self updateContent];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateContent) name:NFBAutoReplySessionDidRefreshed object:nil];
        
    }
    return self;
}

-(void)updateContent {//content contains on/offline notice and  operation message
    
    BOOL onLine = [[NFBAutoReplySession sharedSession] isOnline];
    if(onLine){
        bgView.image = [[NFBAppearanceProxy sharedAppearance] headerOnlineBackgroundImage];
        avatarView.image = [[NFBAppearanceProxy sharedAppearance] headerOnlineImage];
    }else{
        bgView.image = [[NFBAppearanceProxy sharedAppearance] headerOfflineBackgroundImage];
        avatarView.image = [[NFBAppearanceProxy sharedAppearance] headerOfflineImage];
    }
    
    NSString* content = [[NFBAutoReplySession sharedSession] floatMessage];
    CGSize size = [NFBUtil drawSizeOfString:content withFont:font constrainedToSize:NOTICE_CONTENT_SIZE];
    if(size.height > NOTICE_NORMAL_HEIGHT){
        noticeLbl.frame = CGRectMake(noticeLbl.frame.origin.x, (MM_HEADER_HEIGHT - NOTICE_CONTENT_SIZE.height)/2, NOTICE_CONTENT_SIZE.width, NOTICE_CONTENT_SIZE.height);
    }
    noticeLbl.text = content;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
