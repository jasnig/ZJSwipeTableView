//
//  ZJSwipeView.h
//  ZJSwipTableView
//
//  Created by ZeroJ on 16/10/13.
//  Copyright © 2016年 ZeroJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZJSwipeButton.h"

@interface ZJSwipeView : UIView
- (instancetype)initWithSwipeButtons:(NSArray<ZJSwipeButton *> *)swipeButtons height:(CGFloat)height;
@end
