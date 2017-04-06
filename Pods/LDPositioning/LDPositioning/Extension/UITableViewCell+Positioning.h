//
//  UITableViewCell+Positioning.h
//  NeteaseLottery
//
//  Created by Lome on 16/5/6.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITableViewCell (Positioning)

/**
 *  获取cell所属的TableView
 *
 *  @return UITableView 可能为空（eg：当Cell未被加到TableView）
 */
- (nullable UITableView *)ldp_manageTableView;

@end

NS_ASSUME_NONNULL_END
