//
//  ViewController.m
//  HttpDNSDemo
//
//  Created by ZhiLi on 2016/11/24.
//  Copyright © 2016年 ZhiLi. All rights reserved.
//

#import "ViewController.h"
#import "IPAddressClient.h"
#import "WebViewController.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIButton *requestBtn;
@property (strong, nonatomic) IBOutlet UIButton *webViewBtn;
@property (strong, nonatomic) IBOutlet UILabel *showLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)webViewBtnAction:(id)sender {
    WebViewController *webVC = [[WebViewController alloc] init];
    [self.navigationController pushViewController:webVC animated:YES];
}

- (IBAction)requestDataAction:(id)sender {
    [IPAddressClient getIPAddressDataSuccuss:^(DNSResponse *respose) {
        NSDictionary *jsonDictionary = [MTLJSONAdapter JSONDictionaryFromModel:respose.result error:nil];
        self.showLabel.text = [jsonDictionary description];
    } failure:^(NSError *error) {
        self.showLabel.text = error.description;
    }];
}

@end
