//
//  GameScene.m
//  Try_100000000_Money
//
//  Created by irons on 2016/1/12.
//  Copyright (c) 2016年 irons. All rights reserved.
//

#import "GameScene.h"
#import "GameCenterUtil.h"

//static const uint32_t shipCategory =  0x1 << 0;
//static const uint32_t obstacleCategory =  0x1 << 1;

static const float BG_VELOCITY = 100.0;
static const float Coin10_VELOCITY = 200.0;
static const float Coin30_VELOCITY = 260.0;
static const float Coin50_VELOCITY = 320.0;

static inline CGPoint CGPointAdd(const CGPoint a, const CGPoint b) {
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint CGPointMultiplyScalar(const CGPoint a, const CGFloat b) {
    return CGPointMake(a.x * b, a.y * b);
}

@implementation GameScene {
    SKSpriteNode *ship;
    SKAction *actionMoveUp;
    SKAction *actionMoveDown;
    
    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _dt;
    NSTimeInterval _lastMissileAdded;
    
    NSMutableArray *tretureBoxes;
    
    SKSpriteNode *rankBtn;
    
    SKLabelNode *moneyLabel;
    int money;
}

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        tretureBoxes = [NSMutableArray array];
        
        self.backgroundColor = [SKColor whiteColor];
        [self initalizingScrollingBackground];
        
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsWorld.contactDelegate = self;
        
        moneyLabel = [SKLabelNode labelNodeWithText:[NSString stringWithFormat:@"%d", money]];
        moneyLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        moneyLabel.position  = CGPointMake(0, 0 + 100);
        moneyLabel.zPosition = 1;
        moneyLabel.name = @"layerNumLabel";
        moneyLabel.fontSize = 42;
        moneyLabel.fontColor = [UIColor blackColor];
        [self addChild:moneyLabel];
        
        rankBtn = [SKSpriteNode spriteNodeWithImageNamed:@"btnL_GameCenter-hd"];
        
        rankBtn.name = @"rankBtn";
        rankBtn.size = CGSizeMake(50,50);
        rankBtn.position = CGPointMake(rankBtn.size.width/2.0f, self.frame.size.height - 200);
        rankBtn.zPosition = 1;
        [self addChild:rankBtn];
    }
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self.scene];
    
    [self checkTouchTretureBox:touchLocation];
    
    if (CGRectContainsPoint(rankBtn.calculateAccumulatedFrame, touchLocation)) {
        self.showRankView();
    }
}

- (void)initalizingScrollingBackground {
    for (int i = 0; i < 2; i++) {
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"bg"];
        bg.size = self.size;
        bg.position = CGPointMake(i * bg.size.width, 0);
        bg.anchorPoint = CGPointZero;
        bg.name = @"bg";
        [self addChild:bg];
    }
    
}

- (void)moveBg {
    [self enumerateChildNodesWithName:@"bg" usingBlock: ^(SKNode *node, BOOL *stop) {
         SKSpriteNode * bg = (SKSpriteNode *) node;
         CGPoint bgVelocity = CGPointMake(-BG_VELOCITY, 0);
         CGPoint amtToMove = CGPointMultiplyScalar(bgVelocity,_dt);
         bg.position = CGPointAdd(bg.position, amtToMove);
         
         //Checks if bg node is completely scrolled of the screen, if yes then put it at the end of the other node
         if (bg.position.x <= -bg.size.width) {
             bg.position = CGPointMake(bg.position.x + bg.size.width*2,
                                       bg.position.y);
         }
     }];
}

- (void)moveObstacle {
    NSArray *nodes = self.children;//1
    
    for(SKNode * node in nodes){
        if ([node.name isEqual: @"coin10"] || [node.name isEqual: @"coin30"] || [node.name isEqual: @"coin50"]) {
            SKSpriteNode *ob = (SKSpriteNode *) node;
            int coinVelocity = 0;
            if ([node.name isEqual: @"coin10"]) {
                coinVelocity = Coin10_VELOCITY;
            } else if ([node.name isEqual: @"coin30"]) {
                coinVelocity = Coin30_VELOCITY;
            } else {
                coinVelocity = Coin50_VELOCITY;
            }
            CGPoint obVelocity = CGPointMake(-coinVelocity, 0);
            CGPoint amtToMove = CGPointMultiplyScalar(obVelocity,_dt);
            
            ob.position = CGPointAdd(ob.position, amtToMove);
            if(ob.position.x < -100)
            {
                [ob removeFromParent];
            }
        }
    }
}

