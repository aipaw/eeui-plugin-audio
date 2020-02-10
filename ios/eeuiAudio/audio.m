//
//  audio.m
//  Pods
//

#import "audio.h"
#import "WeexInitManager.h"
#import <WebKit/WKWebView.h>

@implementation audio

+ (FSAudioStream*) sharedManager {
    static dispatch_once_t onceToken;
    static FSAudioStream *instance;
    dispatch_once(&onceToken, ^{
        instance = [[FSAudioStream alloc] init];
        instance.strictContentTypeChecking = NO;
        instance.defaultContentType = @"audio/mpeg";
    });
    return instance;
}

@end
