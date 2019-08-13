//
//  IIGuideViewController.h
//  IIBrowser
//
//  Created by whatsbug on 2019/7/15.
//  Copyright © 2019 whatsbug. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface IIGuideItem : NSObject
@property(nonatomic, assign) CGRect frame;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, assign) CGFloat cornerRadius;
@end

@class IIGuideViewController;
@protocol IIGuideViewControllerDelegate <NSObject>

- (NSInteger)numberOfGuidesInGuideViewController:(IIGuideViewController *)guideViewController;
- (IIGuideItem *)guideViewController:(IIGuideViewController *)guideViewController itemForGuideAtIndex:(NSUInteger)index;

- (void)guideViewControllerDidSelectRemindMe:(IIGuideViewController *)guideViewController;
- (void)guideViewControllerDidSelectNoLongerRemind:(IIGuideViewController *)guideViewController;

@end

@interface IIGuideViewController : UIViewController

+ (void)showsInViewController:(UIViewController<IIGuideViewControllerDelegate> *)viewController;

- (void)showsInViewController:(UIViewController<IIGuideViewControllerDelegate> *)viewController;

@end

NS_ASSUME_NONNULL_END
