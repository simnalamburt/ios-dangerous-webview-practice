//
//  ViewController.h
//  ios-dangerous-webview-practice
//
//  Created by 김지현 on 2017. 2. 24..
//  Copyright © 2017년 hyeonme. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *dangerousWebView;

@end

