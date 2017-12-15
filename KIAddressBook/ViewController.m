//
//  ViewController.m
//  KIAddressBook
//
//  Created by xinyu on 2017/10/23.
//  Copyright © 2017年 xinyu. All rights reserved.
//

#import "ViewController.h"
#import "AddressBookController1.h"
#import "AddressBookController2.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, copy) NSArray *dataSource;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"联系人";
    _dataSource = @[@"顺序排列",@"无序排列"];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"CELL";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = self.dataSource[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *VC = nil;
    if(indexPath.row == 0) {
        VC = [AddressBookController1 new];
    } else {
        VC = [AddressBookController2 new];
    }
    [self.navigationController pushViewController:VC animated:YES];
}


@end
