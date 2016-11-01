//
//  ViewController.m
//  ZJSwipTableView
//
//  Created by ZeroJ on 16/10/12.
//  Copyright © 2016年 ZeroJ. All rights reserved.
//

#import "ViewController.h"
#import "ZJSwipeTableViewCell.h"
#import "ZJProgressHUD.h"
@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, ZJSwipeTableViewCellDelegate>
@property (strong, nonatomic) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 15;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const kCellId = @"kCellId";
    
    ZJSwipeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    
    if (cell == nil) {
        // 当然可以直接继承ZJSwipeTableViewCell进行自定义cell, 也支持xib
        // 对cell进行相同的设置
        cell = [[ZJSwipeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellId];
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // 对cell进行个性化的设置 注意cell重用的问题 -- 数据填充等
    
    // 可以为每个cell设置不同的动画类型, 目前支持常用的四种
    // 当然设置的时候需要注意cell重用的问题, 应该为所有的cell都明确设置style
    /**
     * 例如当只想为第一个cell设置style为ZJSwipeViewAnimatedStyleOverlap 其他设置为默认的
     * 一定不能少了 else 语句, 否则是会出现重用出错的问题, 不清楚的可以自行查阅cell重用内容显示不对的解决方法
     if (indexPath.row==0) {
     cell.swipeViewAnimatedStyle = ZJSwipeViewAnimatedStyleOverlap;
     }
     else {
     cell.swipeViewAnimatedStyle = ZJSwipeViewAnimatedStyleDefault;
     
     }
     */
    if (indexPath.row%4==0) {
        cell.swipeViewAnimatedStyle = ZJSwipeViewAnimatedStyleOverlap;
    }
    else if (indexPath.row%4==1) {
        cell.swipeViewAnimatedStyle = ZJSwipeViewAnimatedStyleDefault;
        
    }
    else if (indexPath.row%4==2) {
        cell.swipeViewAnimatedStyle = ZJSwipeViewAnimatedStyleNone;
        
    }
    else {
        cell.swipeViewAnimatedStyle = ZJSwipeViewAnimatedStyleParallax;
        
    }
    cell.textLabel.text = [NSString stringWithFormat:@"当前页是:----%ld", indexPath.row];

    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSArray<ZJSwipeButton *> *)tableView:(UITableView *)tableView leftSwipeButtonsAtIndexPath:(NSIndexPath *)indexPath {
    ZJSwipeButton *leftBtn = [[ZJSwipeButton alloc] initWithTitle:@"检查1" image:nil onClickHandler:^(UIButton *swipeButton) {
        NSLog(@"点击了检查1: --- %ld", indexPath.row);
        [ZJProgressHUD showStatus:[NSString stringWithFormat:@"点击了检查1: --- %ld", indexPath.row] andAutoHideAfterTime:1];
    }];
    ZJSwipeButton *leftBtn1 = [[ZJSwipeButton alloc] initWithTitle:@"测试2" image:nil onClickHandler:^(UIButton *swipeButton) {
        NSLog(@"点击了测试2: --- %ld", indexPath.row);
        [ZJProgressHUD showStatus:[NSString stringWithFormat:@"点击了测试2: --- %ld", indexPath.row] andAutoHideAfterTime:1];

    }];
    
    ZJSwipeButton *leftBtn2 = [[ZJSwipeButton alloc] initWithTitle:@"检查3" image:nil onClickHandler:^(UIButton *swipeButton) {
        NSLog(@"点击了检查3: --- %ld", indexPath.row);
        [ZJProgressHUD showStatus:[NSString stringWithFormat:@"点击了检查3: --- %ld", indexPath.row] andAutoHideAfterTime:1];

    }];
    ZJSwipeButton *leftBtn3 = [[ZJSwipeButton alloc] initWithTitle:@"测试4" image:nil onClickHandler:^(UIButton *swipeButton) {
        NSLog(@"点击了测试: --- %ld", indexPath.row);
        [ZJProgressHUD showStatus:[NSString stringWithFormat:@"点击了测试4: --- %ld", indexPath.row] andAutoHideAfterTime:1];

        
    }];
    
    return @[leftBtn,leftBtn1, leftBtn2,leftBtn3];
}

- (NSArray<ZJSwipeButton *> *)tableView:(UITableView *)tableView rightSwipeButtonsAtIndexPath:(NSIndexPath *)indexPath {
    
    ZJSwipeButton *leftBtn = [[ZJSwipeButton alloc] initWithTitle:@"检查1" image:[UIImage imageNamed:@"cm2_act_icn_comment"] onClickHandler:^(UIButton *swipeButton) {
        NSLog(@"点击了检查1: --- %ld", indexPath.row);
        [ZJProgressHUD showStatus:[NSString stringWithFormat:@"点击了检查1: --- %ld", indexPath.row] andAutoHideAfterTime:1];

    }];
    
    
    ZJSwipeButton *leftBtn1 = [[ZJSwipeButton alloc] initWithTitle:@"测试2" image:[UIImage imageNamed:@"cm2_act_icn_recoment"] onClickHandler:^(UIButton *swipeButton) {
        NSLog(@"点击了测试: --- %ld", indexPath.row);
        [ZJProgressHUD showStatus:[NSString stringWithFormat:@"点击了测试2: --- %ld", indexPath.row] andAutoHideAfterTime:1];

        
    }];
    
    ZJSwipeButton *leftBtn2 = [[ZJSwipeButton alloc] initWithTitle:@"检查3" image:[UIImage imageNamed:@"cm2_act_icn_unknown"] onClickHandler:^(UIButton *swipeButton) {
        NSLog(@"点击了检查: --- %ld", indexPath.row);
        [ZJProgressHUD showStatus:[NSString stringWithFormat:@"点击了检查3: --- %ld", indexPath.row] andAutoHideAfterTime:1];

    }];
    ZJSwipeButton *leftBtn3 = [[ZJSwipeButton alloc] initWithTitle:@"测试4" image:[UIImage imageNamed:@"cm2_clock_icn_delete"] onClickHandler:^(UIButton *swipeButton) {
        NSLog(@"点击了测试: --- %ld", indexPath.row);
        [ZJProgressHUD showStatus:[NSString stringWithFormat:@"点击了测试4: --- %ld", indexPath.row] andAutoHideAfterTime:1];

    }];
    
    return @[leftBtn,leftBtn1, leftBtn2,leftBtn3];
}


- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        // 行高度
        tableView.rowHeight = 100.f;
        _tableView = tableView;
    }
    return _tableView;
}

@end
