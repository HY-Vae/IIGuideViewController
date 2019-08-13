//
//  IIPopLabel.h
//  IIBrowser
//
//  Created by whatsbug on 2019/7/17.
//  Copyright © 2019 whatsbug. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface IIPopView : UIView

@property(nonatomic, strong) UIColor *color;
@property(nonatomic, strong) NSString *text;

+ (instancetype)viewWithText:(nullable NSString *)text;
- (void)addButton:(UIButton *)button;
- (void)popAtFrame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
