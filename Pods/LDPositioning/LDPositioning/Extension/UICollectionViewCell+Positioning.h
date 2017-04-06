//
//  UICollectionViewCell+Positioning.h
//  Pods
//
//  Created by wuxu on 16/5/13.
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UICollectionViewCell (Positioning)

/**
 *  获取cell所属的CollectionView
 *
 *  @return UICollectionView 可能为空（eg：当Cell未被加到CollectionView）
 */
- (nullable UICollectionView *)ldp_manageCollectionView;

@end

NS_ASSUME_NONNULL_END
