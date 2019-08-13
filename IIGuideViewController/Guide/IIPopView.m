//
//  IIPopLabel.m
//  IIBrowser
//
//  Created by whatsbug on 2019/7/17.
//  Copyright © 2019 whatsbug. All rights reserved.
//

#import "IIPopView.h"

@interface IIPopView ()
@property(nonatomic, strong) UILabel *label;
@property(nonatomic, assign) BOOL isArrowAtTop;
@property(nonatomic, strong) UIView *arrowView;
@property(nonatomic, assign) CGFloat arrowX;
@property(nonatomic, strong) NSMutableArray *buttons;
@end

@implementation IIPopView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.color = UIColor.orangeColor;
        self.buttons = NSMutableArray.new;
        [self addSubview:self.label];
        [self addSubview:self.arrowView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.buttons.count == 0) {
        self.label.frame = CGRectInset(self.bounds, IIPopView.textPadding, 0.0);
        return;
    }
    
    CGFloat padding = IIPopView.padding;
    CGFloat buttonHeight = IIPopView.buttonHeight;
    CGRect slice, remainder;
    CGRectDivide(CGRectInset(self.bounds, 0, padding), &slice, &remainder, buttonHeight, CGRectMaxYEdge);
    self.label.frame = CGRectInset(remainder, IIPopView.textPadding, 0.0);
    
    NSInteger index = 0;
    CGFloat buttonWidth = CGRectGetWidth(slice) / self.buttons.count;
    for (UIButton *button in self.buttons) {
        button.tag = index;
        button.frame = CGRectMake(index * buttonWidth, CGRectGetMinY(slice) - 8, buttonWidth, buttonHeight);
        index ++;
    }
}

- (void)drawRect:(CGRect)rect {
    // background drawing
    CGFloat padding = IIPopView.padding;
    CGRect backgroundRect = CGRectInset(rect, 0.0, padding);
    UIBezierPath *backgroundPath = [UIBezierPath bezierPathWithRoundedRect:backgroundRect cornerRadius:8.0];
    [self.color setFill];
    [backgroundPath fill];
    
    // arrowView
    self.arrowView.backgroundColor = self.color;
}

///MARK: - Privacy
- (void)addButton:(UIButton *)button {
    [self.buttons addObject:button];
    [self addSubview:button];
}

- (void)layoutArrowViewWithRect:(CGRect)rect {
    CGFloat padding = IIPopView.padding;
    CGFloat viewX = self.arrowX;
    CGFloat viewY = self.isArrowAtTop ? padding : rect.size.height - padding;
    self.arrowView.center = CGPointMake(viewX, viewY);
    
    if (CGAffineTransformIsIdentity(self.arrowView.transform)) {
        self.arrowView.transform = CGAffineTransformMakeRotation(M_PI_4);
    }
}

+ (CGFloat)padding {
    return 8.0;
}

+ (CGFloat)textPadding {
    return 18.0;
}

+ (CGFloat)buttonHeight {
    return 24.0;
}

///MARK: - Public
+ (instancetype)viewWithText:(NSString *)text {
    IIPopView *popLabel = [[self alloc] initWithFrame:CGRectZero];
    popLabel.label.text = text ?: @"";
    return popLabel;
}

- (void)popAtFrame:(CGRect)frame {
    CGFloat frameMidY = CGRectGetMidY(frame);
    CGFloat superviewMidY = CGRectGetMidY(self.superview.bounds);
    self.isArrowAtTop = frameMidY < superviewMidY;
    
    CGFloat maxWidth = CGRectGetWidth(self.superview.bounds) * 0.8;
    NSDictionary *attributes = @{NSFontAttributeName: self.label.font};
    CGSize textSize = [self.label.text boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    
    CGFloat offset = 30.0;
    CGFloat viewW = MAX(textSize.width + IIPopView.textPadding * 2.0, 180);
    CGFloat viewH = textSize.height + 72.0 + (self.buttons.count > 0 ? IIPopView.buttonHeight : 0.0);
    CGFloat viewY = self.isArrowAtTop ? CGRectGetMaxY(frame) + offset : CGRectGetMinY(frame) - offset - viewH;
    // frame的中心点在其坐标系的比例决定箭头的位置
    self.arrowX = CGRectGetMidX(frame) / CGRectGetWidth(self.superview.bounds) * viewW;
    CGFloat viewX = CGRectGetMidX(frame) - self.arrowX;
    CGRect viewFrame = CGRectMake(viewX, viewY, viewW, viewH);
    
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = viewFrame;
        [self layoutArrowViewWithRect:viewFrame];
    }];

    [self setNeedsDisplay];
}

///MARK: - Getter && Setter
- (UILabel *)label {
    if (!_label) {
        UILabel *label = UILabel.new;
        _label = label;
        label.textColor = UIColor.blackColor;
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f];
    }
    return _label;
}

- (UIView *)arrowView {
    if (!_arrowView) {
        UIView *arrowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
        _arrowView = arrowView;
    }
    return _arrowView;
}

- (void)setText:(NSString *)text {
    self.label.text = text;
}

- (NSString *)text {
    return self.label.text;
}

@end
