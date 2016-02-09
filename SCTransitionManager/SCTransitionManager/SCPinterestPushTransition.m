//
//  SCPinterestPushTransition.m
//  SCTransitionManager
//
//  Created by sichenwang on 16/2/9.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import "SCPinterestPushTransition.h"
#import "UIView+Capture.h"

@implementation SCPinterestPushTransition

- (instancetype)init {
    if (self = [super init]) {
        _duration = 0.3;
    }
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return self.duration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    toViewController.view.alpha = 0;
    [transitionContext.containerView addSubview:toViewController.view];
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    CGRect originFrame = _sourceViewController.view.frame;
    
    UIView *sourceVCSnapshotView = [_sourceViewController.view captureView];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:originFrame];
    backgroundView.backgroundColor = [UIColor colorWithRed:238.0/255.0
                                                     green:238.0/255.0
                                                      blue:238.0/255.0
                                                     alpha:1.0];
    [_sourceViewController.view.superview insertSubview:backgroundView aboveSubview:_sourceViewController.view];
    sourceVCSnapshotView.frame = backgroundView.bounds;
    [backgroundView addSubview:sourceVCSnapshotView];
    
    UIView *animationView = [[UIView alloc] initWithFrame:_sourceViewController.view.frame];
    animationView.backgroundColor = [UIColor clearColor];
    [_sourceViewController.view.superview insertSubview:animationView aboveSubview:backgroundView];
    
    UIView *imageViewSourceVC = [_sourceView captureView];
    CGRect frameInVCView = [_sourceView convertRect:_sourceView.bounds toView:animationView];
    imageViewSourceVC.frame = frameInVCView;
    imageViewSourceVC.contentMode = _sourceView.contentMode;
    [animationView addSubview:imageViewSourceVC];
    
    CGPoint centerobj = [_sourceView convertPoint:CGPointMake(_sourceView.bounds.size.width / 2, _sourceView.bounds.size.height / 2) toView:self.sourceViewController.view];
    
    CGPoint centerOfTargetFrame = CGPointMake(self.targetFrame.origin.x + self.targetFrame.size.width / 2, self.targetFrame.origin.y + self.targetFrame.size.height / 2);
    
    CGFloat deltaXToTargetFrameCenter = centerOfTargetFrame.x - centerobj.x;
    CGFloat deltaYToTargetFrameCenter = centerOfTargetFrame.y - centerobj.y;
    CGRect frame = sourceVCSnapshotView.layer.frame;
    sourceVCSnapshotView.layer.anchorPoint = CGPointMake(centerOfTargetFrame.x / sourceVCSnapshotView.bounds.size.width, centerOfTargetFrame.y / sourceVCSnapshotView.bounds.size.height);
    sourceVCSnapshotView.layer.frame = frame;
    
    [UIView animateWithDuration:self.duration animations:^{
        sourceVCSnapshotView.alpha = 0.0;
        
        CGFloat xScale = self.targetFrame.size.width / _sourceView.bounds.size.width;
        CGFloat yScale = xScale;
        sourceVCSnapshotView.transform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(deltaXToTargetFrameCenter, deltaYToTargetFrameCenter), CGAffineTransformMakeScale(xScale,yScale)) ;
        
        imageViewSourceVC.frame = CGRectMake(self.targetFrame.origin.x, self.targetFrame.origin.y, imageViewSourceVC.frame.size.width * xScale, imageViewSourceVC.frame.size.height * yScale);
        
    } completion:^(BOOL finished) {
        UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        
        [UIView animateWithDuration:0.2 animations:^{
            toViewController.view.alpha = 1;
        } completion:^(BOOL finished) {
            [animationView removeFromSuperview];
            [imageViewSourceVC removeFromSuperview];
            [backgroundView removeFromSuperview];
            [transitionContext completeTransition:YES];
            [[UIApplication sharedApplication ] endIgnoringInteractionEvents];
        }];
    }];
}

@end