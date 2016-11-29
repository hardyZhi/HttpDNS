//
//  IPAddressModel.h
//  union
//
//  Created by ZhiLi on 2016/11/21.
//  Copyright © 2016年 hardy. All rights reserved.
//  服务器端各个域名的iP列表

#import <Mantle/Mantle.h>

@interface IPAddressModel : MTLModel<MTLJSONSerializing>
@property (nonatomic, strong) NSArray <NSString *> *jifenIPList;//jifen.2345.com IP列表
@property (nonatomic, strong) NSArray <NSString *> *shoujiIPList;//shouji.2345.com IP列表
@property (nonatomic, strong) NSArray <NSString *> *bbsIPList;//bbs.2345.cn IP列表
@property (nonatomic, strong) NSArray <NSString *> *wangpaiIPList;//wangpai.2345.cn IP列表
@property (nonatomic, strong) NSArray <NSString *> *shoujibbsIPList;//shoujibbs.2345.cn IP列表
@end
