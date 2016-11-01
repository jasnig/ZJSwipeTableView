//
//  UIView+Frame.m
//  ZJSwipTableView
//
//  Created by ZeroJ on 16/10/13.
//  Copyright © 2016年 ZeroJ. All rights reserved.
//

#import "UIView+Frame.h"

@implementation UIView (Frame)

- (CGFloat)zj_x {
    return self.frame.origin.x;
}

- (void)setZj_x:(CGFloat)zj_x {
    CGRect frame = self.frame;
    frame.origin.x = zj_x;
    self.frame = frame;
}

- (CGFloat)zj_y {
    return self.frame.origin.y;
}

- (void)setZj_y:(CGFloat)zj_y {
    CGRect frame = self.frame;
    frame.origin.x = zj_y;
    self.frame = frame;
}

- (CGFloat)zj_width {
    return self.frame.size.width;
}

- (void)setZj_width:(CGFloat)zj_width {
    CGRect frame = self.frame;
    frame.size.width = zj_width;
    self.frame = frame;
}

- (CGFloat)zj_height {
    return self.frame.size.height;
}

- (void)setZj_height:(CGFloat)zj_height {
    CGRect frame = self.frame;
    frame.size.height = zj_height;
    self.frame = frame;
}

@end
