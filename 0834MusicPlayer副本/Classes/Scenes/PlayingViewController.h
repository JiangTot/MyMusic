//
//  PlayingViewController.h
//  0834MusicPlayer
//
//  Created by lanou3g on 15/11/5.
//  Copyright © 2015年 lanou3g. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayingViewController : UIViewController

+(instancetype)sharedPlayingPVC;
//播放第几首
@property (nonatomic, assign)NSInteger index;


@end
