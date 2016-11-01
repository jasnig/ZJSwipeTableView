//
//  ZJSwipeTableViewCell.m
//  ZJSwipTableView
//
//  Created by ZeroJ on 16/10/12.
//  Copyright © 2016年 ZeroJ. All rights reserved.
//

#import "ZJSwipeTableViewCell.h"
#import "UIView+Frame.h"

// 滑动操作的类型
typedef NS_ENUM(NSUInteger, ZJSwipeOperation) {
    ZJSwipeOperationNone,
    ZJSwipeOperationOpenLeft,
    ZJSwipeOperationCloseLeft,
    ZJSwipeOperationOpenRight,
    ZJSwipeOperationCloseRight
};


static char ZJSwipeCellContext;

static NSString *const ZJSwipeCellTableViewGesturePath = @"tableView.panGestureRecognizer.state";

@interface ZJSwipeTableViewCell ()<UIGestureRecognizerDelegate> {
    // 记录手势开始的时候`overlayerContentView`的x
    CGFloat _beginContentViewX;
    // 记录手势开始的时候`snapView`的x
    CGFloat _beginSnapViewX;
    // 记录手势开始的时候手指的位置, 便于处理手指松开的时候判断滑动了多远,是否完成滑动
    CGFloat _beginX;
}
// cell的截图
@property (strong, nonatomic) UIView *snapView;
// 所有添加的subviews的容器, 滑动时覆盖在cell上
@property (nonatomic, strong) UIView *overlayerContentView;
// 右边的滑动菜单
@property (nonatomic, strong) ZJSwipeView *rightView;
// 左边的滑动菜单
@property (nonatomic, strong) ZJSwipeView *leftView;

//手势
@property (strong, nonatomic) UIPanGestureRecognizer *panGesture;
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;
// cell所在的tableView  weak!
@property (weak, nonatomic) UITableView *tableView;
// 记录cell的选中style 便于复原
@property (assign, nonatomic) UITableViewCellSelectionStyle reallySelectionStyle;
// 滑动的操作
@property (assign, nonatomic) ZJSwipeOperation swipeOperation;

// 用于不同动画类型的时候设置相应的比例
@property (assign, nonatomic) CGFloat animatedTypePercent;

@end

@implementation ZJSwipeTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self commonInit];
    
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self commonInit];
    
}

- (void)commonInit {
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    self.panGesture.delegate = self;
    [self addGestureRecognizer:self.panGesture];
    _closeOtherCellSwipeViewWhenOpenSwipeView = YES;
    _reallySelectionStyle = self.selectionStyle;
    _swipeViewAnimatedStyle = ZJSwipeViewAnimatedStyleDefault;
    _overlayerBackgroundColor = [UIColor whiteColor];
    _threholdPercent = 0.5;
    _animatedDuration = 0.25;
    _threholdSpeed = 200.f;
}


- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    CGFloat locationX = [panGesture locationInView:self].x;
    CGFloat transitionX = [panGesture translationInView:self].x;
    CGFloat velocityX = [panGesture velocityInView:self].x;

    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan: {
            // 设置左右侧滑菜单和截图
            [self setupSwipeViewWithSwipeVelocityX:velocityX];
            // 记录初始数据
            _beginX = locationX;
            _beginSnapViewX = self.snapView.zj_x;
            _beginContentViewX = self.overlayerContentView.zj_x;
            self.swipeOperation = ZJSwipeOperationNone;

        }
            break;
        case UIGestureRecognizerStateChanged: {
            // 始终同步滚动 snapView
            CGFloat tempSnapViewX = _beginSnapViewX;
            tempSnapViewX += transitionX;
            self.snapView.zj_x = tempSnapViewX;
            
            // 向右滑动说明是 打开左边 或者关闭右边
            if (transitionX>0) {
                // 右边菜单存在, 并且开始滑动时截图的x = 右边菜单宽度的负值
                // 说明这次手势开始的时候右边的菜单是打开的, 正在关闭右边的菜单
                if (self.rightView && _beginSnapViewX == -self.rightView.zj_width) {
                    // 记录为正在关闭右边菜单, 便于在手指离开的时候判断
                    self.swipeOperation = ZJSwipeOperationCloseRight;
                    // 影藏左边菜单 显示右边菜单
                    [self hideAndShowSwipeViewNeededWithShowleft:NO];
                    // 手指向右移动的距离 >= 右边菜单的宽度, 说明右边菜单已经完全关闭
                    // 手指再继续右移就变成了打开左边菜单的操作了, 这个时候就要
                    // 将各个变量设置为打开左边菜单的初始值
                    if (transitionX>=self.rightView.zj_width) {
                        // 右边关闭完成 --- 变为打开左边
                        // 手势设置移动为0
                        [panGesture setTranslation:CGPointZero inView:self];
                        // 重置开始X
                        _beginContentViewX = -self.leftView.zj_width*self.animatedTypePercent;
                        _beginX = locationX;
                        _beginSnapViewX = 0;
                        self.overlayerContentView.zj_x = -self.leftView.zj_width*self.animatedTypePercent;
                    }
                    else {
                        // 正在关闭右边 改变overlayerContentView的x
                        CGFloat tempX = _beginContentViewX;
                        tempX += transitionX*self.animatedTypePercent;
                        self.overlayerContentView.zj_x = tempX;
                    }
                    // 这是我们模仿简书的打开和关闭的时候的动画效果进行的frame计算, 需要一点数学能力
                    [self animateSwipeButtonsWithPercent:transitionX/self.rightView.zj_width];

                }
                else {
                    self.swipeOperation = ZJSwipeOperationOpenLeft;
                    if (!self.leftView) return;
                    [self hideAndShowSwipeViewNeededWithShowleft:YES];

                    if (_beginContentViewX == 0) { // 左边完全打开的情况下右滑 固定 transitionX
                        transitionX = self.leftView.zj_width;
                    }
                    else {
                        
                        if (transitionX>=self.leftView.zj_width) {
                            self.overlayerContentView.zj_x = 0.f; //固定contentView
                            transitionX = self.leftView.zj_width;
                        }
                        else {

                            // 滚动overLayerContentView
                            CGFloat tempX = _beginContentViewX;
                            tempX += transitionX*self.animatedTypePercent;
                            self.overlayerContentView.zj_x = tempX;
                        }
                        
                    }
                    
                    [self animateSwipeButtonsWithPercent:transitionX/self.leftView.zj_width];

                }
            }
            if (transitionX<0) {// 关闭左边或者打开右边
                
                if (self.leftView && _beginSnapViewX == self.leftView.zj_width) { //左边是打开的
                    self.swipeOperation = ZJSwipeOperationCloseLeft;
                    [self hideAndShowSwipeViewNeededWithShowleft:YES];

                    // 关闭左边
                    if (transitionX<=-self.leftView.zj_width) {
                        // 左边关闭完成
                        // 手势设置移动为0
                        [panGesture setTranslation:CGPointZero inView:self];
                        _beginContentViewX = -self.leftView.zj_width*self.animatedTypePercent;
                        _beginX = locationX;
                        _beginSnapViewX = 0;
                        transitionX = -self.leftView.zj_width;
                        self.overlayerContentView.zj_x = -self.leftView.zj_width*self.animatedTypePercent;
                    }
                    else {
                        // 正在关闭左边
                        CGFloat tempX = _beginContentViewX;
                        tempX += transitionX*self.animatedTypePercent;
                        self.overlayerContentView.zj_x = tempX;
                    }
                    
                    [self animateSwipeButtonsWithPercent:-transitionX/self.leftView.zj_width];

                }
                else {
                    self.swipeOperation = ZJSwipeOperationOpenRight;
                    if (!self.rightView) return;
                    [self hideAndShowSwipeViewNeededWithShowleft:NO];

                    // 打开右边
                    if (_beginSnapViewX == -self.rightView.zj_width) { // 右边完全打开的情况下右滑 --
                        transitionX = -self.rightView.zj_width;
                    }
                    else {
                        if (transitionX<=-self.rightView.zj_width) {
                            // 打开右边完成
                            self.overlayerContentView.zj_x = _beginContentViewX-self.rightView.zj_width*self.animatedTypePercent; //固定contentView
                            transitionX = -self.rightView.zj_width;

                        }
                        else {
                            CGFloat tempX = _beginContentViewX;
                            tempX += transitionX*self.animatedTypePercent;
                            self.overlayerContentView.zj_x = tempX;
                        }
                        
                    }
                    [self animateSwipeButtonsWithPercent:-transitionX/self.rightView.zj_width];

                }

            }
        }
            break;
        case UIGestureRecognizerStateEnded: {
            CGFloat velocityX = [panGesture velocityInView:self].x;
            [self handleFinishOrCancelWithVelocityX:velocityX andLocationX:locationX];
        }
            
            break;
        default:
            break;
    }
}

