//
//  ViewController.m
//  ios-dangerous-webview-practice
//
//  Created by 김지현 on 2017. 2. 24..
//  Copyright © 2017년 hyeonme. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController {
    BOOL _authenticated;
    NSURLRequest *_failedRequest;
}

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
    NSLog(@"HTTP 요청 발생 : %@ (인증 %s)", request.URL, _authenticated ? "성공" : "실패");

    if (!_authenticated) {
        NSLog(@"정상적인 방법으로 진행 불가, 우회 시작 : %@", request.URL);

        _failedRequest = request;
        [[NSURLConnection alloc] initWithRequest:request delegate:self];
        return NO;
    }
    return YES;
}

-(void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    NSLog(@"인증 챌린지 시작 : %@", _failedRequest.URL);
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        // TODO: 특정 도메인만 허용하기
        // NSURL* baseURL = [NSURL URLWithString:_BaseRequest];
        NSURL* baseURL = _failedRequest.URL;

        if ([challenge.protectionSpace.host isEqualToString:baseURL.host]) {
            NSLog(@"인증서 신뢰하도록 설정 : %@", challenge.protectionSpace.host);

            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
        } else {
            NSLog(@"인증서 신뢰하지 않은채로 둠 : %@", challenge.protectionSpace.host);
        }
    }
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"응답 수신함 : %@", [response URL]);
    _authenticated = YES;
    [connection cancel];
    [_dangerousWebView loadRequest:_failedRequest];
}

@end
