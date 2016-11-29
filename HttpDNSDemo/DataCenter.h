//
//  DataCenter.h
//  HttpDNSDemo
//
//  Created by ZhiLi on 16/11/24.
//  Copyright © 2016年 hardy. All rights reserved.
//

#ifndef DataCenter_h
#define DataCenter_h

#import <Foundation/Foundation.h>

#define StandardUserDefaults [NSUserDefaults standardUserDefaults]


#pragma mark -  是否初装，初装的话要加载一些默认配置
FOUNDATION_STATIC_INLINE BOOL RCLoadedApplicationEver() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"LoadedApplication"];
}

FOUNDATION_STATIC_INLINE void RCLoadApplication() {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"LoadedApplication"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//存储阿里云httpDNS返回的ip地址存在本地
static NSString *const kHttpDNSJifenKey = @"jifen.2345.com";

FOUNDATION_STATIC_INLINE NSString *HttpDNSJifenIP() {
    NSString *ipStr = [StandardUserDefaults objectForKey:kHttpDNSJifenKey];
    return ipStr;
}

FOUNDATION_STATIC_INLINE void RemoveHttpDNSJifenIP() {
    [StandardUserDefaults removeObjectForKey:kHttpDNSJifenKey];
    [StandardUserDefaults synchronize];
}

FOUNDATION_STATIC_INLINE void SetHttpDNSJifenIP(NSString *ipStr) {
    [StandardUserDefaults setObject:ipStr forKey:kHttpDNSJifenKey];
    [StandardUserDefaults synchronize];
}
#endif /* UNDataCenter_h */
