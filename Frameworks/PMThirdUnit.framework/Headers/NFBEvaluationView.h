//
//  NFBEvaluationView.h
//  Pods
//
//  Created by david on 16/4/14.
//
//

#import <UIKit/UIKit.h>

@protocol NFBEvaluationViewDelegate;
@interface NFBEvaluationView : UIView

@property (nonatomic, weak) id<NFBEvaluationViewDelegate> delegate;

- (void)show;

@end

@protocol NFBEvaluationViewDelegate <NSObject>

- (void)viewWillMoveToSuper:(NFBEvaluationView *)evaluationView;

- (void)viewWillRemoveFromSuper:(NFBEvaluationView *)evaluationView;

@end