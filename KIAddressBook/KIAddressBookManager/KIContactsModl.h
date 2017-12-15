//
//  KIContactsModl.h
//  KIAddressBook
//
//  Created by xinyu on 2017/10/23.
//  Copyright © 2017年 xinyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KIContactsModl : NSObject

//姓名
@property (nonatomic, copy) NSString *name;

//电话数组,一个联系人可存储多个号码
@property (nonatomic, strong) NSMutableArray *mobileArray;

//头像
@property (nonatomic, strong) UIImage *headerImage;

@end
