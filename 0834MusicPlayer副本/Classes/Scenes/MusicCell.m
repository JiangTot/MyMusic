//
//  MusicCell.m
//  0834MusicPlayer
//
//  Created by lanou3g on 15/11/4.
//  Copyright © 2015年 lanou3g. All rights reserved.
//

#import "MusicCell.h"


@implementation MusicCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setMusic:(MusicModel *)music{
    _music = music;
    _songName.text = music.name;
    _personName.text = music.singer;
    _imgView.image = [UIImage imageNamed:music.picUrl];
}

@end
