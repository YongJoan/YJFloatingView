//
//  YJFloatingView.m
//  ThreadSafeTest
//
//  Created by YangJun on 2026/11/18.
//

#import "YJFloatingView.h"
@interface YJFloatingView ()
@property (nonatomic, assign) CGPoint dragStartPoint; // 记录开始拖拽时的中心点
@end
@implementation YJFloatingView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}
#pragma mark - Setup UI
- (void)setupUI {
    // 1. 设置整体容器大小 (CSS: width 129, height 81)
    self.frame = CGRectMake(0, 0, 129, 81);
    
    // 2. 背景透明，因为阴影需要透出来，且顶部按钮区域通常无背景
    self.backgroundColor = [UIColor clearColor];
    
    // -------------------------------------------------------------
    // 3. 内部内容视图 (Content View) - 用于承载红色条和文字
    // 这个视图负责“裁剪”出圆角效果，确保红色背景不会超出白色卡片的圆角
    // -------------------------------------------------------------
    UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.clipsToBounds = YES; // 开启裁剪，配合下面的 cornerRadius
    contentView.layer.borderWidth = 1;
    contentView.layer.cornerRadius = 9; // 比外层小一点，留出边框空间 (20 - 2 = 18)
    contentView.layer.borderColor = [UIColor colorWithRed:1.0 green:0.15 blue:0.0 alpha:1.0].CGColor; // #FF2800

    [self addSubview:contentView];
    
    UIView *shadowView = [[UIView alloc] init];
    shadowView.backgroundColor = [UIColor clearColor];
    // 【关键】处理阴影
    // 阴影必须加在没有裁剪的视图上
    shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    shadowView.layer.shadowOpacity = 0.12;
    shadowView.layer.shadowOffset = CGSizeMake(0, 6);
    shadowView.layer.shadowRadius = 6;
    shadowView.layer.masksToBounds = NO; // 允许阴影溢出
    shadowView.layer.cornerRadius = 9;
    [self insertSubview:shadowView belowSubview:contentView];
    // 【关键】处理边框 (Border)
    // 边框通常也需要跟随圆角，所以我们在下面的 mask 处理完后，
    
    // -------------------------------------------------------------
    // 4. 添加红色积分条 (Red Bar)
    // 现在它放在 contentView 里，会被自动裁剪成圆角，且能铺满宽度
    // -------------------------------------------------------------
    UIView *redBar = [[UIView alloc] init];
    redBar.backgroundColor = [UIColor colorWithRed:1.0 green:0.15 blue:0.0 alpha:1.0]; // #FF2800
    // 不需要再设 cornerRadius，因为父视图 contentView 已经裁剪了顶部圆角
    [contentView addSubview:redBar];
    
    UILabel *redLabel = [[UILabel alloc] init];
    redLabel.text = @"🌟 积分可抵2.5%";
    redLabel.textColor = [UIColor whiteColor];
    redLabel.font = [UIFont boldSystemFontOfSize:14];
    [redBar addSubview:redLabel];
    
    // -------------------------------------------------------------
    // 5. 底部预估价格行
    // -------------------------------------------------------------
    UILabel *priceLabel = [[UILabel alloc] init];
    priceLabel.text = @"预估抵 ¥25";
    priceLabel.textColor = [UIColor darkGrayColor];
    priceLabel.font = [UIFont systemFontOfSize:14];
    [contentView addSubview:priceLabel];
    
    UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"chevron.right"]];
    arrow.tintColor = [UIColor grayColor];
    [contentView addSubview:arrow];
    
    // -------------------------------------------------------------
    // 6. 关闭按钮 (Close Button)
    // 放在最顶层，不受卡片裁剪影响
    // -------------------------------------------------------------
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [closeBtn setTitle:@"×" forState:UIControlStateNormal];
    closeBtn.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightBold];
    closeBtn.backgroundColor = [UIColor lightGrayColor];
    closeBtn.layer.cornerRadius = 10;
    closeBtn.clipsToBounds = YES;
    [closeBtn addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeBtn];
    
    // -------------------------------------------------------------
    // 7. Auto Layout 约束
    // -------------------------------------------------------------
    shadowView.translatesAutoresizingMaskIntoConstraints = NO;
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    redBar.translatesAutoresizingMaskIntoConstraints = NO;
    redLabel.translatesAutoresizingMaskIntoConstraints = NO;
    priceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    arrow.translatesAutoresizingMaskIntoConstraints = NO;
    closeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSMutableArray *constraints = [NSMutableArray array];
    // A. contentView View (主白底框)
    [constraints addObject:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:54]];
    
    // 紧贴 shadowView 边缘，但考虑到 borderWidth=2，我们可以稍微 inset 或者让它覆盖整个 cardView
    // 这里为了让红色条完美贴合圆角，contentView 应该填满 cardView
    [constraints addObject:[NSLayoutConstraint constraintWithItem:shadowView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:shadowView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:shadowView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:shadowView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    
    // C. Red Bar (红色条 - 铺满宽度)
    [constraints addObject:[NSLayoutConstraint constraintWithItem:redBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:redBar attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:redBar attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:redBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:25]];
    
    // D. Red Label
    [constraints addObject:[NSLayoutConstraint constraintWithItem:redLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:redBar attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:redLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:redBar attribute:NSLayoutAttributeLeading multiplier:1 constant:5]];
    
    // E. Price & Arrow (底部区域)
    [constraints addObject:[NSLayoutConstraint constraintWithItem:priceLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:5]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:priceLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-8]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:arrow attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-8]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:arrow attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:priceLabel attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:arrow attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:8]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:arrow attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:8]];
    
    // F. Close Button
    [constraints addObject:[NSLayoutConstraint constraintWithItem:closeBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:closeBtn attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:closeBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:20]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:closeBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:20]];
    
    [NSLayoutConstraint activateConstraints:constraints];
    
    
    // 7. 添加拖拽手势
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:panGesture];
}