- (void)addTretureBox {
    //initalizing spaceship node
    SKSpriteNode *missile;
    missile = [SKSpriteNode spriteNodeWithImageNamed:@"treatureBox01.png"];
    int treatureBoxRandomNumber = arc4random_uniform(100);
    if (treatureBoxRandomNumber < 20) {
        missile.name = @"coin50";
        [missile setScale:0.1];
    } else if (treatureBoxRandomNumber < 50) {
        missile.name = @"coin30";
        [missile setScale:0.15];
    } else {
        missile.name = @"coin10";
        [missile setScale:0.2];
    }
    
    //Adding SpriteKit physicsBody for collision detection
    missile.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:missile.size];
//    missile.physicsBody.categoryBitMask = obstacleCategory;
    missile.physicsBody.dynamic = YES;
//    missile.physicsBody.contactTestBitMask = shipCategory;
    missile.physicsBody.collisionBitMask = 0;
    missile.physicsBody.usesPreciseCollisionDetection = YES;
    
    
    //selecting random y position for missile
    int r = arc4random() % (NSInteger)(self.frame.size.height - 40) + 20;
    missile.position = CGPointMake(self.frame.size.width + 20,r);
    
    [self addChild:missile];
    [tretureBoxes addObject:missile];
}

- (void)checkTouchTretureBox:(CGPoint)touchPoint {
    NSMutableArray *willRemoveTretureBoxs = [NSMutableArray array];
    for (SKSpriteNode *tretureBox in tretureBoxes) {
        if(CGRectContainsPoint(tretureBox.calculateAccumulatedFrame, touchPoint)){
            
            [self createNewCoins:tretureBox.position coinName:tretureBox.name];
            
            if ([tretureBox.name isEqual:@"coin10"]) {
                money += 10;
            } else if ([tretureBox.name isEqual:@"coin30"]) {
                money += 30;
            } else {
                money += 50;
            }
            
            [willRemoveTretureBoxs addObject:tretureBox];
            
            [self updateMoneyLabel];
        }
    }
    
    for (SKSpriteNode *tretureBox in willRemoveTretureBoxs) {
        [tretureBox removeFromParent];
        [tretureBoxes removeObject:tretureBox];
    }
}

- (void)updateMoneyLabel {
    moneyLabel.text = [NSString stringWithFormat:@"%d", money];
}

- (void)createNewCoins:(CGPoint)position coinName:(NSString *)coinName {
    NSString *myParticlePath = nil;
    if ([coinName isEqual: @"coin10"]) {
        myParticlePath = [[NSBundle mainBundle] pathForResource:@"Coin10Spark" ofType:@"sks"];
    } else if ([coinName isEqual: @"coin30"]) {
        myParticlePath = [[NSBundle mainBundle] pathForResource:@"Coin30Spark" ofType:@"sks"];
    } else {
        myParticlePath = [[NSBundle mainBundle] pathForResource:@"Coin50Spark" ofType:@"sks"];
    }
    
    SKEmitterNode *rainEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:myParticlePath];
    rainEmitter.position = position;
    [self addChild:rainEmitter];
    
}

- (void)countMoney {
    
}

- (void)update:(CFTimeInterval)currentTime {
    
    if (_lastUpdateTime) {
        _dt = currentTime - _lastUpdateTime;
    } else {
        _dt = 0;
    }
    _lastUpdateTime = currentTime;
    
    if(currentTime - _lastMissileAdded > 0.5) {
        _lastMissileAdded = currentTime + 0.5;
//        [self addMissile];
        [self addTretureBox];
    }
    
    [self moveBg];
    [self moveObstacle];
}

@end

