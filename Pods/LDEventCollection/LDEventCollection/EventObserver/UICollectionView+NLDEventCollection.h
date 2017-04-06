//
//  UICollectionView+NLDEventCollection.h
//  LDEventCollection
//
//  Created by SongLi on 5/17/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 由collectionView对象发出，UserInfo包含"collectionView":UICollectionView,"indexPath":NSIndexPath,"addition":NSDictionary
extern NSString * const NLDNotificationCollectionViewDidSelectIndexPath;

@interface UICollectionView (NLDEventCollection)

@end
