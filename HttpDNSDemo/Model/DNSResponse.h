//
//  DNSResponse.h
//  HttpDNSDemo
//
//  Created by ZhiLi on 2016/11/24.
//  Copyright © 2016年 ZhiLi. All rights reserved.
//

#import <Overcoat/Overcoat.h>

@class DNSResponse;

typedef void(^DNSRequestCompleteBlock)(DNSResponse * response);
typedef void(^DNSRequestFailedBlock)(NSError * error);

@interface DNSResponse : OVCResponse

@property (nonatomic, assign) NSInteger status;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *tips;

@end
