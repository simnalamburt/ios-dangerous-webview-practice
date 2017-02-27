@import UIKit;

@interface ViewController : UIViewController <UIWebViewDelegate, NSURLConnectionDataDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *dangerousWebView;

@end
