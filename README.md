# ZJSwipeTableView
一个可以方便实现自定义的tableView的左右侧滑菜单的效果. 支持四种动画效果. 也同时支持了简书的漂亮的侧滑效果.

![swipeTableViewCell.gif](http://upload-images.jianshu.io/upload_images/1271831-e4772b0472eef55d.gif?imageMogr2/auto-orient/strip)


```

- (NSArray<ZJSwipeButton *> *)tableView:(UITableView *)tableView leftSwipeButtonsAtIndexPath:(NSIndexPath *)indexPath {
    ZJSwipeButton *leftBtn = [[ZJSwipeButton alloc] initWithTitle:@"检查1" image:nil onClickHandler:^(UIButton *swipeButton) {
        NSLog(@"点击了检查1: --- %ld", indexPath.row);
        [ZJProgressHUD showStatus:[NSString stringWithFormat:@"点击了检查1: --- %ld", indexPath.row] andAutoHideAfterTime:1];
    }];
    ZJSwipeButton *leftBtn1 = [[ZJSwipeButton alloc] initWithTitle:@"测试2" image:nil onClickHandler:^(UIButton *swipeButton) {
        NSLog(@"点击了测试2: --- %ld", indexPath.row);
        [ZJProgressHUD showStatus:[NSString stringWithFormat:@"点击了测试2: --- %ld", indexPath.row] andAutoHideAfterTime:1];

    }];
    return @[leftBtn,leftBtn1, leftBtn2,leftBtn3];

}
```