iOS dangerous webview practice
========
You can force [`UIWebView`] to show web pages with invalid certificates. This
sample app precisely allows a few predefined domains, rather than blindly
allowing all insecure HTTPS loads.

You don't need to go through the whole source codes. Just take a look at the two
source files.

### 1. [ViewController.m]
Using [`UIWebViewDelegate`], it intercepts the HTTPS requests before it fails. The
[answers in stack overflow][ref1] solve this problem with a few codes but it
doesn't cover all corner cases. To do this in production, The logic gets quite
complicated. You'll have read the whole codes of [ViewController.m].

### 2. [Info.plist]
It makes a few exceptions to the iOS's App Transport Security. You'll have to
configure it, server-by-server.

```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSExceptionDomains</key>
  <dict>
    <key>m.busan.go.kr</key>
    <dict>
      <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key><true/>
      <key>NSTemporaryExceptionRequiresForwardSecrecy</key><false/>
    </dict>
    <key>www.busan.go.kr</key>
    <dict>
      <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key><true/>
      <key>NSTemporaryExceptionRequiresForwardSecrecy</key><false/>
    </dict>
  </dict>
</dict>
```

###### References
- [UIWebView to view self signed websites - is it possible?][ref1] - stack overflow
- [Configuring App Transport Security Exceptions in iOS 9 and OSX 10.11][ref2] - by Steven Peterson

<br>

--------
*ios-dangerous-webview-practice* is primarily distributed under the terms of
both the [MIT license] and the [Apache License (Version 2.0)]. See [COPYRIGHT]
for details.

[`UIWebView`]: https://developer.apple.com/reference/uikit/uiwebview
[`UIWebViewDelegate`]: https://developer.apple.com/reference/uikit/uiwebviewdelegate
[ViewController.m]: ios-dangerous-webview-practice/ViewController.m
[Info.plist]: ios-dangerous-webview-practice/Info.plist
[ref1]: http://stackoverflow.com/q/11573164
[ref2]: https://ste.vn/2015/06/10/configuring-app-transport-security-ios-9-osx-10-11/
[MIT license]: LICENSE-MIT
[Apache License (Version 2.0)]: LICENSE-APACHE
[COPYRIGHT]: COPYRIGHT
