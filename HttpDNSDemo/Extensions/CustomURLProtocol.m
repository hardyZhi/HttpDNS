//
//  CustomURLProtocol.m
//  union
//
//  Created by ZhiLi on 2016/11/16.
//  Copyright © 2016年 hardy. All rights reserved.
//

#import "CustomURLProtocol.h"
#import <AlicloudHttpDNS/AlicloudHttpDNS.h>
#import <objc/runtime.h>

#define protocolKey @"CFHttpMessagePropertyKey"
#define kAnchorAlreadyAdded @"AnchorAlreadyAdded"
#define httpDNSHostJifen @"jifen.2345.com"

@interface CustomURLProtocol () <NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation CustomURLProtocol
/**
 *  是否拦截处理指定的请求
 *
 *  @param request 指定的请求
 *
 *  @return 返回YES表示要拦截处理，返回NO表示不拦截处理
 */
+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    
    /* 防止无限循环，因为一个请求在被拦截处理过程中，也会发起一个请求，这样又会走到这里，如果不进行处理，就会造成无限循环 */
    if ([NSURLProtocol propertyForKey:protocolKey inRequest:request]) {
        return NO;
    }
    
    NSMutableURLRequest *mutableReq = [request mutableCopy];
    if (mutableReq){
        if ([mutableReq.URL.host isEqualToString:httpDNSHostJifen]&&HttpDNSJifenIP()) {
            return YES;
        }
    }
    return NO;
}

/**
 *  如果需要对请求进行重定向，添加指定头部等操作，可以在该方法中进行
 *
 *  @param request 原请求
 *
 *  @return 修改后的请求
 */
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    NSMutableURLRequest *mutableReq = [request mutableCopy];
    NSString *originalUrl = mutableReq.URL.absoluteString;
    NSURL *url = [NSURL URLWithString:originalUrl];
    if ([url.host isEqualToString:httpDNSHostJifen]){
        if (HttpDNSJifenIP()) {
            // 通过HTTPDNS获取IP成功，进行URL替换和HOST头设置
            NSLog(@"Get IP(%@) for host(%@) from HTTPDNS Successfully!", HttpDNSJifenIP(), url.host);
            NSRange hostFirstRange = [originalUrl rangeOfString:url.host];
            if (NSNotFound != hostFirstRange.location) {
                NSString *newUrl = [originalUrl stringByReplacingCharactersInRange:hostFirstRange withString:HttpDNSJifenIP()];
                NSLog(@"New URL: %@", newUrl);
                mutableReq.URL = [NSURL URLWithString:newUrl];
                //得在header中添加原域名的host，这步很重要必须得有
                [mutableReq setValue:url.host forHTTPHeaderField:@"host"];
                // 添加originalUrl保存原始URL
                [mutableReq addValue:originalUrl forHTTPHeaderField:@"originalUrl"];
            }
        }
    }
    return [mutableReq copy];
}
/**
 *  开始加载，在该方法中，加载一个请求
 */
- (void)startLoading {
    NSMutableURLRequest *request = [self.request mutableCopy];
    // 表示该请求已经被处理，防止无限循环
    [NSURLProtocol setProperty:@(YES) forKey:protocolKey inRequest:request];
    [self startRequest];
}
/**
 *  取消请求
 */
- (void)stopLoading {
    [self.session invalidateAndCancel];
    self.session = nil;
}

/**
 *  使用NSURLSession转发请求
 */
- (void)startRequest {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue currentQueue]];
    NSURLSessionTask *task = [_session dataTaskWithRequest:self.request];
    [task resume];
}

- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust
                  forDomain:(NSString *)domain {
    /*
     * 创建证书校验策略
     */
    NSMutableArray *policies = [NSMutableArray array];
    if (domain) {
        [policies addObject:(__bridge_transfer id) SecPolicyCreateSSL(true, (__bridge CFStringRef) domain)];
    } else {
        [policies addObject:(__bridge_transfer id) SecPolicyCreateBasicX509()];
    }
    /*
     * 绑定校验策略到服务端的证书上
     */
    SecTrustSetPolicies(serverTrust, (__bridge CFArrayRef) policies);
    /*
     * 评估当前serverTrust是否可信任，
     * 官方建议在result = kSecTrustResultUnspecified 或 kSecTrustResultProceed
     * 的情况下serverTrust可以被验证通过，https://developer.apple.com/library/ios/technotes/tn2232/_index.html
     * 关于SecTrustResultType的详细信息请参考SecTrust.h
     */
    SecTrustResultType result;
    SecTrustEvaluate(serverTrust, &result);
    return (result == kSecTrustResultUnspecified || result == kSecTrustResultProceed);
}

#pragma NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *_Nullable))completionHandler {
    if (!challenge) {
        return;
    }
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    NSURLCredential *credential = nil;
    /*
     * 获取原始域名信息。
     */
    NSString *host = [[self.request allHTTPHeaderFields] objectForKey:@"host"];
    if (!host) {
        host = self.request.URL.host;
    }
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if ([self evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:host]) {
            disposition = NSURLSessionAuthChallengeUseCredential;
            credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        } else {
            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        }
    } else {
        disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    }
    // 对于其他的challenges直接使用默认的验证方案
    completionHandler(disposition, credential);
}

#pragma NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    NSLog(@"receive response: %@", response);
    // 获取原始URL
    NSString* originalUrl = [dataTask.currentRequest valueForHTTPHeaderField:@"originalUrl"];
    if (!originalUrl) {
        originalUrl = response.URL.absoluteString;
    }
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSURLResponse *retResponse = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:originalUrl] statusCode:httpResponse.statusCode HTTPVersion:(__bridge NSString *)kCFHTTPVersion1_1 headerFields:httpResponse.allHeaderFields];
        [self.client URLProtocol:self didReceiveResponse:retResponse cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    } else {
        NSURLResponse *retResponse = [[NSURLResponse alloc] initWithURL:[NSURL URLWithString:originalUrl] MIMEType:response.MIMEType expectedContentLength:response.expectedContentLength textEncodingName:response.textEncodingName];
        [self.client URLProtocol:self didReceiveResponse:retResponse cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    }
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        [self.client URLProtocol:self didFailWithError:error];
    } else {
        [self.client URLProtocolDidFinishLoading:self];
    }
}

@end
