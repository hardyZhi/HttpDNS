//
//  DNSResponse.m
//  HttpDNSDemo
//
//  Created by ZhiLi on 2016/11/24.
//  Copyright © 2016年 ZhiLi. All rights reserved.
//

#import "DNSResponse.h"
@implementation DNSResponse

+ (OVC_NULLABLE NSString *)resultKeyPathForJSONDictionary:(NSDictionary *)JSONDictionary {
    return @"data";
}

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return @{
             @"status" : @"status",
             @"message" : @"message",
             @"tips" : @"tips",
             };
}

@end