- (void)handleFinishOrCancelWithVelocityX:(CGFloat)velocityX andLocationX:(CGFloat)locationX {
    
    if (self.swipeOperation == ZJSwipeOperationOpenLeft) {
        
        if (fabs(_beginX - locationX) > self.leftView.zj_width*self.threholdPercent) {
            [self animatedOpenLeft];
        }
        else {
            //判断离开的速度
            if (fabs(velocityX) > _threholdSpeed)
                [self animatedOpenLeft];
            else
                [self animatedCloseLeft];
        }
        
    }
    else if (self.swipeOperation == ZJSwipeOperationCloseLeft) {
        if (fabs(_beginX - locationX) > self.leftView.zj_width*self.threholdPercent) {
            [self animatedCloseLeft];
        }
        else {
            if (fabs(velocityX) > _threholdSpeed) [self animatedCloseLeft];
            else [self animatedOpenLeft];
            
        }
    }
    else if (self.swipeOperation == ZJSwipeOperationOpenRight) {
        if (fabs(_beginX - locationX) > self.rightView.zj_width*self.threholdPercent) {
            [self animatedOpenRight];
        }
        else {
            if (fabs(velocityX) > _threholdSpeed) [self animatedOpenRight];
            else [self animatedCloseRight];
        }
    }
    else if (self.swipeOperation == ZJSwipeOperationCloseRight) {
        // 如果手指移动的距离 > 我们定义的百分比 说明应该执行动画关闭右边菜单
        if (fabs(_beginX - locationX) > self.rightView.zj_width*self.threholdPercent) {
            [self animatedCloseRight];
        }
        else {
            // 如果手指移动的距离较小, 就判断手指离开的速度是否大于我们定义的最小速度
            // 如果大于证明应该执行动画关闭右边菜单, 否则说明关闭右边失败, 重新打开 右边菜单
            if (fabs(velocityX) > _threholdSpeed)
                [self animatedCloseRight];
            else
                [self animatedOpenRight];
            
        }
    }
}

- (void)resetInitialState {
    // 移除kvo监听者
    [self removeTableViewObserver];
    // 移除tap手势
    [self.tableView removeGestureRecognizer:self.tapGesture];
    // 移除添加的view
    self.snapView = nil;
    [self.overlayerContentView removeFromSuperview];
    self.overlayerContentView = nil;
    self.leftView = nil;
    self.rightView = nil;
    self.tapGesture = nil;
    self.selectionStyle = self.reallySelectionStyle;

}

- (void)animateSwipeButtonsWithPercent:(CGFloat)percent {
    if (_swipeViewAnimatedStyle != ZJSwipeViewAnimatedStyleOverlap) {
        return;
    }
//    NSLog(@"%f", percent);
    CGFloat x=0;

    if (self.swipeOperation == ZJSwipeOperationOpenLeft) {
        for (ZJSwipeButton *swipeBtn in [self.leftView.subviews reverseObjectEnumerator]) {
            swipeBtn.zj_x = (self.leftView.zj_width - swipeBtn.zj_width - x) * (1.0 - percent) + x;
            x += swipeBtn.zj_width;
        }
    }
    else if (self.swipeOperation == ZJSwipeOperationCloseLeft) {
        for (ZJSwipeButton *swipeBtn in [self.leftView.subviews reverseObjectEnumerator]) {
            swipeBtn.zj_x = (self.leftView.zj_width - swipeBtn.zj_width - x) * percent + x;
            x += swipeBtn.zj_width;
        }
        
    }

    else if (self.swipeOperation == ZJSwipeOperationOpenRight) {
        for (ZJSwipeButton *swipeBtn in self.rightView.subviews) {
            swipeBtn.zj_x = x*percent;
            x += swipeBtn.zj_width;
        }

    }
    else if (self.swipeOperation == ZJSwipeOperationCloseRight) {
        
        for (ZJSwipeButton *swipeBtn in self.rightView.subviews) {
            swipeBtn.zj_x = x*(1-percent);
            x += swipeBtn.zj_width;
        }
    }
}

