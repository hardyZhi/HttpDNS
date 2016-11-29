//
//  IPAddressModel.m
//  union
//
//  Created by ZhiLi on 2016/11/21.
//  Copyright © 2016年 hardy. All rights reserved.
//

#import "IPAddressModel.h"

@implementation IPAddressModel
+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return @{@"jifenIPList": @"jifen",
             @"shoujiIPList": @"shouji",
             @"bbsIPList": @"bbs",
             @"wangpaiIPList": @"wangpai",
             @"shoujibbsIPList" :@"shoujibbs"
             };
}
@end
