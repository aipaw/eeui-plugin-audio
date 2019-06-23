//
//  audio.h
//  Pods
//

#import <Foundation/Foundation.h>
#import <FSAudioStream.h>

@interface audio : NSObject

+(FSAudioStream*)sharedManager;

@end
