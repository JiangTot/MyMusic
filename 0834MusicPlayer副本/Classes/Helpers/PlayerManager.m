//
//  PlayerManager.m
//  0834MusicPlayer
//
//  Created by lanou3g on 15/11/5.
//  Copyright © 2015年 lanou3g. All rights reserved.
//

#import "PlayerManager.h"
#import <AVFoundation/AVFoundation.h>

@interface PlayerManager ()

// 播放器  全局唯一 因为如果有两个音乐的话就会同时播放两个音乐
@property (nonatomic, strong) AVPlayer *player;

//计时器
@property(nonatomic,strong)NSTimer *timer;

@end

@implementation PlayerManager

static PlayerManager *manager = nil;

+ (PlayerManager *)sharedManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [PlayerManager new];
    });
    return manager;
}
//自动播放下一首
-(instancetype)init{
    if (self) {
        //添加通知中心，当self发出AVPlayerItemDidPlayToEndTimeNotification是触发playerDidPlayEnd:事件
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playerDidPlayEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    return self;
}
//实现通知中心的方法
-(void)playerDidPlayEnd:(NSNotification *)not{
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerDidPlayEnd)])  {
        //接收到item播放结束后，让代理去实现播放下一首
        [self.delegate playerDidPlayEnd];
    }

    
}



-(void)playWithUrlString:(NSString *)urlStr{
    //如果是切换歌曲，要先把正在播放的观察者移除掉
    if (self.player.currentItem) {
        [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    }
    
    //创建item
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:urlStr]];
    //对item 添加观察
    [item addObserver:self forKeyPath:@"status" options:(NSKeyValueObservingOptionNew) context:nil];
    
    
    //替换当前正在播放的音乐
    [self.player replaceCurrentItemWithPlayerItem:item];
    //开始播放(拿到下面)
 //   [self.player play];
    
}


-(void)play{
    [self.player play];
        _isPlaying = YES;
    
    
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(playingWithSeconds) userInfo:nil repeats:YES];
    
    }
    
-(void)playingWithSeconds{
    NSLog(@"%lld",self.player.currentTime.value/self.player.currentTime.timescale);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerPlayingWithTime:)]) {
        
        //计算一下播放器正在播放的秒数
        NSTimeInterval time = self.player.currentTime.value/self.player.currentTime.timescale;
        [_delegate playerPlayingWithTime:time];
    }
}


-(void)pause{
    [self.player pause];
    //暂停播放后设为NO
    _isPlaying = NO;
    
    //使计时器失效并置为空
    [self.timer invalidate];
    self.timer = nil;
}

// 改变进度
-(void)seekToTime:(NSTimeInterval)time{
    //先暂停
    [self pause];
    [self.player seekToTime:CMTimeMakeWithSeconds(time, self.player.currentTime.timescale) completionHandler:^(BOOL finished) {
        if (finished) {
            //拖拽成功后在播放
            [self play];
        }
    }];
}

//设置音量重写set方法
-(void)setSound:(float)sound{
    self.player.volume = sound;
}

//重写get方法
-(float)sound{
    return self.player.volume;
}


#pragma mark --lazy load
-(AVPlayer *)player{
    if (!_player) {
        _player = [AVPlayer new];
    }
    return _player;
}

#pragma mark -- 观察响应(当观察的值发生变化的时候出发的事件)
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    NSLog(@"%@",keyPath);
    NSLog(@"%@",change);
    //状态变化后的新值
    AVPlayerItemStatus status = [change[@"new"]integerValue];
    switch (status) {
        case AVPlayerItemStatusFailed:
            NSLog(@"加载失败");
            break;
        case AVPlayerItemStatusUnknown:
            NSLog(@"资源不对");
        case AVPlayerItemStatusReadyToPlay:
            NSLog(@"准备播放");
            //开始播放
            //先暂停，将NSTimer销毁，然然后在播放，创建NSTimer
        
            [self pause];
            [self play];
            break;
        default:
            break;
    }
    
}

@end