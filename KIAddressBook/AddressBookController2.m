//
//  AddressBookController2.m
//  KIAddressBook
//
//  Created by xinyu on 2017/10/23.
//  Copyright © 2017年 xinyu. All rights reserved.
//

#import "AddressBookController2.h"
#import "KIAddressBookManager.h"

@interface AddressBookController2 ()<UIAlertViewDelegate>

@property (nonatomic, copy) NSArray *dataSource;

@end

@implementation AddressBookController2

- (void)viewDidLoad {
    [super viewDidLoad];
    
     self.title = @"联系人列表";
    
    self.tableView.tableFooterView = [UIView new];
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.frame = CGRectMake(0, 0, 80, 80);
    indicator.center = CGPointMake([UIScreen mainScreen].bounds.size.width*0.5, [UIScreen mainScreen].bounds.size.height*0.5-80);
    indicator.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.7];
    indicator.clipsToBounds = YES;
    indicator.layer.cornerRadius = 6;
    [indicator startAnimating];
    [self.view addSubview:indicator];
    
    //获取没有经过排序的联系人模型
    [KIAddressBookManager getOriginalAddressBook:^(NSArray<KIContactsModl *> *addressBookArray) {
        [indicator stopAnimating];
        
        _dataSource = addressBookArray;
        [self.tableView reloadData];
        
    } authorizationFailure:^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"请在iPhone的“设置-隐私-通讯录”选项中，允许PPAddressBook访问您的通讯录"
                                                       delegate:nil
                                              cancelButtonTitle:@"知道了"
                                              otherButtonTitles:nil];
        [alert show];
    }];
    
    self.tableView.rowHeight = 60;
}


#pragma mark - TableViewDatasouce/TableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *reuseIdentifier = @"CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    KIContactsModl *people = _dataSource[indexPath.row];
    cell.imageView.image = people.headerImage ? people.headerImage : [UIImage imageNamed:@"avatar"];
    cell.imageView.layer.cornerRadius = 50/2;
    cell.imageView.clipsToBounds = YES;
    cell.textLabel.text = people.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    KIContactsModl *people = _dataSource[indexPath.row];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:people.name
                                                    message:[NSString stringWithFormat:@"号码:%@",people.mobileArray]
                                                   delegate:nil
                                          cancelButtonTitle:@"知道啦"
                                          otherButtonTitles:nil];
    [alert show];
}



@end
