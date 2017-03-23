#import "ViewController.h"

@implementation ViewController {
    NSURLRequest *_failedRequest;
    NSMutableDictionary *_isTrusted;
}

@synthesize dangerousWebView;

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view, typically from a nib.
    _failedRequest = nil;
    _isTrusted = @{
        @"www.domain.go.kr": @NO,
        @"m.domain.go.kr": @NO,
        @"logger.domain.go.kr": @NO,
        @"mail.metro.domain.kr": @NO,
    }.mutableCopy;

    NSURL *url = [NSURL URLWithString:@"https://m.domain.go.kr"];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [dangerousWebView loadRequest:requestObj];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    dangerousWebView.delegate = self;
}

- (BOOL)webView:(UIWebView *)__unused webView
    shouldStartLoadWithRequest:(NSURLRequest *)request
                navigationType:(UIWebViewNavigationType)__unused navigationType
{
    // Pass if it is not a HTTPS request
    if (![request.URL.scheme isEqualToString:@"https"]) { return YES; }

    // Pass if its certificate is already trusted
    const NSString * const hostname = request.URL.host;
    id entry = _isTrusted[hostname];
    if (entry == nil || ((NSNumber*) entry).boolValue) { return YES; }

    // Start trusting invalid certificate procedure.
    // `willSendRequestForAuthenticationChallenge` will be invoked.
    _failedRequest = request;
    [NSURLConnection connectionWithRequest:request delegate:self];
    return NO;
}

-(void)connection:(NSURLConnection *)__unused connection
    willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    id entry;

    // Pass if current authentication challenge is not about server trust
    if (![challenge.protectionSpace.authenticationMethod
        isEqualToString:NSURLAuthenticationMethodServerTrust]) { goto FALLBACK; }

    entry = _isTrusted[challenge.protectionSpace.host];
    // Pass if the requested domain is not in the predefined domain list
    if (entry == nil) { goto FALLBACK; }
    // Pass if the requested domain was already trusted
    if (((NSNumber*)entry).boolValue) { goto FALLBACK; }

    // Trust the certificate
    [challenge.sender
        useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]
        forAuthenticationChallenge:challenge
    ];
    // Memo that the domain is trusted now
    _isTrusted[challenge.protectionSpace.host] = @YES;
    return;

FALLBACK:

    // Fallback to the default authentication procedure
    [challenge.sender
        performDefaultHandlingForAuthenticationChallenge:challenge];
}

-(void)connection:(NSURLConnection *)connection
    didReceiveResponse:(NSURLResponse *)__unused response
{
    [connection cancel];
    [dangerousWebView loadRequest:_failedRequest];
}

@end
