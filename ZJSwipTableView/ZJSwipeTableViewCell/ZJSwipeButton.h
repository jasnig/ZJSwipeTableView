//
//  ZJSwipeButton.h
//  ZJSwipTableView
//
//  Created by ZeroJ on 16/10/13.
//  Copyright © 2016年 ZeroJ. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ZJSwipeButtonOnClickHandler)(UIButton *swipeButton);
@interface ZJSwipeButton : UIButton
- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image onClickHandler:(ZJSwipeButtonOnClickHandler)onClickHandler;
@end