#pragma mark - Gesture Handling
- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.dragStartPoint = self.center;
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gesture translationInView:self.superview];
        self.center = CGPointMake(self.dragStartPoint.x + translation.x,
                                  self.dragStartPoint.y + translation.y);
    } else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        [self snapBackToScreenIfNeeded];
    }
}

#pragma mark - Logic: Snap Back
- (void)snapBackToScreenIfNeeded {
    UIView *parentView = self.superview;
    if (!parentView) return;
    
    CGRect parentBounds = parentView.bounds;
    CGFloat viewWidth = self.bounds.size.width;
    CGFloat viewHeight = self.bounds.size.height;
    
    CGPoint newCenter = self.center;
    BOOL needsAnimation = NO;
    
    // 定义边距（防止完全贴边，看起来更美观，可根据需求设为0）
    CGFloat margin = 10;
    
    // 1. 检查左边界
    if (newCenter.x - viewWidth / 2 < margin) {
        newCenter.x = viewWidth / 2 + margin;
        needsAnimation = YES;
    }
    // 2. 检查右边界
    else if (newCenter.x + viewWidth / 2 > parentBounds.size.width - margin) {
        newCenter.x = parentBounds.size.width - viewWidth / 2 - margin;
        needsAnimation = YES;
    }
    
    // 3. 检查上边界
    if (newCenter.y - viewHeight / 2 < margin) {
        newCenter.y = viewHeight / 2 + margin;
        needsAnimation = YES;
    }
    // 4. 检查下边界
    else if (newCenter.y + viewHeight / 2 > parentBounds.size.height - margin) {
        newCenter.y = parentBounds.size.height - viewHeight / 2 - margin;
        needsAnimation = YES;
    }
    
    if (needsAnimation) {
        // 执行回弹动画
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
            self.center = newCenter;
        } completion:nil];
    }
}

- (void)closeAction {
    // 点击关闭按钮移除视图
    [self removeFromSuperview];
}
@end
