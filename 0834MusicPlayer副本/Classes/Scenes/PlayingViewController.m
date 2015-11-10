//
//  PlayingViewController.m
//  0834MusicPlayer
//
//  Created by lanou3g on 15/11/5.
//  Copyright © 2015年 lanou3g. All rights reserved.
//

#import "PlayingViewController.h"
#import "PlayerManager.h"
#import "DataManager.h"
#import "MusicModel.h"
#import "UIImageView+WebCache.h"
#import "LyricManager.h"
#import "LyricModel.h"

@interface PlayingViewController ()<PlayerManagerDelegate,UITableViewDataSource,UITableViewDelegate>

//记录一下当前播放的音乐的索引
@property(nonatomic,assign)NSInteger currentIndex;

//记录当前正在播放的音乐
@property(nonatomic,strong)MusicModel *currentModel;


@property (strong, nonatomic) IBOutlet UILabel *songName;

@property (strong, nonatomic) IBOutlet UILabel *singerName;

@property (strong, nonatomic) IBOutlet UIImageView *imgView;

@property (strong, nonatomic) IBOutlet UISlider *sliderrTime;

@property (strong, nonatomic) IBOutlet UISlider *sliderVolume;

@property (strong, nonatomic) IBOutlet UILabel *playTimeLabel;

@property (strong, nonatomic) IBOutlet UILabel *lastTimeLabel;

- (IBAction)ActionLast:(UIButton *)sender;

- (IBAction)actionPlayOrPause:(UIButton *)sender;

- (IBAction)actionNext:(UIButton *)sender;

- (IBAction)actionChangeTime:(UISlider *)sender;

- (IBAction)actionChangeVolume:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *btnPlayOrPause;

@property (strong, nonatomic) IBOutlet UITableView *tableViewLyric;

@property (strong, nonatomic) IBOutlet UIButton *nsxtButton;


@end
static NSString *cellIdentifier = @"cell";
static PlayingViewController *playingVC = nil;

@implementation PlayingViewController
+(instancetype)sharedPlayingPVC{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        //拿到main sb
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        //在main sb 拿到我们要用的视图控制器
        playingVC = [sb instantiateViewControllerWithIdentifier:@"playingVC"];
    });
    return playingVC;
    
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //如果要播放的音乐和当前播放的音乐一样，就什么都不干
    if (_index == _currentIndex) {
        return;
    }else{
        //如果不等于，
        _currentIndex = _index;
    }
    
    [self startPlay];
}
//
-(void)startPlay{
        [[PlayerManager sharedManager]playWithUrlString:self.currentModel.mp3Url];
    
        [self buildUI];
    }
//更新UI
-(void)buildUI{
    self.songName.text = self.currentModel.name;
    self.singerName.text = self.currentModel.singer;
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:self.currentModel.picUrl]];
    
    //更改button
    [self.btnPlayOrPause setTitle:@"暂停" forState:(UIControlStateNormal)];
    
    //改变进度条的最大值
    self.sliderrTime.maximumValue = [self.currentModel.duration integerValue]/1000;
    
  //  self.sliderrTime .value = 0;
    
    //更改旋转的角度，图片归为
    self.imgView.transform = CGAffineTransformMakeRotation(0);
    
    
    //解析歌词
    [[LyricManager sharedManager] LoadLyricWith:self.currentModel.lyric];
    
    //更新歌词
    [_tableViewLyric reloadData];
    
    
    
}

//- (void)setImage:(nullable UIImage *)image forState:(UIControlState)state{
//    _nsxtButton.imageView.image = [UIImage imageNamed:@"1139424.gif"];
//}


- (void)viewDidLoad {
    [super viewDidLoad];
    _currentIndex = -1;
    
    
    
    // 设置自己为播放器的代理，帮播放器干一些事情
    [PlayerManager sharedManager].delegate = self;
    
    //加圆角
    self.imgView.layer.masksToBounds = YES;
    self.imgView.layer.cornerRadius = 120;
    
    
    
    [self.tableViewLyric registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
}
//返回按钮
- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)ActionLast:(UIButton *)sender {
    _currentIndex--;
    if (_currentIndex == -1) {
       _currentIndex = [DataManager sharedManager].allMusic.count-1;
    }
    [self startPlay];
}

- (IBAction)actionPlayOrPause:(UIButton *)sender {
    //判断是否正在播放
    if ([PlayerManager sharedManager].isPlaying) {
        //如果正在播放，就让播放暂停，同时改变button的text
        [[PlayerManager sharedManager] pause];
        [sender setTitle:@"播放" forState:(UIControlStateNormal)];
    }else{
        [[PlayerManager sharedManager] play];
        [sender setTitle:@"暂停" forState:(UIControlStateNormal)];
        
    }
  // TODO:这里有个bug,在暂停之后，点击下一首不会播放

    
}
//下一首
- (IBAction)actionNext:(UIButton *)sender {
    
    
    
    _currentIndex++;
    //判断一下是不是最后一首
    if (_currentIndex == [DataManager sharedManager].allMusic.count) {
        _currentIndex = 0;
    }
    [self startPlay];
    
}
// 改变播放的进度
- (IBAction)actionChangeTime:(UISlider *)sender {
    UISlider *slider= sender;
    [[PlayerManager sharedManager] seekToTime:slider.value];
}

- (IBAction)actionChangeVolume:(UISlider *)sender {
    [PlayerManager sharedManager].sound = sender.value;  
}

#pragma mark -PlayerManagerDelegate
// 播放器播放结束了，开始播放下一首
-(void)playerDidPlayEnd{
    
    [self actionNext:nil];
    
}

// 播放器每0.1秒会让代理（也就是这个页面）执行一下这个事件
-(void)playerPlayingWithTime:(NSTimeInterval)time{
    self.sliderrTime.value = time;
    
   self.playTimeLabel.text = [self stringWithTime:time];
//    //剩余时间
    NSTimeInterval time2 = [self.currentModel.duration integerValue]/1000-time;
    self.lastTimeLabel.text = [self stringWithTime:time2];
    //每0.1 秒旋转一度
    self.imgView.transform = CGAffineTransformRotate(self.imgView.transform,M_PI / 180);
    
    
    //根据当前播放时间获取到应该播放那就歌词
    NSInteger index = [[LyricManager sharedManager]indexWith:time];
    NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
    //让tableView选中我们的歌词
    [self.tableViewLyric selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    

}

//更具时间获取到字符串
-(NSString *)stringWithTime:(NSTimeInterval)time{
    NSInteger minutes = time/60;
    NSInteger seconde = (int)time % 60;
    return [NSString stringWithFormat:@"%ld:%ld",(long)minutes,(long)seconde];
}


#pragma mark -- getter
//确保当前播放的音乐是最新的
-(MusicModel *)currentModel{
    //取到要播放的model
    MusicModel *model = [[DataManager sharedManager]musicModelWithIndex:_currentIndex];
    return model;

}
#pragma mark --UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [LyricManager sharedManager].allLyric.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [_tableViewLyric dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    //取到对应的歌词
    LyricModel *lyric= [LyricManager sharedManager].allLyric[indexPath.row];
    
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    cell.textLabel.text =[lyric lyricContext];
    return cell;
    
    
    
}






@end
