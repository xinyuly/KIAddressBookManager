//
//  KIAddressBookManager.h
//  KIAddressBook
//
//  Created by xinyu on 2017/10/23.
//  Copyright © 2017年 xinyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KIContactsModl.h"

/** 一个联系人的相关信息*/
typedef void(^PPPersonModelBlock)(KIContactsModl *model);

/** 授权失败的Block*/
typedef void(^AuthorizationFailure)(void);

/**
 *  获取原始顺序的所有联系人的Block
 */
typedef void(^AddressBookArrayBlock)(NSArray<KIContactsModl *> *addressBookArray);

typedef void(^AddressBookDictBlock)(NSDictionary<NSString *,NSArray *> *addressBookDict,NSArray *nameKeys);

@interface KIAddressBookManager : NSObject

/**
 *  请求用户授权
 */
+ (void)requestAddressBookAuthorization;

/**
 *  获得联系人原始列表
 */
+ (void)getOriginalAddressBook:(AddressBookArrayBlock)addressBookArray authorizationFailure:(AuthorizationFailure)failure;

+ (void)getOrderAddressBook:(AddressBookDictBlock)addressBookInfo authorizationFailure:(AuthorizationFailure)failure;

@end
