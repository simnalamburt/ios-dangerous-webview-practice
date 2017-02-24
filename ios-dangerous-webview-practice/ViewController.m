//
//  ViewController.m
//  ios-dangerous-webview-practice
//
//  Created by 김지현 on 2017. 2. 24..
//  Copyright © 2017년 hyeonme. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

-(void)viewWillAppear:(BOOL)animated {
    _dangerousWebView.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view, typically from a nib.
    NSURL *url = [NSURL URLWithString:@"https://m.busan.go.kr"];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [_dangerousWebView loadRequest:requestObj];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"HTTP 요청 발생  URL: %@", request.URL);
    return YES;
}

@end
