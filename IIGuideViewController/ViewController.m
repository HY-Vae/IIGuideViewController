//
//  ViewController.m
//  IIGuideViewController
//
//  Created by whatsbug on 2019/8/13.
//  Copyright © 2019 whatsbug. All rights reserved.
//

#import "ViewController.h"
#import "IIGuideViewController.h"

@interface ViewController ()<IIGuideViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *purpleView;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UISwitch *switchView;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UIView *redView;
@end

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![NSUserDefaults.standardUserDefaults boolForKey:@"skipTutorial"]) {
        [IIGuideViewController showsInViewController:self];
    }
}

///MARK: - IIGuideViewControllerDelegate
- (IIGuideItem *)guideViewController:(IIGuideViewController *)guideViewController itemForGuideAtIndex:(NSUInteger)index {
    CGRect frame = CGRectZero;
    CGFloat cornerRadius = 0.0;
    IIGuideItem *item = self.guideItems[index];
    if (index == 0) {
        frame = self.purpleView.frame;
        cornerRadius = 10.0;
    } else if (index == 1) {
        frame = self.slider.frame;
        cornerRadius = CGRectGetHeight(frame) * 0.5;
    } else if (index == 2) {
        CGFloat x = CGRectGetMaxX(self.purpleView.frame) + 150;
        CGFloat y = CGRectGetMidY(self.purpleView.frame) + 50;
        frame = CGRectMake(x, y, 100, 40);
        cornerRadius = 20.0;
    } else if (index == 3) {
        frame = self.switchView.frame;
        cornerRadius = CGRectGetHeight(frame) * 0.5;
    } else if (index == 4) {
        UIView *view = self.button;
        CGRect tmpFrame = [view.superview convertRect:view.frame toView:view.window];
        frame = CGRectInset(tmpFrame, -15.0, -3.0);
        cornerRadius = CGRectGetHeight(frame) * 0.5;
    } else if (index == 5) {
        frame = self.redView.frame;
        cornerRadius = CGRectGetHeight(frame) * 0.5;
    }
    
    item.frame = frame;
    item.cornerRadius = cornerRadius;
    return item;
}

- (void)guideViewControllerDidSelectNoLongerRemind:(IIGuideViewController *)guideViewController {
    //[NSUserDefaults.standardUserDefaults setBool:YES forKey:@"skipTutorial"];
}

- (void)guideViewControllerDidSelectRemindMe:(IIGuideViewController *)guideViewController {
    //[J2NotificationView showWithStatus:@"下次进入App重新提醒"];
}

- (NSInteger)numberOfGuidesInGuideViewController:(IIGuideViewController *)guideViewController {
    return self.guideItems.count;
}

- (NSArray *)guideItems {
    IIGuideItem *item0 = IIGuideItem.new;
    item0.title = @"紫色紫色紫色紫色紫色紫色";
    
    IIGuideItem *item1 = IIGuideItem.new;
    item1.title = @"进度条进度条进度条";
    
    IIGuideItem *item2 = IIGuideItem.new;
    item2.title = @"没有东西没有东西没有东西";
    
    IIGuideItem *item3 = IIGuideItem.new;
    item3.title = @"哇哇哇哇哇哇哇";
    
    IIGuideItem *item4 = IIGuideItem.new;
    item4.title = @"哪吒哪吒哪吒";
    
    IIGuideItem *item5 = IIGuideItem.new;
    item5.title = @"企鹅企鹅企鹅企鹅企鹅";
    
    return @[item0, item1, item2, item3, item4, item5];
}

@end
