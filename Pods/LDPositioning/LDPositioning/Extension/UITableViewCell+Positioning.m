//
//  UITableViewCell+Positioning.m
//  NeteaseLottery
//
//  Created by Lome on 16/5/6.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "UITableViewCell+Positioning.h"

@implementation UITableViewCell (Positioning)

- (nullable UITableView *)ldp_manageTableView
{
    UIView *tableView = self.superview;
    
    while (![tableView isKindOfClass:[UITableView class]] || !tableView.superview) {
        tableView = tableView.superview;
    }
    
    return (UITableView *)tableView;
}

@end
