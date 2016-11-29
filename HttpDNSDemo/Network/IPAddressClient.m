//
//  IPAddressClient.m
//  HttpDNSDemo
//
//  Created by ZhiLi on 2016/11/24.
//  Copyright © 2016年 ZhiLi. All rights reserved.
//

#import "IPAddressClient.h"
#import <TMCache/TMCache.h>
#import "CustomURLProtocol.h"

static dispatch_once_t onceTokenIPAddress;
static IPAddressClient *_sharedIPAddressClient;
@implementation IPAddressClient
+ (OVCHTTPSessionManager *)currentClient {
    return [IPAddressClient sharedClient];
}

+ (void)clientDealloc {
    onceTokenIPAddress = 0;
    _sharedIPAddressClient = nil;
}

+ (instancetype)sharedClient {
    dispatch_once(&onceTokenIPAddress, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
        if (HttpDNSJifenIP()) {
            NSMutableArray *protocolsArray = [NSMutableArray arrayWithArray:configuration.protocolClasses];
            [protocolsArray insertObject:[CustomURLProtocol class] atIndex:0];
            configuration.protocolClasses = protocolsArray;
        }
        _sharedIPAddressClient = [[IPAddressClient alloc] initWithBaseURL:[NSURL URLWithString:kServerIPAddressListBaseUrl] sessionConfiguration:configuration];
        _sharedIPAddressClient.requestSerializer.timeoutInterval = 10;
        _sharedIPAddressClient.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", nil];
    });
    
    return _sharedIPAddressClient;
}

#pragma mark - Overcoat

+ (NSDictionary *)modelClassesByResourcePath {
    return @{kGetRealIPPath: [IPAddressModel class]};
}

+ (OVC_NULLABLE NSDictionary OVCGenerics(NSString *, id) *)responseClassesByResourcePath {
    return @{@"**": [DNSResponse class]};
}
+ (void)getIPAddressData{
    [[self currentClient] GET:kGetRealIPPath parameters:nil completion:^(OVCResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@",error);
        } else {
            DNSResponse *dnsResponse = (id)response;
            if (dnsResponse.status == 200) {
                IPAddressModel *ipAddress = dnsResponse.result;
                if (ipAddress) {
                    [[TMCache sharedCache] removeAllObjects];
                    [[TMCache sharedCache] setObject:ipAddress forKey:kLocalIPAddressModel];
                }
            }
        }
    }];
}
#pragma mark - 展示接口
+ (void)getIPAddressDataSuccuss:(DNSRequestCompleteBlock)success
                        failure:(DNSRequestFailedBlock)failure {
    [[self currentClient] GET:kGetRealIPPath parameters:nil completion:^(OVCResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            failure(error);
        } else {
            DNSResponse *dnsResponse = (id)response;
            success(dnsResponse);
        }
    }];
}
@end
