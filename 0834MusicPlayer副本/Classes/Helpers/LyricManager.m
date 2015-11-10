//
//  LyricManager.m
//  0834MusicPlayer
//
//  Created by lanou3g on 15/11/10.
//  Copyright © 2015年 lanou3g. All rights reserved.
//




/**
 *
 [00:10.440]It's been a long day without you my friend
 [00:17.400]And I'll tell you all about it when I see you again
 [00:23.200]We've come a long way from where we began
 [00:29.080]Oh I'll tell you all about it when I see you again
 [00:35.100]When I see you again
 [00:39.920]Damn who knew all the planes we flew
 [00:42.900]Good things we've been through
 [00:44.610]That I'll be standing right here
 *
 *  @param lyricString
 */



#import "LyricManager.h"
#import "LyricModel.h"

@interface LyricManager  ()
//用来存放歌词
@property(nonatomic,strong)NSMutableArray *lyrics;

@end



@implementation LyricManager
static LyricManager *manager = nil;
+(instancetype)sharedManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [LyricManager new];
    });
    
    return manager;
}

-(void)LoadLyricWith:(NSString *)lyricStr{
    // 1 分行
    NSMutableArray *lyricStringArray = [[lyricStr componentsSeparatedByString:@"\n"]mutableCopy];
    
    [lyricStringArray removeLastObject];
    
    
    //先将之前的歌词移除
    [self.lyrics removeAllObjects];
    for (NSString * str in lyricStringArray) {
        
//        if ([str isEqualToString:@""]) {
//            continue;
//        }
        // 分开时间个歌词
        NSArray *timeAndLtric = [str componentsSeparatedByString:@"]"];
        //3 去掉时间左边的“【”
        NSString *time = [timeAndLtric[0] substringFromIndex:1];
        //4
        NSArray *minuteAndSecond = [time componentsSeparatedByString:@":"];
        //分
        NSInteger minute = [minuteAndSecond[0] integerValue];
        //秒
        double second = [minuteAndSecond[1]doubleValue];
        // 5 装成一个model
        LyricModel *model = [[LyricModel alloc]initWithTime:(minute*60 +second) lyric:timeAndLtric[1]];
        // 6 添加到数组中
        [self.lyrics addObject:model];
        
    }
   
    
}
-(NSMutableArray *)lyrics{
    if (!_lyrics) {
        _lyrics = [NSMutableArray new];
    }
    return _lyrics;
}
//保证数据安全

-(NSArray *)allLyric{
    return self.lyrics;
}
//实现接口方法
-(NSInteger)indexWith:(NSTimeInterval)time{
    NSInteger index = 0;
    //遍历数组，找到还没有播放的那一句歌词
    for (int i = 0; i < self.lyrics.count; i ++) {
        LyricModel *model = self.lyrics[i];
        if (model.time > time) {
            //注意如果是第 0 个元素，而且元素时间比要播放的时间大，i- 1 就会小于0 这样tableView就会ctash
           index  = ( i - 1 > 0)? i - 1 : 0;
            //一定要break,要不就会一直循环下去
            break;
        }
        
    }
    return index;
    
}

@end
