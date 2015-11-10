//
//  DataManager.h
//  0834MusicPlayer
//
//  Created by lanou3g on 15/11/4.
//  Copyright © 2015年 lanou3g. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MusicModel.h"

typedef void(^UpdataUI)();

@interface DataManager : NSObject

@property (nonatomic, copy)UpdataUI myUpdataUI;

@property (nonatomic, retain)NSArray * allMusic;

+(DataManager *)sharedManager;

-(MusicModel *)musicModelWithIndex:(NSInteger)index;



@end
