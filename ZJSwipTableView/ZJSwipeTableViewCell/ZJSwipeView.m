//
//  ZJSwipeView.m
//  ZJSwipTableView
//
//  Created by ZeroJ on 16/10/13.
//  Copyright © 2016年 ZeroJ. All rights reserved.
//

#import "ZJSwipeView.h"

@interface ZJSwipeView ()

@end
@implementation ZJSwipeView

- (instancetype)initWithSwipeButtons:(NSArray<ZJSwipeButton *> *)swipeButtons height:(CGFloat)height {

    if (self = [super init]) {

        CGFloat btnX = 0.f;
        CGFloat allBtnWidth = 0.f;
        // 为每个按钮设置frame, 同时计算好所有的按钮的宽度之和, 作为swipeView的宽度
        // 注意这里是反向遍历添加的
        for (ZJSwipeButton *button in [swipeButtons reverseObjectEnumerator]) {
            [self addSubview:button];
            
            button.frame = CGRectMake(btnX, 0, button.bounds.size.width, height);
            btnX += button.bounds.size.width;
            allBtnWidth += button.bounds.size.width;
        }
        // 设置frame 宽高有效, x, y在swipeTableViewCell中还会相应的调整
        self.frame = CGRectMake(0.f, 0.f, allBtnWidth, height);
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}
@end
