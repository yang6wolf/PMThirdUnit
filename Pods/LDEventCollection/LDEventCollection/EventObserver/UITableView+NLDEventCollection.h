//
//  UITableView+NLDEventCollection.h
//  LDEventCollection
//
//  Created by SongLi on 5/6/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 由tableView对象发出，UserInfo包含"tableView":UITableView,"indexPath":NSIndexPath,"addition":NSDictionary
extern NSString * const NLDNotificationTableViewDidSelectRow;

@interface UITableView (NLDEventCollection)

@end
