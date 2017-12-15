//
//  AddressBookController1.m
//  KIAddressBook
//
//  Created by xinyu on 2017/10/23.
//  Copyright © 2017年 xinyu. All rights reserved.
//

#import "AddressBookController1.h"
#import "KIAddressBookManager.h"

#define START NSDate *startTime = [NSDate date]
#define END NSLog(@"Time: %f", -[startTime timeIntervalSinceNow])

@interface AddressBookController1 ()

@property (nonatomic, copy) NSDictionary *contactPeopleDict;
@property (nonatomic, copy) NSArray *keys;

@end

@implementation AddressBookController1

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
    
    
    //获取按联系人姓名首字拼音A~Z排序(已经对姓名的第二个字做了处理)
    [KIAddressBookManager getOrderAddressBook:^(NSDictionary<NSString *,NSArray *> *addressBookDict, NSArray *nameKeys) {
        
        [indicator stopAnimating];
        
        //装着所有联系人的字典
        self.contactPeopleDict = addressBookDict;
        //联系人分组按拼音分组的Key值
        self.keys = nameKeys;
        
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.keys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = _keys[section];
    return [_contactPeopleDict[key] count];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.keys[section];
}

//右侧的索引
- (NSArray*)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.keys;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"CELL";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    NSString *key = self.keys[indexPath.section];
    KIContactsModl *people = [_contactPeopleDict[key] objectAtIndex:indexPath.row];
    cell.imageView.image = people.headerImage ? people.headerImage : [UIImage imageNamed:@"avatar"];
    cell.imageView.layer.cornerRadius = 50/2;
    cell.imageView.clipsToBounds = YES;
    cell.textLabel.text = people.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key = _keys[indexPath.section];
    KIContactsModl *people = [_contactPeopleDict[key] objectAtIndex:indexPath.row];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:people.name
                                                    message:[NSString stringWithFormat:@"号码:%@",people.mobileArray]
                                                   delegate:nil
                                          cancelButtonTitle:@"知道啦"
                                          otherButtonTitles:nil];
    [alert show];
}


@end
