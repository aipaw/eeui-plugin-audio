//
//  audioModule.m
//  Pods
//

#import "audioModule.h"
#import "audio.h"
#import "DeviceUtil.h"
#import "eeuiViewController.h"
#import <WeexPluginLoader/WeexPluginLoader.h>
#import <AVFoundation/AVFoundation.h>

static WXModuleKeepAliveCallback callback;

@interface audioModule ()
@end

@implementation audioModule

@synthesize weexInstance;

WX_PlUGIN_EXPORT_MODULE(eeuiAudio, audioModule)
WX_EXPORT_METHOD(@selector(play:))
WX_EXPORT_METHOD(@selector(pause))
WX_EXPORT_METHOD(@selector(stop))
WX_EXPORT_METHOD(@selector(seek:))
WX_EXPORT_METHOD_SYNC(@selector(isPlay))
WX_EXPORT_METHOD(@selector(volume:))
WX_EXPORT_METHOD(@selector(loop:))
WX_EXPORT_METHOD(@selector(setCallback:))
WX_EXPORT_METHOD(@selector(getDuration:call:))

-(void)play:(NSString*)url{
    url = [DeviceUtil rewriteUrl:url mInstance:weexInstance];
    if(![self.url isEqualToString:url]){
        self.url = url;
        [[audio sharedManager] playFromURL:[NSURL URLWithString:url]];
    }else{
        if (![audio sharedManager].isPlaying) {
            [[audio sharedManager] pause];
        }
    }
    [self addListener];
}

-(void)addListener{
    __weak typeof (self) weakself = self;
    [audio sharedManager].onStateChange = ^(FSAudioStreamState state) {
        if (state == kFsAudioStreamPlaying){
            [weakself onCallback:@"start"];
            [weakself releaseTimer];
            weakself.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:weakself selector:@selector(updateProcess) userInfo:nil repeats:YES];
            [weakself.timer fire];
        } if (state == kFsAudioStreamPlaybackCompleted){
            NSString *url = weakself.url;
            if (weakself.loop) {
                weakself.url = nil;
                [weakself releaseTimer];
                [weakself stop];
                [weakself play:url];
            }else{
                [weakself onCallback:@"compelete"];
                weakself.url = nil;
                [weakself releaseTimer];
            }
        } if (state == kFsAudioStreamFailed){
            [weakself onCallback:@"error"];
        } if (state == kFsAudioStreamSeeking){
            [weakself onCallback:@"seek"];
        } if (state == kFsAudioStreamBuffering){
            [weakself onCallback:@"buffering"];
        }
    };
}

-(void)updateProcess{
    if ([audio sharedManager].isPlaying) {
        [self onCallback:@"play"];
    }
}

-(void)pause{
    if ([audio sharedManager].isPlaying) {
        [[audio sharedManager] pause];
    }
}

-(void)stop{
    self.url = nil;
    [self releaseTimer];
    [[audio sharedManager] stop];
}

-(void)seek:(float)current{
    unsigned total = ([audio sharedManager].duration.minute * 60 + [audio sharedManager].duration.second) * 1000;
    float percent = (float)current / total;
    FSStreamPosition position;
    position.position = MIN(1, MAX(0, percent));
    [[audio sharedManager] seekToPosition:position];
}

-(BOOL)isPlay{
    return [audio sharedManager].isPlaying;
}

-(void)volume:(float)vol{
    [audio sharedManager].volume = vol;
}

-(void)loop:(id)loop{
    self.loop = [WXConvert BOOL:loop];
}

-(void)setCallback:(WXModuleKeepAliveCallback)call{
    callback = call;
}

-(void)onCallback:(NSString*)status{
    if (callback) {
        unsigned current = ([audio sharedManager].currentTimePlayed.minute * 60 + [audio sharedManager].currentTimePlayed.second) * 1000;
        unsigned duration = ([audio sharedManager].duration.minute * 60 + [audio sharedManager].duration.second) * 1000;
        float percent = (float)current / duration;
        callback(@{@"status":status, @"url":_url.length > 0 ? _url : @"", @"current":@(current),@"duration": @(duration),@"percent":@(percent)}, true);
    }
}

-(void)getDuration:(NSString *)url call:(WXModuleCallback)call{
    if (call && url.length > 0) {
        url = [DeviceUtil rewriteUrl:url mInstance:weexInstance];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSUInteger duration = 0;
            AVURLAsset*audioAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:url] options:nil];
            CMTime audioDuration = audioAsset.duration;
            float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
            if (audioDurationSeconds > 0) {
                duration = audioDurationSeconds * 1000;
            }
            call(@{@"url":url, @"duration": @(duration)});
        });
    }
}

-(void)releaseTimer{
    if (_timer) {
        if ([_timer isValid]) {
            [_timer invalidate];
            _timer = nil;
        }
    }
}

- (void)dealloc {
    [self releaseTimer];
}

@end
