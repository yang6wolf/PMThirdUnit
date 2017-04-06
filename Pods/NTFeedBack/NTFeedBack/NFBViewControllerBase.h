//
//  NFBViewControllerBase.h
//  NTFeedBack
//
//  Created by  龙会湖 on 10/31/14.
//  Copyright (c) 2014 netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NFBAppearance.h"

/**
 *  如果想要自定义客服主界面，请从这个类继承
 */
@interface NFBViewControllerBase : UIViewController<UITableViewDataSource,UITableViewDelegate>

/**
 *  包含所有内容View的容器，如果NFBViewController放在一个NavigationController里面，那么containerView==self.view；否则是self.view的subView，包含了UINavigationBar
 */
@property(nonatomic,strong,readonly) UIView *containerView;
@property(nonatomic,strong,readonly) UITableView *tableView;
@property(nonatomic,strong,readonly) UINavigationBar *navigationBar;
@property(nonatomic,strong,readonly) NSArray *messageArray;

@property(nonatomic,copy) NSString *entrance; //客服MM入口，不同的入口显示不同的问答列表。

/**
 *  定制NFBViewController的外观
 *
 *  @param appearance
 */
- (void)setAppearance:(id<NFBAppearance>)appearance;


/**
 *  发送文字消息
 */
- (void)sendTextMessage:(NSString*)textMessage;


/**
 *  调出图片选择界面，如果用户选择并确认，发送图片
 */
- (void)selectAndSendImage;

/**
 *  请子类重写此函数，实现打开url的功能
 *
 *  @param url
 */
- (void)openUrl:(NSString*)url;


/**
 *  子类重写此函数，一般在消息列表被刷新时被调用，比如新消息到达、发送了新消息。
 */
- (void)onMessageArrayReloaded;

@end
