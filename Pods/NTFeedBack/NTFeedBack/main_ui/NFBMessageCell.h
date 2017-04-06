//
//  FBMessageCell.h
//  NeteaseLottery
//
//  Created by wangbo on 13-3-21.
//  Copyright (c) 2013年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedBackMessages.h"
#import <UIKit/UIKit.h>


@protocol NFBMessageCellDelegate <NSObject>
- (void)messageCell:(UITableViewCell*)cell didOpenLink:(NSString*)link;
@end

@interface NFBAutoReplyQuestionsCell : UITableViewCell
@property(nonatomic,weak) id<NFBMessageCellDelegate> delegate;
- (void)setWithContent:(NSArray *)questions;
+ (CGSize)sizeForContent:(NSArray *)questions;
@end


@interface NFBMessageCell : UITableViewCell
@property(nonatomic,weak) id<NFBMessageCellDelegate> delegate;
+(CGSize)sizeForMessage:(FeedBackMessages *)message;
-(void)setWithMessage:(FeedBackMessages *)message;
@end
