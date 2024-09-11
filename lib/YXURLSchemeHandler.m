
#import "YXURLSchemeHandler.h"
#import <CommonCrypto/CommonDigest.h>

NSString *const YX_URL_SCHEME = @"com.yx.url.scheme";

@interface YXURLSchemeHandler ()

/**
 * 记录任务状态
 * key = md5 url
 * value = int   1表示任务已停止
 */
@property (strong ,nonatomic) NSMutableDictionary *taskComplet;
@end

@implementation YXURLSchemeHandler

#pragma mark - hook
- (void)webView:(nonnull WKWebView *)webView startURLSchemeTask:(nonnull id<WKURLSchemeTask>)urlSchemeTask {
    __weak typeof(self) _self = self;
    
    NSURL *URL = urlSchemeTask.request.URL;
    NSString *urlString = URL.absoluteString;
    NSString *originURLString = [URL.absoluteString stringByReplacingOccurrencesOfString:YX_URL_SCHEME withString:@"http"];
    NSString *md5URLString = [YXURLSchemeHandler MD5String:originURLString];
    
    if (_taskComplet == nil) {
        _taskComplet = [NSMutableDictionary dictionary];
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dataDirectory = [YXURLSchemeHandler dataDirectory];
    if ([fileManager fileExistsAtPath:dataDirectory] == NO) {
        [fileManager createDirectoryAtPath:dataDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *responseDirectory = [YXURLSchemeHandler responseDirectory];
    if ([fileManager fileExistsAtPath:responseDirectory] == NO) {
        [fileManager createDirectoryAtPath:responseDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *dataFilePath = [NSString stringWithFormat:@"%@/%@" ,dataDirectory ,md5URLString];
    NSString *responseFilePath = [NSString stringWithFormat:@"%@/%@" ,responseDirectory ,md5URLString];
    
#if DEBUG
    NSLog(@"⚽️ 拦截到请求的地址: %@", urlString);
    NSLog(@"⚽️ 原始的请求地址: %@", originURLString);
    NSLog(@"⚽️ 原始的请求地址MD5: %@" ,md5URLString);
    NSLog(@"⚽️ 文件缓存地址: %@", dataFilePath);
    NSLog(@"⚽️ 响应缓存地址: %@" ,responseFilePath);
#endif
    
    NSData *data = [NSData dataWithContentsOfFile:dataFilePath];
    NSURLResponse *response = [NSKeyedUnarchiver unarchiveObjectWithFile:responseFilePath];
    
    if (data && response) {
        [self safeReceiveResponse:response data:data urlSchemeTask:urlSchemeTask identifier:md5URLString];
#if DEBUG
        NSLog(@"⚽️ 使用本地缓存的数据");
#endif
        return;
    }
    
#if DEBUG
    NSLog(@"⚽️ 无缓存数据，开始请求数据: %@" ,originURLString);
#endif
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[[NSURL URLWithString:originURLString] URLByResolvingSymlinksInPath]];
    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
#if DEBUG
        NSHTTPURLResponse *httpResponse = nil;
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            httpResponse = (NSHTTPURLResponse *)response;
        }
        NSLog(@"⚽️ 请求结束: [%@] %@" ,@(httpResponse.statusCode),originURLString);
#endif
        if (data) {
            
            [_self safeReceiveResponse:response data:data urlSchemeTask:urlSchemeTask identifier:md5URLString];
            
            // 过滤掉一些不需要缓存的文件
            if ([response.MIMEType containsString:@"text/html"]) {
#if DEBUG
                NSLog(@"⚽️ 数据缓存失败，此类文件无需缓存: %@" ,originURLString);
#endif
                return;
            }
            
            // 数据写入本地
            BOOL ret = [data writeToFile:dataFilePath atomically:YES];
#if DEBUG
            if (ret) {
                NSLog(@"⚽️ 数据缓存成功: %@" ,dataFilePath);
            } else {
                NSLog(@"⚽️ 数据缓存失败: %@" ,dataFilePath);
            }
#endif
            
            ret = [NSKeyedArchiver archiveRootObject:response toFile:responseFilePath];
#if DEBUG
            if (ret) {
                NSLog(@"⚽️ response 缓存成功: %@" ,responseFilePath);
            } else {
                NSLog(@"⚽️ response 缓存失败: %@" ,responseFilePath);
            }
#endif
        } else {
#if DEBUG
            NSLog(@"⚽️ 文件下载失败: %@" ,originURLString);
#endif
            [_self safeFailWithError:error urlSchemeTask:urlSchemeTask identifier:md5URLString];
        }
    }];
    [task resume];
}

- (void)webView:(nonnull WKWebView *)webView stopURLSchemeTask:(nonnull id<WKURLSchemeTask>)urlSchemeTask {
    // nothing
#if DEBUG
    NSLog(@"%s" ,__func__);
#endif
    NSURL *URL = urlSchemeTask.request.URL;
    NSString *urlString = URL.absoluteString;
    NSString *originURLString = [URL.absoluteString stringByReplacingOccurrencesOfString:YX_URL_SCHEME withString:@"http"];
    NSString *md5URLString = [YXURLSchemeHandler MD5String:originURLString];
    _taskComplet[md5URLString] = @(1);
}

- (void)safeReceiveResponse:(NSURLResponse *)response data:(NSData *)data urlSchemeTask:(id <WKURLSchemeTask>)urlSchemeTask identifier:(id)identifier {
    id value = _taskComplet[identifier];
    if ([value respondsToSelector:@selector(integerValue)]) {
        if ([value integerValue] == 1) {
            return;
        }
    }
    @try {
        [urlSchemeTask didReceiveResponse:response];
        [urlSchemeTask didReceiveData:data];
        [urlSchemeTask didFinish];
    } @catch (NSException *exception) {
#if DEBUG
        NSLog(@"⚽️ Receive response crash: %@" ,exception);
#endif
    }
}

- (void)safeFailWithError:(NSError *)error urlSchemeTask:(id <WKURLSchemeTask>)urlSchemeTask identifier:(id)identifier {
    id value = _taskComplet[identifier];
    if ([value respondsToSelector:@selector(integerValue)]) {
        if ([value integerValue] == 1) {
            return;
        }
    }
    @try {
        [urlSchemeTask didFailWithError:error];
    } @catch (NSException *exception) {
#if DEBUG
        NSLog(@"⚽️ Did fail crash: %@" ,exception);
#endif
    }
}

#pragma mark - cache

+ (NSString *)root {
    NSString *result = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    result = [result stringByAppendingPathComponent:@"com.yx.web.cache"];
    return result;
}
+ (NSString *)dataDirectory {
    NSString *result = [YXURLSchemeHandler root];
    result = [result stringByAppendingPathComponent:@"source-data"];
    return result;
}
+ (NSString *)responseDirectory {
    NSString *result = [YXURLSchemeHandler root];
    result = [result stringByAppendingPathComponent:@"response-data"];
    return result;
}

+ (void)removeAllWebCache {
    NSString *path = [YXURLSchemeHandler root];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
}

#pragma mark - utils
+ (NSString *)MD5String:(NSString *)string; {
    // Create pointer to the string as UTF8
    const char *ptr = [string UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, (unsigned int)strlen(ptr), md5Buffer);
    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x",md5Buffer[i]];
    }
    return output;
}

+ (NSString *)fixURLString:(NSString *)urlString {
    if ([urlString containsString:@".html"]) { return urlString; }
    if ([urlString hasSuffix:@"/"]) { return urlString; }
    if ([urlString containsString:@"/?"]) { return urlString; }
    if ([urlString containsString:@"?"]) {
        return [urlString stringByReplacingOccurrencesOfString:@"?" withString:@"/?"];
    }
    return [NSString stringWithFormat:@"%@/",urlString];
}

+ (NSString *)handleURLString:(NSString *)urlString {
    urlString = [YXURLSchemeHandler fixURLString:urlString];
    if ([urlString containsString:@"https:"]) {
        return [urlString stringByReplacingOccurrencesOfString:@"https:" withString:[NSString stringWithFormat:@"%@:",YX_URL_SCHEME]];
    }
    if ([urlString containsString:@"http:"]) {
        return [urlString stringByReplacingOccurrencesOfString:@"http:" withString:[NSString stringWithFormat:@"%@:",YX_URL_SCHEME]];
    }
    return urlString;
}

@end
