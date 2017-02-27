#import "ViewController.h"

@implementation ViewController {
    BOOL _authenticated;
    NSURLRequest *_failedRequest;
    // TODO: Don't do this
    NSUInteger _retryCount;
}

@synthesize dangerousWebView;

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    dangerousWebView.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view, typically from a nib.
    NSURL *url = [NSURL URLWithString:@"https://m.busan.go.kr"];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [dangerousWebView loadRequest:requestObj];
}

- (BOOL)webView:(UIWebView *)__unused webView
    shouldStartLoadWithRequest:(NSURLRequest *)request
                navigationType:(UIWebViewNavigationType)__unused navigationType
{
    NSLog(@"HTTP 요청 발생 : %@ (인증 %s)", request.URL, _authenticated ? "성공" : "실패");

    // TODO: Don't do this
    BOOL condition =
        _retryCount < 1 &&
        [request.URL.scheme isEqualToString:@"https"] &&
        [request.URL.host isEqualToString:@"www.busan.go.kr"];
    if (condition) {
        NSLog(@"강제 인증 우회 시도 (%lu번째 시도)", _retryCount);
        _authenticated = NO;
        _retryCount += 1;
    }

    if (!_authenticated) {
        NSLog(@"정상적인 방법으로 진행 불가, 우회 시작 : %@", request.URL);

        _failedRequest = request;
        [NSURLConnection connectionWithRequest:request delegate:self];
        return NO;
    }
    return YES;
}

-(void)connection:(NSURLConnection *)__unused connection
    willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
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
    [dangerousWebView loadRequest:_failedRequest];
}

@end