- (void)animatedOpenLeft {
    [UIView animateWithDuration:_animatedDuration animations:^{
        // 设置cell截图在左边打开时的最终位置
        self.snapView.zj_x = self.leftView.zj_width;
        // 设置左右菜单的容器view在左边打开时的最终位置
        self.overlayerContentView.zj_x = 0;
        if (_swipeViewAnimatedStyle == ZJSwipeViewAnimatedStyleOverlap) {
            // 设置每个按钮的最终位置
            CGFloat x=0;
            for (ZJSwipeButton *swipeBtn in [self.leftView.subviews reverseObjectEnumerator]) {
                
                swipeBtn.zj_x = x;
                x += swipeBtn.zj_width;
            }

        }


    } completion:nil];
}

- (void)animatedCloseLeft {

    [UIView animateWithDuration:_animatedDuration animations:^{
        // 设置cell截图在左边关闭时的最终位置
        self.snapView.zj_x = 0;
        // 设置左右菜单的容器view在左边关闭时的最终位置
        self.overlayerContentView.zj_x = -self.leftView.zj_width*self.animatedTypePercent;
        
        if (_swipeViewAnimatedStyle == ZJSwipeViewAnimatedStyleOverlap) {
            // 设置每个按钮的最终位置
            for (ZJSwipeButton *swipeBtn in [self.leftView.subviews reverseObjectEnumerator]) {
                swipeBtn.zj_x = self.leftView.zj_width-swipeBtn.zj_width;
            }

        }
    } completion:^(BOOL finished) {
        [self resetInitialState];
    }];
    
}

- (void)animatedOpenRight {
    [UIView animateWithDuration:_animatedDuration animations:^{
        // 设置cell截图在右边打开时的最终位置
        self.snapView.zj_x = -self.rightView.zj_width;
        // 设置左右菜单的容器view在右边打开时的最终位置
        self.overlayerContentView.zj_x = -(self.leftView.zj_width+self.rightView.zj_width)*self.animatedTypePercent;
        if (_swipeViewAnimatedStyle == ZJSwipeViewAnimatedStyleOverlap) {
            // 设置每个按钮的最终位置
            CGFloat x=0;
            for (ZJSwipeButton *swipeBtn in self.rightView.subviews) {
                
                swipeBtn.zj_x = x;
                x += swipeBtn.zj_width;
            }
        }
    } completion:nil];
}

- (void)animatedCloseRight {
    [UIView animateWithDuration:_animatedDuration animations:^{
        // 设置cell截图在右边关闭时的最终位置
        self.snapView.zj_x = 0;
        // 设置左右菜单的容器view在右边关闭时的最终位置
        self.overlayerContentView.zj_x = -self.leftView.zj_width*self.animatedTypePercent;
        if (_swipeViewAnimatedStyle == ZJSwipeViewAnimatedStyleOverlap) {
            // 设置每个按钮的最终位置
            for (ZJSwipeButton *swipeBtn in self.rightView.subviews) {
                swipeBtn.zj_x = 0;
            }
        }

    } completion:^(BOOL finished) {
        [self resetInitialState];
        
    }];
    
}

/**
 *  隐藏左边或者右边的swipeView
 *
 *  @param isShowLeft 是否需要显示左边的swipeView
 */
- (void)hideAndShowSwipeViewNeededWithShowleft:(BOOL)isShowLeft {
    if (isShowLeft) {
        self.leftView.hidden = NO;
        self.rightView.hidden = YES;
    }
    else {
        self.leftView.hidden = YES;
        self.rightView.hidden = NO;
    }
}

- (void)addTableViewObserver {
    [self addObserver:self forKeyPath:ZJSwipeCellTableViewGesturePath options:NSKeyValueObservingOptionInitial context:&ZJSwipeCellContext];
}

