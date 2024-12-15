
WKWebView 资源缓存  

---  

* [Github](https://github.com/568071718/url-scheme-handler)    
* [Gitee](https://gitee.com/568071718/url-scheme-handler)  

## 集成  

* CocoaPods  
```ruby 
# 以下源选择一个配置到项目 Podfile 文件，执行 pod install  

# Github  
pod 'YXURLSchemeHandler', :git => 'https://github.com/568071718/url-scheme-handler.git'  

# Gitee  
pod 'YXURLSchemeHandler', :git => 'https://gitee.com/568071718/url-scheme-handler.git'
```

## 使用  
```objc 

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


