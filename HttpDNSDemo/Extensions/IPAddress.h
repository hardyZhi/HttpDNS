//
//  IPAddress.h
//  httpdns_ios_demo
//
//  Created by ZhiLi on 2016/11/24.
//  Copyright © 2016年 ZhiLi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IPAddress : NSObject

//获取域名对应的DNS解析后的IP
+ (NSString *)getIPAddressWithUrl:(NSString *)url;
@end
