//
//  UICollectionViewCell+Positioning.m
//  Pods
//
//  Created by wuxu on 16/5/13.
//
//

#import "UICollectionViewCell+Positioning.h"

@implementation UICollectionViewCell (Positioning)

- (nullable UICollectionView *)ldp_manageCollectionView
{
    UIView *collectionView = self.superview;
    
    while (![collectionView isKindOfClass:[UICollectionView class]] || !collectionView.superview) {
        collectionView = collectionView.superview;
    }
    
    return (UICollectionView *)collectionView;
}

@end
