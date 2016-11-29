//
//  ApplicationManager.m
//  HttpDNSDemo
//
//  Created by ZhiLi on 2016/11/22.
//  Copyright © 2016年 hardy. All rights reserved.
//

#import "ApplicationManager.h"
#import "IPAddressModel.h"
#import <TMCache/TMCache.h>

@implementation ApplicationManager
+ (ApplicationManager *)defaultManager {
    static ApplicationManager *defaultManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultManager = [[ApplicationManager alloc] init];
    });
    return defaultManager;
}
+ (void)initialApplication {
    //首次打开
    if (!RCLoadedApplicationEver()) {
        //初始化本地IP地址库
        [[ApplicationManager defaultManager] initLocalIPAddressCache];
    }
    RCLoadApplication();
}

-(void)initLocalIPAddressCache{
    NSMutableDictionary*ipAddressDictionary = [NSMutableDictionary dictionary];
    [ipAddressDictionary setObject:@[@"115.231.185.111",@"42.62.60.247",@"101.71.94.16"] forKey:@"jifen"];
    [ipAddressDictionary setObject:@[@"183.136.203.23",@"42.62.60.247",@"101.71.94.19"] forKey:@"shouji"];
    [ipAddressDictionary setObject:@[@"183.136.203.9",@"101.71.94.5",@"112.25.27.160"] forKey:@"bbs"];
    IPAddressModel *iPAddressModel =
    [MTLJSONAdapter modelOfClass:[IPAddressModel class] fromJSONDictionary:ipAddressDictionary error:nil];
    [[TMCache sharedCache] setObject:iPAddressModel forKey:kLocalIPAddressModel];
}
@end
