//
//  IIGuideViewController.m
//  IIBrowser
//
//  Created by whatsbug on 2019/7/15.
//  Copyright © 2019 whatsbug. All rights reserved.
//

#import "IIGuideViewController.h"
#import "IIPopView.h"
#import <AudioToolbox/AudioToolbox.h>

@interface IIGuideViewController ()
@property(nonatomic, weak) id<IIGuideViewControllerDelegate> delegate;
@property(nonatomic, strong) CAShapeLayer *maskLayer;
@property(nonatomic, strong) IIPopView *popView;
@property(nonatomic, assign) NSInteger currentIndex;
@property(nonatomic, strong) UIButton *previousButton;
@property(nonatomic, strong) UIButton *nextButton;
@property(nonatomic, strong) UIButton *skipButton;
@end

@implementation IIGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubviews];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    self.currentIndex = 0;
    
    [self showGuideAtIndex:self.currentIndex];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self.skipButton sizeToFit];
    self.skipButton.frame = CGRectInset(self.skipButton.frame, -15.0, -3.0);
    
    CGRect frame = self.skipButton.frame;
    frame.origin.y = CGRectGetHeight(self.view.bounds) * 0.1;
    CGFloat maxX = CGRectGetMaxX(self.view.bounds);
    if (@available(iOS 11.0, *)) {
        maxX = CGRectGetMaxX(self.view.safeAreaLayoutGuide.layoutFrame);
    }
    frame.origin.x = maxX - frame.size.width - 20.0;
    self.skipButton.frame = frame;
    self.skipButton.layer.cornerRadius = CGRectGetHeight(frame) * 0.5;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    if (CGSizeEqualToSize(self.view.bounds.size, size)) {
        return;
    }
    
    [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        // 屏幕方向变化时
        [self showGuideAtIndex:self.currentIndex];
    }];
}

///MARK: - Privacy
- (void)addSubviews {
    [self.view addSubview:self.popView];
    [self.view addSubview:self.skipButton];
}

- (UIButton *)createButtonWithTitle:(NSString *)title {
    UIButton *button = UIButton.new;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithWhite:0.0 alpha:0.8] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor colorWithWhite:0.0 alpha:0.3] forState:UIControlStateDisabled];
    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
    return button;
}

///MARK: - Public
+ (void)showsInViewController:(UIViewController<IIGuideViewControllerDelegate> *)viewController {
    IIGuideViewController *guideVC = IIGuideViewController.new;
    [guideVC showsInViewController:viewController];
}

- (void)showsInViewController:(UIViewController<IIGuideViewControllerDelegate> *)viewController {
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.delegate = viewController;
    [viewController.presentedViewController dismissViewControllerAnimated:NO completion:nil];
    [viewController presentViewController:self animated:NO completion:nil];
}

- (void)showGuideAtIndex:(NSInteger)index {
    if (index < 0) {
        self.currentIndex = 0;
        return;
    }
    
    NSInteger count = 0;
    if ([self.delegate respondsToSelector:@selector(numberOfGuidesInGuideViewController:)]) {
        count = [self.delegate numberOfGuidesInGuideViewController:self];
    }
    
    if (index >= count) {
        self.popView.text = @"教程结束，不再提醒？";
        self.previousButton.selected = YES;
        self.nextButton.selected = YES;
        [self.maskLayer removeFromSuperlayer];
   
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.popView cache:NO];
        [UIView setAnimationDuration:1.0];
        self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
        [UIView commitAnimations];
        
        return;
    }
    
    self.previousButton.enabled = index != 0;
    
    CGPathRef fromPath = self.maskLayer.path;
    IIGuideItem *item = nil;
    if ([self.delegate respondsToSelector:@selector(guideViewController:itemForGuideAtIndex:)]) {
        item = [self.delegate guideViewController:self itemForGuideAtIndex:index];
    }
    UIBezierPath *visualPath = [UIBezierPath bezierPathWithRoundedRect:item.frame cornerRadius:item.cornerRadius];
    UIBezierPath *toPath = [UIBezierPath bezierPathWithRect:self.view.bounds];
    [toPath appendPath:visualPath];
    
    /// 遮罩的路径
    self.maskLayer.path = toPath.CGPath;
    self.view.layer.mask = self.maskLayer;
    
    /// 开始移动动画
    if (fromPath && toPath) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
        animation.duration = 0.2;
        animation.fromValue = (__bridge id _Nullable)(fromPath);
        animation.toValue = (__bridge id _Nullable)(toPath.CGPath);
        [self.maskLayer addAnimation:animation forKey:nil];
    }
    
    // text
    self.popView.text = item.title;
    [self.popView popAtFrame:item.frame];
}

///MARK: - Control Events
- (void)previousButtonPressed:(UIButton *)button {
    if (button.selected) {
        if ([self.delegate respondsToSelector:@selector(guideViewControllerDidSelectNoLongerRemind:)]) {
            [self.delegate guideViewControllerDidSelectNoLongerRemind:self];
        }
        [self dismissViewControllerAnimated:NO completion:nil];
    } else {
        [self showGuideAtIndex:--self.currentIndex];
    }
}

- (void)nextButtonPressed:(UIButton *)button {
    if (button.selected) {
        if ([self.delegate respondsToSelector:@selector(guideViewControllerDidSelectRemindMe:)]) {
            [self.delegate guideViewControllerDidSelectRemindMe:self];
        }
        [self dismissViewControllerAnimated:NO completion:nil];
    } else {
        [self showGuideAtIndex:++self.currentIndex];
        
        AudioServicesPlaySystemSound(1519);
    }
}

- (void)skipButtonPressed:(UIButton *)button {
    self.nextButton.selected = YES;
    [self nextButtonPressed:self.nextButton];
}

///MARK: - Getter && Setter
- (IIPopView *)popView {
    if (!_popView) {
        IIPopView *popView = [IIPopView viewWithText:nil];
        _popView = popView;
        popView.color = [UIColor colorWithRed:255.0/255.0 green:234.0/255.0 blue:95.0/255.0 alpha:1.0];
        [popView addButton:self.previousButton];
        [popView addButton:self.nextButton];
    }
    return _popView;
}

- (UIButton *)previousButton {
    if (!_previousButton) {
        UIButton *previousButton = [self createButtonWithTitle:@"上一条"];
        _previousButton = previousButton;
        [previousButton setTitle:@"不再提醒" forState:UIControlStateSelected];
        [previousButton addTarget:self action:@selector(previousButtonPressed:) forControlEvents:UIControlEventTouchDown];
    }
    return _previousButton;
}

- (UIButton *)nextButton {
    if (!_nextButton) {
        UIButton *nextButton = [self createButtonWithTitle:@"知道了"];
        _nextButton = nextButton;
        [nextButton setTitle:@"下次提醒" forState:UIControlStateSelected];
        [nextButton addTarget:self action:@selector(nextButtonPressed:) forControlEvents:UIControlEventTouchDown];
    }
    return _nextButton;
}

- (UIButton *)skipButton {
    if (!_skipButton) {
        UIButton *skipButton = [self createButtonWithTitle:@"跳过教程"];
        _skipButton = skipButton;
        skipButton.layer.backgroundColor = self.popView.color.CGColor;
        skipButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f];
        [skipButton addTarget:self action:@selector(skipButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _skipButton;
}

- (CAShapeLayer *)maskLayer {
    if (!_maskLayer) {
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        _maskLayer = maskLayer;
        maskLayer.fillRule = kCAFillRuleEvenOdd;
    }
    return _maskLayer;
}

@end


@implementation IIGuideItem

@end
