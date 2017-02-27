#import "ViewController.h"

@implementation ViewController {
    NSURLRequest *_failedRequest;
    NSMutableDictionary *_isTrusted;
}

@synthesize dangerousWebView;

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // TODO: 왜 WebViewDelegate가 Self여야할까
    dangerousWebView.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view, typically from a nib.
    _isTrusted = @{
        @"www.busan.go.kr": @NO,
        @"m.busan.go.kr": @NO,
        @"logger.busan.go.kr": @NO,
    }.mutableCopy;

    NSURL *url = [NSURL URLWithString:@"https://m.busan.go.kr"];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [dangerousWebView loadRequest:requestObj];
}

- (BOOL)webView:(UIWebView *)__unused webView
    shouldStartLoadWithRequest:(NSURLRequest *)request
                navigationType:(UIWebViewNavigationType)__unused navigationType
{
    NSLog(@"HTTP 요청 발생 : %@", request.URL);

    // HTTPS 요청이 아닐경우 바로 통과
    if (![request.URL.scheme isEqualToString:@"https"]) { return YES; }

    // 이미 강제인증을 거친 도메인일 경우 통과
    const NSString * const hostname = request.URL.host;
    id entry = _isTrusted[hostname];
    if (entry == nil || ((NSNumber*) entry).boolValue) { return YES; }

    // 강제인증 시작
    NSLog(@"\"%@\" 도메인 강제인증 시도", hostname);
    _failedRequest = request;
    // TODO: 왜 NSURLConnectionDelegate가 Self여야할까
    [NSURLConnection connectionWithRequest:request delegate:self];
    return NO;
}

-(void)connection:(NSURLConnection *)__unused connection
    willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    id entry;

    if (![challenge.protectionSpace.authenticationMethod
        isEqualToString:NSURLAuthenticationMethodServerTrust]) { goto FALLBACK; }

    entry = _isTrusted[challenge.protectionSpace.host];
    if (entry == nil) { goto FALLBACK; }
    if (((NSNumber*)entry).boolValue) { goto FALLBACK; }

    NSLog(@"\"%@\"의 인증서를 신뢰하도록 설정함", challenge.protectionSpace.host);
    [challenge.sender
        useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]
        forAuthenticationChallenge:challenge
    ];
    _isTrusted[challenge.protectionSpace.host] = @YES;
    return;

FALLBACK:
    [challenge.sender
        performDefaultHandlingForAuthenticationChallenge:challenge];
}

-(void)connection:(NSURLConnection *)connection
    didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"응답 수신함 : %@", [response URL]);
    [connection cancel];
    [dangerousWebView loadRequest:_failedRequest];
}

@end
