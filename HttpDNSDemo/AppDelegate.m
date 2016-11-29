//
//  AppDelegate.m
//  HttpDNSDemo
//
//  Created by ZhiLi on 2016/11/24.
//  Copyright © 2016年 ZhiLi. All rights reserved.
//

#import "AppDelegate.h"
#import "NetworkManager.h"
#import <AlicloudHttpDNS/AlicloudHttpDNS.h>
#import <AlicloudUtils/AlicloudUtils.h>
#import "CustomURLProtocol.h"
#import "IPAddressClient.h"
#import "IPAddressModel.h"
#import <TMCache/TMCache.h>
#import "IPAddress.h"
#import "ApplicationManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    //详细逻辑说明可以看看目录下的README
    
    //内置本地IPList
    [ApplicationManager initialApplication];
    //判断本机是否被劫持，并使用阿里云服务获取真实IP地址
    [self setAlicloudHttpDNS];
    
    //启动时获取服务器各域名解析地址并存储在本地
    [IPAddressClient getIPAddressData];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma  mark - 阿里云httpDNS
- (NSString *)getIpByHostInURLString:(NSString *)urlString {
    NSURL *URL = [NSURL URLWithString:urlString];
    NSString *ip = [[HttpDnsService sharedInstance] getIpByHostInURLFormat:URL.host];
    if ([[AlicloudIPv6Adapter getInstance] isIPv4Address:ip]) {
        return ip;
    }
    return nil;
}

/*
 * 降级过滤器，您可以自己定义HTTPDNS降级机制
 */
- (BOOL)shouldDegradeHTTPDNS:(NSString *)hostName {
    NSLog(@"Enters Degradation filter.");
    // 根据HTTPDNS使用说明，存在网络代理情况下需降级为Local DNS
    if ([NetworkManager configureProxies]) {
        NSLog(@"Proxy was set. Degrade!");
        return YES;
    }
    
    // 假设您禁止"www.taobao.com"域名通过HTTPDNS进行解析
    if ([hostName isEqualToString:@"www.taobao.com"]) {
        NSLog(@"The host is in blacklist. Degrade!");
        return YES;
    }
    
    return NO;
}
- (void)setAlicloudHttpDNS{
    //删除原来的内置IP
    RemoveHttpDNSJifenIP();
    if ([[TMCache sharedCache] objectForKey:kLocalIPAddressModel]) {
        IPAddressModel * model = [[TMCache sharedCache] objectForKey:kLocalIPAddressModel];
        NSString *jifenIP = [IPAddress getIPAddressWithUrl:@"jifen.2345.com"];
        BOOL openJifenHTTPDNS = YES;
        //检测jifen域名是否被劫持
        if (jifenIP) {
            for (NSString *loacalIP in model.jifenIPList) {
                if ([loacalIP isEqualToString:jifenIP]) {
                    openJifenHTTPDNS = NO;
                }
            }
        }else{
            openJifenHTTPDNS = NO;
        }
        if(openJifenHTTPDNS){
            //所有网络请求优先经过CustomURLProtocol来实现阿里云HttpDNS防护
            [NSURLProtocol registerClass:[CustomURLProtocol class]];
        }
        if (openJifenHTTPDNS) {
            // 初始化HTTPDNS
            HttpDnsService *httpdns = [HttpDnsService sharedInstance];
            
            // 设置AccoutID
            [httpdns setAccountID:107988];//本iP仅供测试用
            // 为HTTPDNS服务设置降级机制
            [httpdns setDelegateForDegradationFilter:(id < HttpDNSDegradationDelegate >)self];
            // 允许返回过期的IP
            [httpdns setExpiredIPEnabled:YES];
            
            // edited
            NSArray *preResolveHosts = @[ @"jifen.2345.com"];
            // 设置预解析域名列表
            [httpdns setPreResolveHosts:preResolveHosts];
            if (openJifenHTTPDNS) {
                //积分联盟
                NSString *PCIP = [self getIpByHostInURLString:kServerIPAddressListBaseUrl];
                if (DATA_STRING(PCIP)) {
                    SetHttpDNSJifenIP(PCIP);
                }
            }
        }
    }
}

@end
