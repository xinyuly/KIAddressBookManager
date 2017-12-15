//
//  KIAddressBookManager.m
//  KIAddressBook
//
//  Created by xinyu on 2017/10/23.
//  Copyright © 2017年 xinyu. All rights reserved.
//

#import "KIAddressBookManager.h"
#import <Contacts/Contacts.h>

#define IOS9_LATER ([[UIDevice currentDevice] systemVersion].floatValue >= 9.0 ? YES : NO )

@interface KIAddressBookManager()
@property (nonatomic, strong) CNContactStore *contactStore;
@end

@implementation KIAddressBookManager
static id _instance;

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

- (id)copyWithZone:(NSZone *)zone {
    return _instance;
}
#pragma mark - request Authorization
+ (void)requestAddressBookAuthorization {
    // 判断是否授权成功
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized) return;
    // 授权
    [[KIAddressBookManager sharedManager].contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            NSLog(@"授权成功");
        }else{
            NSLog(@"授权失败");
        }
    }];
}

- (void)getAddressBookDataSource:(PPPersonModelBlock)personModel authorizationFailure:(AuthorizationFailure)failure {
    
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (status != CNAuthorizationStatusAuthorized) {
        failure ? failure() : nil;
        return;
    }
    // keys决定获取哪些信息,例:姓名,电话,头像等
    NSArray *fetchKeys = @[[CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName],CNContactPhoneNumbersKey,CNContactThumbnailImageDataKey];
    CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:fetchKeys];
    
    [self.contactStore enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact * _Nonnull contact,BOOL * _Nonnull stop) {
        
        KIContactsModl *model = [KIContactsModl new];
        NSString *name = [CNContactFormatter stringFromContact:contact style:CNContactFormatterStyleFullName];
        model.name = name.length > 0 ? name : @"无名氏" ;
        
        model.headerImage = [UIImage imageWithData:contact.thumbnailImageData];
        
        NSArray *phones = contact.phoneNumbers;
        
        for (CNLabeledValue *labelValue in phones) {
            CNPhoneNumber *phoneNumber = labelValue.value;
            NSString *mobile = [self removeSpecialSubString:phoneNumber.stringValue];
            [model.mobileArray addObject: mobile.length > 0 ? mobile : @"空号"];
        }
        //回调出去
        personModel ? personModel(model) : nil;
    }];
    
}

//自定义添加过滤字符串
- (NSString *)removeSpecialSubString: (NSString *)string {
    string = [string stringByReplacingOccurrencesOfString:@"+86" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"-" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"(" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@")" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return string;
}


#pragma mark - 原始顺序所有联系人
+ (void)getOriginalAddressBook:(AddressBookArrayBlock)addressBookArray authorizationFailure:(AuthorizationFailure)failure {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSMutableArray *array = [NSMutableArray array];
        [[[KIAddressBookManager alloc] init] getAddressBookDataSource:^(KIContactsModl *model) {
            
            [array addObject:model];
            
        } authorizationFailure:^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                failure ? failure() : nil;
            });
        }];
        
        // 将联系人数组回调到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            addressBookArray ? addressBookArray(array) : nil ;
        });
    });
    
}

#pragma mark - 按A~Z顺序排列的所有联系人
+ (void)getOrderAddressBook:(AddressBookDictBlock)addressBookInfo authorizationFailure:(AuthorizationFailure)failure {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSMutableDictionary *addressBookDict = [NSMutableDictionary dictionary];
        [[KIAddressBookManager sharedManager] getAddressBookDataSource:^(KIContactsModl *model) {
            //获取姓名的大写首字母
            NSString *firstLetterString = [self getFirstLetterFromString:model.name];
            if (addressBookDict[firstLetterString]) {
                [addressBookDict[firstLetterString] addObject:model];
            } else {
                NSMutableArray *arrGroupNames = [NSMutableArray array];
                [arrGroupNames addObject:model];
                [addressBookDict setObject:arrGroupNames forKey:firstLetterString];
            }
        } authorizationFailure:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                failure ? failure() : nil;
            });
        }];
        
        // 将addressBookDict字典中的所有Key值进行排序: A~Z
        NSArray *nameKeys = [[addressBookDict allKeys] sortedArrayUsingSelector:@selector(compare:)];
        
        // 将 "#" 排列在 A~Z 的后面
        if ([nameKeys.firstObject isEqualToString:@"#"]) {
            NSMutableArray *mutableNamekeys = [NSMutableArray arrayWithArray:nameKeys];
            [mutableNamekeys insertObject:nameKeys.firstObject atIndex:nameKeys.count];
            [mutableNamekeys removeObjectAtIndex:0];
            dispatch_async(dispatch_get_main_queue(), ^{
                addressBookInfo ? addressBookInfo(addressBookDict,mutableNamekeys) : nil;
            });
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            addressBookInfo ? addressBookInfo(addressBookDict,nameKeys) : nil;
        });
        
    });
    
}

#pragma mark - 传入汉字字符串, 返回大写拼音首字母
+ (NSString *)getFirstLetterFromString:(NSString *)aString {
    NSMutableString *mutableString = [NSMutableString stringWithString:aString];
    CFStringTransform((CFMutableStringRef)mutableString, NULL, kCFStringTransformToLatin, false);
    NSString *pinyinString = [mutableString stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
    
    // 将拼音首字母转大写
    NSString *strPinYin = [[self polyphoneStringHandle:aString pinyinString:pinyinString] uppercaseString];
    NSString *firstString = [strPinYin substringToIndex:1];
    NSString *regexA = @"^[A-Z]$";
    NSPredicate *predA = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexA];
    // 获取并返回首字母
    return [predA evaluateWithObject:firstString] ? firstString : @"#";
}

/**
 多音字处理
 */
+ (NSString *)polyphoneStringHandle:(NSString *)aString pinyinString:(NSString *)pinyinString {
    if ([aString hasPrefix:@"长"]) { return @"chang";}
    if ([aString hasPrefix:@"沈"]) { return @"shen"; }
    if ([aString hasPrefix:@"厦"]) { return @"xia";  }
    if ([aString hasPrefix:@"地"]) { return @"di";   }
    if ([aString hasPrefix:@"重"]) { return @"chong";}
    return pinyinString;
}

#pragma mark - setter && getter
- (CNContactStore *)contactStore {
    if(!_contactStore) {
        _contactStore = [[CNContactStore alloc] init];
    }
    return _contactStore;
}
@end
