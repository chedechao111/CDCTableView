//
//  ViewController.m
//  CDTableViewTest
//
//  Created by chedechao on 2017/7/20.
//  Copyright © 2017年 chedechao. All rights reserved.
//

#import "ViewController.h"
#import "CDTableView.h"
#import "CDTableViewCell.h"
@interface ViewController ()<CDTableViewDelegate,CDTableViewDataSource>

@end

@implementation ViewController{
    CDTableView *_tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    CGSize viewSize = self.view.frame.size;
    _tableView = [[CDTableView alloc] initWithFrame:CGRectMake(0, 0, viewSize.width, viewSize.height)];
    _tableView.cdDataSource = self;
    _tableView.cdDelegate = self;
    [_tableView setUpCell];
    [self.view addSubview:_tableView];
}

#pragma mark - delegate && dataSource

- (NSInteger)cdtableView:(CDTableView *)cdtableView numberOfRowsInSection:(NSInteger)section {
    return 200;
}
- (CDTableViewCell *)cdtableView:(CDTableView *)cdtableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CDTableViewCell *cell = [cdtableView dequeueReusableCellWithIdentifier:@"cellReuse"];
    if (!cell) {
        cell = [[CDTableViewCell alloc] init];
        cell.reuserId = @"cellReuse";
    }
    return cell;
}

-(CGFloat)cdtableView:(CDTableView *)cdtableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 22 * (indexPath.row + 1);
    return 60;
}

- (void)dealloc {
    _tableView.cdDelegate = nil;
    _tableView.cdDataSource = nil;
}



@end
