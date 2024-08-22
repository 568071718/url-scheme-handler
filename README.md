
WKWebView 资源缓存

## 集成  

* CocoaPods  
```
pod 'YXURLSchemeHandler', :git => 'https://gitee.com/568071718/url-scheme-handler.git'
```

## 使用  
```

WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];

// 配置自定义的 scheme handler
_urlSchemeHandler = [[YXURLSchemeHandler alloc] init];
[configuration setURLSchemeHandler:_urlSchemeHandler forURLScheme:YX_URL_SCHEME];

...

_webView = [[WKWebView alloc] initWithFrame:self.bounds configuration:configuration];

...

// 设置自定义的 url scheme
NSURL *url = [NSURL URLWithString:[YXURLSchemeHandler handleURLString:_urlString]];
NSURLRequest *request = [NSURLRequest requestWithURL:url];
[_webView loadRequest:request];

```


