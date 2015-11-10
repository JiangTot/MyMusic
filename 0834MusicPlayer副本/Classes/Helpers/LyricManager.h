//
//  LyricManager.h
//  0834MusicPlayer
//
//  Created by lanou3g on 15/11/10.
//  Copyright © 2015年 lanou3g. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LyricManager : NSObject
+(instancetype)sharedManager;

-(void)LoadLyricWith:(NSString *)lyricStr;
//对外的歌词数组
@property(nonatomic,strong)NSArray *allLyric;
/**
 *  根据播放时间获取到该播放的歌词的索引
 *
 *  @param time <#time description#>
 *
 *  @return <#return value description#>
 */
-(NSInteger)indexWith:(NSTimeInterval)time;
@end
