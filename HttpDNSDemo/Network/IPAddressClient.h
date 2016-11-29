//
//  IPAddressClient.h
//  HttpDNSDemo
//
//  Created by ZhiLi on 2016/11/24.
//  Copyright © 2016年 ZhiLi. All rights reserved.
//

#import <Overcoat/Overcoat.h>
#import "IPAddressModel.h"
#import "DNSResponse.h"

@interface IPAddressClient : OVCHTTPSessionManager

+ (void)clientDealloc;
//获取联盟各域名IP地址列表并保存本地存储
+ (void)getIPAddressData;

//展示接口
+ (void)getIPAddressDataSuccuss:(DNSRequestCompleteBlock)success
                        failure:(DNSRequestFailedBlock)failure;
@end
