//
//  JWZTAudioLengthTool.m
//  BTVMobileCaster
//
//  Created by 肖兆强 on 2017/8/3.
//  Copyright © 2017年 JWZTLive. All rights reserved.
//

#import "ZQAudioLengthTool.h"
#import <AVFoundation/AVFoundation.h>

@implementation ZQAudioLengthTool


+ (NSUInteger)durationWithVideo:(NSURL *)videoUrl
{
    
    AVURLAsset*audioAsset=[AVURLAsset URLAssetWithURL:videoUrl options:nil];
    CMTime audioDuration=audioAsset.duration;
    float audioDurationSeconds=CMTimeGetSeconds(audioDuration);
    if (audioDurationSeconds>0) {
        
        NSUInteger interValue = (audioDurationSeconds *10+5)/10;
        
        return interValue;
        
    }
    
    return 0;
}

@end
