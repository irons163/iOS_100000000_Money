//
//  GameViewController.m
//  Try_100000000_Money
//
//  Created by irons on 2016/1/12.
//  Copyright (c) 2016年 irons. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"
#import "GameCenterUtil.h"
#import "GameScene.h"

@implementation SKScene (Unarchive)

//+ (instancetype)unarchiveFromFile:(NSString *)file {
//    /* Retrieve scene file path from the application bundle */
//    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
//    /* Unarchive the file to an SKScene object */
//    NSData *data = [NSData dataWithContentsOfFile:nodePath
//                                          options:NSDataReadingMappedIfSafe
//                                            error:nil];
//    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
//    [arch setClass:self forClassName:@"SKScene"];
//    scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
//    [arch finishDecoding];
//    
//    return scene;
//}

@end

GameScene *scene;

@implementation GameViewController{
//    ADBannerView * adBannerView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

//    // Configure the view.
//    SKView * skView = (SKView *)self.view;
//    skView.showsFPS = YES;
//    skView.showsNodeCount = YES;
//    /* Sprite Kit applies additional optimizations to improve rendering performance */
//    skView.ignoresSiblingOrder = YES;
//    
//    // Create and configure the scene.
//    GameScene *scene = [GameScene unarchiveFromFile:@"GameScene"];
//    scene.scaleMode = SKSceneScaleModeAspectFill;
//    
//    // Present the scene.
//    [skView presentScene:scene];
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    GameScene * scene = [GameScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
    
//    adBannerView = [[ADBannerView alloc] initWithFrame:CGRectMake(0, -50, 200, 30)];
//    adBannerView.delegate = self;
//    adBannerView.alpha = 1.0f;
//    [self.view addSubview:adBannerView];
    
    scene.showRankView = ^(){
        [self showRankView];
    };
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    SKView * skView = (SKView *)self.view;
    
    if (!skView.scene) {
        skView.showsFPS = YES;
        skView.showsNodeCount = YES;
        
        // Create and configure the scene.
        GameScene * scene = [GameScene sceneWithSize:skView.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
        // Present the scene.
        [skView presentScene:scene];
        
//        adBannerView = [[ADBannerView alloc] initWithFrame:CGRectMake(0, -50, 200, 30)];
//        adBannerView.delegate = self;
//        adBannerView.alpha = 1.0f;
//        [self.view addSubview:adBannerView];
        
        scene.showRankView = ^(){
            [self showRankView];
        };
        
        GameCenterUtil * gameCenterUtil = [GameCenterUtil sharedInstance];
        //    gameCenterUtil.delegate = self;
        [gameCenterUtil isGameCenterAvailable];
        [gameCenterUtil authenticateLocalUser:self];
        [gameCenterUtil submitAllSavedScores];
    }
    
    
}

-(void) showRankView{
    GameCenterUtil * gameCenterUtil = [GameCenterUtil sharedInstance];
    //    gameCenterUtil.delegate = self;
    [gameCenterUtil isGameCenterAvailable];
    //    [gameCenterUtil authenticateLocalUser:self];
    [gameCenterUtil showGameCenter:self];
    [gameCenterUtil submitAllSavedScores];
}

//-(void)bannerViewDidLoadAd:(ADBannerView *)banner{
//    [self layoutAnimated:true];
//}
//
//-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
//    [self layoutAnimated:true];
//}
//
//- (void)layoutAnimated:(BOOL)animated
//{
//    CGRect contentFrame = self.view.bounds;
//    CGRect bannerFrame = adBannerView.frame;
//    if (adBannerView.bannerLoaded)
//    {
//        //        contentFrame.size.height -= adBannerView.frame.size.height;
//        contentFrame.size.height = 0;
//        bannerFrame.origin.y = contentFrame.size.height;
//    } else {
//        bannerFrame.origin.y = contentFrame.size.height;
//    }
//
//    [UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
//        adBannerView.frame = contentFrame;
//        [adBannerView layoutIfNeeded];
//        adBannerView.frame = bannerFrame;
//    }];
//}


- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
