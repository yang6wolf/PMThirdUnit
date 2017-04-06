//
//  FBViewController.h
//  NeteaseLottery
//
//  Created by wangbo on 13-3-21.
//  Copyright (c) 2013年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NFBViewControllerBase.h"

@protocol NFBViewControllerDelegate <NSObject>

@optional

- (void)NTFeedBackOpenUrlString:(NSString *)urlString;

@end

@interface NFBViewController : NFBViewControllerBase

@property (nonatomic, weak) id<NFBViewControllerDelegate> delegate;

@end
