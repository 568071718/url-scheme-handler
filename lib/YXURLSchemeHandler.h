
#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

extern NSString * _Nonnull const YX_URL_SCHEME;

NS_ASSUME_NONNULL_BEGIN

/**
 * https://gitee.com/568071718/url-scheme-handler
 */
@interface YXURLSchemeHandler : NSObject <WKURLSchemeHandler>

+ (NSString *)handleURLString:(NSString *)urlString;

+ (void)removeAllWebCache;
@end

NS_ASSUME_NONNULL_END