- (void)removeTableViewObserver {
    if (self.overlayerContentView) {
        [self removeObserver:self forKeyPath:ZJSwipeCellTableViewGesturePath];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (context == &ZJSwipeCellContext && keyPath == ZJSwipeCellTableViewGesturePath) {
        if (self.tableView.panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
            // 相当于点击了tableView 关闭滑动菜单
            [self handleTapGesture:nil];
        }
    }
}

- (void)setupSwipeViewWithSwipeVelocityX:(CGFloat)velocityX {
    if (self.overlayerContentView == nil) {
        if (self.closeOtherCellSwipeViewWhenOpenSwipeView) {
            for (UITableViewCell *cell in [self.tableView visibleCells]) {
                if ([cell isKindOfClass:[ZJSwipeTableViewCell class]]) {
                    ZJSwipeTableViewCell *swipeCell = (ZJSwipeTableViewCell *)cell;
                    if (swipeCell != self) {
                        [swipeCell handleTapGesture:nil];
                    }
                }
            }

        }
        
        NSArray<ZJSwipeButton *> *leftBtns = [self.delegate tableView:self.tableView leftSwipeButtonsAtIndexPath:[self.tableView indexPathForCell:self]];
        
        NSArray<ZJSwipeButton *> *rightBtns = [self.delegate tableView:self.tableView rightSwipeButtonsAtIndexPath:[self.tableView indexPathForCell:self]];
        // 不符合条件不创建
        // 左边按钮个数为0 说明不需要创建左边菜单,这个时候向右滑动试图打开左边菜单 直接就返回了
        // 右边按钮个数为0 说明不需要创建右边菜单,这个时候向左滑动试图打开右边菜单 直接就返回了
        if ((leftBtns.count==0 && velocityX>0) || (rightBtns.count==0 && velocityX<0)) {
            return;
        }
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.tableView addGestureRecognizer:self.tapGesture];
        [self addTableViewObserver];
        
        CGFloat overleyContentViewWidth = self.bounds.size.width;
        self.overlayerContentView = [[UIView alloc] initWithFrame:self.bounds];
        self.overlayerContentView.backgroundColor = _overlayerBackgroundColor;
        
        if (self.leftView == nil) {
            if (leftBtns.count > 0) {
                self.leftView = [[ZJSwipeView alloc] initWithSwipeButtons:leftBtns height:self.bounds.size.height];
                
                self.leftView.zj_x = 0.f;

                overleyContentViewWidth += (self.leftView.zj_width*self.animatedTypePercent);
                
                [self.overlayerContentView addSubview:self.leftView];
            }

        }
        
        if (!self.rightView) {
            if (rightBtns.count > 0) {
                self.rightView = [[ZJSwipeView alloc] initWithSwipeButtons:rightBtns height:self.bounds.size.height];
                overleyContentViewWidth += (self.rightView.zj_width*self.animatedTypePercent);
                self.rightView.zj_x = overleyContentViewWidth-self.rightView.zj_width;
                [self.overlayerContentView addSubview:self.rightView];
            }
        }

        self.overlayerContentView.zj_x = -self.leftView.zj_width*self.animatedTypePercent;
        self.overlayerContentView.zj_width = overleyContentViewWidth;
        // 先添加overlayerContentView 到cell上, 再添加cell截图, 注意顺序
        [self addSubview:self.overlayerContentView];

        // 添加截图
        if (self.snapView == nil) {
            // 系统提供的方法 iOS7之后就不用我们自己来绘图实现截图的需求了
            self.snapView = [self snapshotViewAfterScreenUpdates:NO];
            self.snapView.frame = self.bounds;
            // 添加到cell上
            [self addSubview:self.snapView];
        }
    }
}

- (void)handleTapGesture:(UITapGestureRecognizer *)tapGesture {
    if (self.overlayerContentView) {
        if (self.swipeOperation == ZJSwipeOperationOpenLeft) {
            [self animatedCloseLeft];
        }
        else {
            [self animatedCloseRight];
        }
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    if (gestureRecognizer == self.panGesture) {
        if (self.editing) {
            return NO;
        }
        self.highlighted = NO;
        CGPoint transion = [self.panGesture translationInView:self];
        return transion.y == 0; // 是否是上下滑动
    }
    else if (gestureRecognizer == self.tapGesture) { // 所有的cell公用这一个tapGesture
        if (self.overlayerContentView) {
            return YES;
        }
        else {
            return NO;
        }
    }
    return YES;
}


- (CGFloat)animatedTypePercent {
    if (self.swipeViewAnimatedStyle == ZJSwipeViewAnimatedStyleNone) {
        return 0.f;
    }
    else if (self.swipeViewAnimatedStyle == ZJSwipeViewAnimatedStyleParallax) {
        return 0.7f;
    }
    else {
        return 1.f;
    }
}

- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        tapGesture.delegate = self;
        _tapGesture = tapGesture;
    }
    return _tapGesture;
}


- (UITableView *)tableView {
    if (!_tableView) {
        UIView *nextView = self.superview;
        while (self.superview) {
            // 遍历cell的superView, 当superView是UITableView的时候, 说明找到了
            // cell所在的tableView
            if ([nextView isKindOfClass:[UITableView class]]) {
                _tableView = (UITableView *)nextView;
                break;
            }
            nextView = nextView.superview;
        }
    }
    return _tableView;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
