//
//  GameScene.h
//  Try_100000000_Money
//

//  Copyright (c) 2016年 irons. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameScene : SKScene

typedef void(^rankView)();
@property (atomic, copy) rankView showRankView;

@end
