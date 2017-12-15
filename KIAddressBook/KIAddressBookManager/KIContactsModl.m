//
//  KIContactsModl.m
//  KIAddressBook
//
//  Created by xinyu on 2017/10/23.
//  Copyright © 2017年 xinyu. All rights reserved.
//

#import "KIContactsModl.h"

@implementation KIContactsModl

- (NSMutableArray *)mobileArray {
    if(!_mobileArray) {
        _mobileArray = [NSMutableArray array];
    }
    return _mobileArray;
}


@end
