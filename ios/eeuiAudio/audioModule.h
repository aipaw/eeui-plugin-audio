//
//  audioModule.h
//  Pods
//

#import <Foundation/Foundation.h>
#import "WeexSDK.h"

@interface audioModule : NSObject <WXModuleProtocol>

@property(nonatomic, strong) NSString *url;
@property(nonatomic, weak) NSTimer *timer;
@property(nonatomic, assign) BOOL loop;

@end
