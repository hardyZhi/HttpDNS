//
//  IPAddress.m
//  httpdns_ios_demo
//
//  Created by ZhiLi on 2016/11/24.
//  Copyright © 2016年 ZhiLi. All rights reserved.
//

#import "IPAddress.h"

#import <arpa/inet.h>
#import <netdb.h>
#import <setjmp.h>
#import <SystemConfiguration/SystemConfiguration.h>

@implementation IPAddress

static sigjmp_buf jmpbuf;
static void alarm_func()
{
    siglongjmp(jmpbuf, 1);
}
static struct hostent *timeGethostbyname(const char *domain, int timeout)
{
    struct hostent *ipHostent = NULL;
    signal(SIGALRM, alarm_func);
    
    if (sigsetjmp(jmpbuf, 1) != 0)
    {
        alarm(0); //timeout
        signal(SIGALRM, SIG_IGN);
        return  NULL;
    }
    
    alarm(timeout);//setting alarm
    ipHostent = gethostbyname(domain);
    signal(SIGALRM, SIG_IGN);
    
    //NSLog(@"%s ", __FUNCTION__);
    return ipHostent;
}
+ (NSString *)getIPAddressWithUrl:(NSString *)url
{
    //2013.07.19
    //ex NSLog(@"%s ip=%@", __FUNCTION__, [SYCrawler getIPAddressWithUrl:@"www.google.com"]);
    struct hostent *host = timeGethostbyname([url UTF8String], 5); //gethostbyname([url UTF8String]);
    
    if (host == NULL) {
        return nil;
    }
    
    struct in_addr **list = (struct in_addr **)host->h_addr_list;
    char *pchar = inet_ntoa(*list[0]);
    NSString *addressString = [NSString stringWithCString:pchar encoding:NSUTF8StringEncoding];
    return addressString;
    
}

@end
