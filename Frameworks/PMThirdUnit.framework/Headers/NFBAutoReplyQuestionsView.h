//
//  AutoReplyQuestionsView.h
//  NeteaseLottery
//
//  Created by bjzhangyuan on 13-12-18.
//  Copyright (c) 2013年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NFBAutoReplyQuestionsView;

@protocol NFBAutoReplyQuestionsViewDelegate <NSObject>
- (void)autoReplyQuestionsView:(NFBAutoReplyQuestionsView*)questionView selectQuestion:(NSUInteger)index;
@end

@interface NFBAutoReplyQuestionsView : UIView
@property(nonatomic,weak) id<NFBAutoReplyQuestionsViewDelegate> delegate;
+ (CGSize)sizeForContent:(NSArray*)questionArray font:(UIFont*)font;
-(void)setContent:(NSArray*)questionsArray font:(UIFont*)aFont color:(UIColor*)aColor;
@end
