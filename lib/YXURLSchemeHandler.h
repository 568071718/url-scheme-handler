//
//  YXURLSchemeHandler.h
//  dazz
//
//  Created by ooc on 2024/8/19.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

extern NSString * _Nonnull const YX_URL_SCHEME;

NS_ASSUME_NONNULL_BEGIN

@interface YXURLSchemeHandler : NSObject <WKURLSchemeHandler>

+ (NSString *)handleURLString:(NSString *)urlString;

+ (void)removeAllWebCache;
@end

NS_ASSUME_NONNULL_END
