//
//  ZJSwipeButton.m
//  ZJSwipTableView
//
//  Created by ZeroJ on 16/10/13.
//  Copyright © 2016年 ZeroJ. All rights reserved.
//

#import "ZJSwipeButton.h"

@interface ZJSwipeButton ()
@property (copy, nonatomic) ZJSwipeButtonOnClickHandler onClickHandler;
@end
@implementation ZJSwipeButton

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image onClickHandler:(ZJSwipeButtonOnClickHandler)onClickHandler {
    if (self = [super init]) {
        _onClickHandler = [onClickHandler copy];
        [self addTarget:self action:@selector(swipeBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self setTitle:title forState:UIControlStateNormal];
        [self setImage:image forState:UIControlStateNormal];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.backgroundColor = [UIColor whiteColor];
        CGFloat margin = 10;
        // 计算文字尺寸
        CGSize textSize = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, 200.f) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.titleLabel.font, NSForegroundColorAttributeName: self.titleLabel.textColor } context:nil].size;
        // 计算按钮宽度, 取图片宽度和文字宽度较大者
        CGFloat btnWidth = MAX(image.size.width+margin, textSize.width+margin);
        // 文字居中
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        // 暂时的, 宽高有效, 其他的会在父控件(ZJSwipeView)中调整
        self.frame = CGRectMake(0.f, 0.f, btnWidth, image.size.height+textSize.height+margin);

    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.imageView.image) {
        // 设置了图片, 重新调整imageView和titleLabel的frame
        // 让图片在上, 文字在下显示
        CGFloat selfHeight = self.bounds.size.height;
        CGFloat selfWidth = self.bounds.size.width;

        CGSize imageSize = self.imageView.image.size;
        CGFloat imageAndTextMargin = 5.f;

        CGFloat margin = (selfHeight - imageSize.height - self.titleLabel.bounds.size.height - imageAndTextMargin)/2;
        self.imageView.frame = CGRectMake((selfWidth-imageSize.width)/2, margin, imageSize.width, imageSize.height);
        // 计算文本frame
        CGRect titleLabelFrame = self.titleLabel.frame;
        titleLabelFrame.origin.x = 0;
        titleLabelFrame.origin.y = CGRectGetMaxY(self.imageView.frame) + imageAndTextMargin;
        titleLabelFrame.size.width = selfWidth;
        self.titleLabel.frame = titleLabelFrame;
    }
}
// 按钮点击响应事件
- (void)swipeBtnOnClick:(UIButton *)btn {
    if (_onClickHandler) {
        _onClickHandler(btn);
    }
}


@end
