//
//  GameScene.m
//  Try_100000000_Money
//
//  Created by irons on 2016/1/12.
//  Copyright (c) 2016年 irons. All rights reserved.
//

#import "GameScene.h"
#import "GameOverScene.h"
#import "GameCenterUtil.h"

static const uint32_t shipCategory =  0x1 << 0;
static const uint32_t obstacleCategory =  0x1 << 1;

static const float BG_VELOCITY = 100.0;
static const float OBJECT_VELOCITY = 160.0;

static inline CGPoint CGPointAdd(const CGPoint a, const CGPoint b)
{
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint CGPointMultiplyScalar(const CGPoint a, const CGFloat b)
{
    return CGPointMake(a.x * b, a.y * b);
}


@implementation GameScene{
    
    SKSpriteNode *ship;
    SKAction *actionMoveUp;
    SKAction *actionMoveDown;
    
    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _dt;
    NSTimeInterval _lastMissileAdded;
    
    NSMutableArray *tretureBoxes;
    
    SKSpriteNode * rankBtn;
    
    SKLabelNode* moneyLabel;
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
        moneyLabel.position  = CGPointMake(self.frame.size.width - 100, 0 + 200);
        moneyLabel.zPosition = 1;
        moneyLabel.name = @"layerNumLabel";
        moneyLabel.fontSize = 30;
        moneyLabel.fontColor = [UIColor blackColor];
        [self addChild:moneyLabel];
        
        rankBtn = [SKSpriteNode spriteNodeWithImageNamed:@"btnL_GameCenter-hd"];
        rankBtn.name = @"rankBtn";
        rankBtn.size = CGSizeMake(50,50);
        //        rankBtn.anchorPoint = CGPointMake(0, 0);
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
    
    if(CGRectContainsPoint(rankBtn.calculateAccumulatedFrame, touchLocation)){
        self.showRankView();
    }
}

- (void)initalizingScrollingBackground {
    for (int i = 0; i < 2; i++) {
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"bg"];
        bg.size = self.frame.size;
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
        if (![node.name  isEqual: @"bg"] && ![node.name  isEqual: @"ship"]
            && ![node.name  isEqual: @"layerNumLabel"] && ![node.name  isEqual: @"adView"] && ![node.name  isEqual: @"rankBtn"]) {
            SKSpriteNode *ob = (SKSpriteNode *) node;
            CGPoint obVelocity = CGPointMake(-OBJECT_VELOCITY, 0);
            CGPoint amtToMove = CGPointMultiplyScalar(obVelocity,_dt);
            
            ob.position = CGPointAdd(ob.position, amtToMove);
            if(ob.position.x < -100) {
                [ob removeFromParent];
            }
        }
    }
}

- (void)addTretureBox {
    //initalizing spaceship node
    SKSpriteNode *missile;
    missile = [SKSpriteNode spriteNodeWithImageNamed:@"treatureBox01.png"];
    [missile setScale:0.15];
    
    //Adding SpriteKit physicsBody for collision detection
    missile.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:missile.size];
    missile.physicsBody.categoryBitMask = obstacleCategory;
    missile.physicsBody.dynamic = YES;
    missile.physicsBody.contactTestBitMask = shipCategory;
    missile.physicsBody.collisionBitMask = 0;
    missile.physicsBody.usesPreciseCollisionDetection = YES;
    missile.name = @"missile";
    
    //selecting random y position for missile
    int r = arc4random() % 300;
    missile.position = CGPointMake(self.frame.size.width + 20,r);
    
    [self addChild:missile];
    [tretureBoxes addObject:missile];
}

- (void)checkTouchTretureBox:(CGPoint)touchPoint {
    for(SKSpriteNode *tretureBox in tretureBoxes) {
        if(CGRectContainsPoint(tretureBox.calculateAccumulatedFrame, touchPoint)) {
            [self createNewCoins:tretureBox.position];
            money += 100;
            [self updateMoneyLabel];
        }
    }
}

- (void)updateMoneyLabel {
    moneyLabel.text = [NSString stringWithFormat:@"%d", money];
}

- (void)createTreturebox {
    
}

- (void)createNewCoins:(CGPoint)position {
    NSString *myParticlePath = [[NSBundle mainBundle] pathForResource:@"MySpark" ofType:@"sks"];
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
    
    if ( currentTime - _lastMissileAdded > 1) {
        _lastMissileAdded = currentTime + 1;
        [self addTretureBox];
    }
    [self moveBg];
    [self moveObstacle];
}

- (void)didBeginContact:(SKPhysicsContact *)contact {
    SKPhysicsBody *firstBody, *secondBody;
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    if ((firstBody.categoryBitMask & shipCategory) != 0 &&
        (secondBody.categoryBitMask & obstacleCategory) != 0) {
        [ship removeFromParent];
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        SKScene * gameOverScene = [[GameOverScene alloc] initWithSize:self.size];
        [self.view presentScene:gameOverScene transition: reveal];
    }
}

@end

