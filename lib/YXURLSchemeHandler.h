
#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

/**
 * 约定的自定义 url scheme
 */
extern NSString * _Nonnull const YX_URL_SCHEME;

NS_ASSUME_NONNULL_BEGIN

/**
 * https://gitee.com/568071718/url-scheme-handler
 */
@interface YXURLSchemeHandler : NSObject <WKURLSchemeHandler>

/**
 * 将 url scheme 替换为自定义 scheme: YX_URL_SCHEME
 * 只有替换为自定义 scheme 才能触发自定义资源管理
 */
+ (NSString *)handleURLString:(NSString *)urlString;

/**
 * 文件缓存目录
 */
+ (NSString *)cacheRoot;

/**
 * 清除缓存
 */
+ (void)removeAllWebCache;

/**
 * 不需要缓存的资源类型
 * 根据 response 的 MIMEType 来判断的，当一个资源加载完成后，会根据这个配置来确定资源是否缓存到本地，如果资源类型是这个数组里面包含的类型则跳过本地缓存
 * 默认为 [ "text/html" ]，也就是默认情况下 html 类型的文件不做缓存
 * 可以设置为 nil 或空数组缓存所有类型的资源
 */
@property (strong ,nonatomic ,nullable) NSArray <NSString *>*excludeTypes;
@end

NS_ASSUME_NONNULL_END
