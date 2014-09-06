//
//  ClassicGameController.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/22.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "ClassicGameController.h"
#import "MenuController.h"
#import "GameAsset.h"
#import "ParticleView.h"
#import "GamePad.h"
#import "Snake.h"
#import "MKAppDelegate.h"
#import "CustomLabel.h"
#import "ScoreObject.h"
#import <AVFoundation/AVFoundation.h>
#import "GameStatsViewController.h"
#import <StoreKit/StoreKit.h>
#import "Reachability.h"

@interface ClassicGameController () <gameoverDelegate,replayDelegate,SKStoreProductViewControllerDelegate>
{
    NSNumberFormatter *numFormatter; //Formatter for score
    NSInteger score;
    SnakeNode *nextNode;
    GamePad *gamePad;
    Snake *snake;
    NSInteger totalCombos;
    NSInteger combosToCreateBomb;
    BOOL swap;
    CustomLabel *nextLabel;
    CustomLabel *scoreLabel;
    BOOL gameIsOver;
    NSInteger scoreGap;
    NSTimer *changeScoreTimer;
    NSMutableArray *scoreArray;
    ParticleView *particle;
    UIButton *settingButton;
    UIButton *soundButton;
    UIButton *musicButton;
    UIButton *rateButton;
    UIButton *tutorial;
    UIView *settingBG;
    BOOL isSetting;
    BOOL musicOn;
    BOOL soundOn;
    MKAppDelegate *appDelegate;
    CustomLabel *soundOnLabel;
    CustomLabel *musicOnLabel;
    UIView *tutorial1BG;
    UIView *tutorial2BG;
    UIView *tutorial3BG;
    UIView *tutorial4BG;

    NSInteger tutorialMode;
    
}
@end

@implementation ClassicGameController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.063 alpha:1.000];
    UIImageView *bgImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Background.png"]];
    [self.view addSubview:bgImageView];
    
    // Do any additional setup after loading the view.
    numFormatter = [[NSNumberFormatter alloc] init];
    [numFormatter setGroupingSeparator:@","];
    [numFormatter setGroupingSize:3];
    [numFormatter setUsesGroupingSeparator:YES];
    
    // -------------------- Setup game pad -------------------- //
    gamePad = [[GamePad alloc]initGamePad];
    gamePad.center = self.view.center;

    // -------------------- Setup particle views -------------------- //
    // Configure the SKView
    SKView * skView = [[SKView alloc]initWithFrame:CGRectMake(0, 0, gamePad.frame.size.width, gamePad.frame.size.height)];
    skView.backgroundColor = [UIColor clearColor];
    
    // Create and configure the scene.
    particle = [[ParticleView alloc]initWithSize:skView.bounds.size];
    particle.scaleMode = SKSceneScaleModeAspectFill;
    [gamePad addSubview:skView];
    [gamePad sendSubviewToBack:skView];

    // Present the scene.
    [skView presentScene:particle];
    [self.view addSubview:gamePad];
    
    // Count down
    scoreLabel = [[CustomLabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 250)/2, 30 , 250, 65) fontSize:65];
    scoreLabel.textColor = [UIColor whiteColor];
    scoreLabel.text = @"0";
    [self.view addSubview:scoreLabel];
    
    // Setup player snake head
    snake = [[Snake alloc]initWithSnakeNode:gamePad.initialNode gamePad:gamePad];
    snake.delegate = self;
    [gamePad addSubview:snake];
    snake.particleView = particle;
    
    // Next Node
    CGFloat nextNodeSize = 40;
    nextNode = [[SnakeNode alloc]initWithFrame:CGRectMake((320-nextNodeSize)/2, self.view.frame.size.height - 90 , nextNodeSize, nextNodeSize)];
    snake.nextNode = nextNode;
    [snake updateNextNode:nextNode animation:YES];
    [self.view addSubview:nextNode];
    
    nextLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(120, self.view.frame.size.height - 50, 80, 15) fontSize:15];
    nextLabel.text = @"Next";
    nextLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:nextLabel];

    // Setup swipe gestures
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDirection:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [gamePad addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDirection:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [gamePad addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDirection:)];
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [gamePad addGestureRecognizer:swipeDown];
    
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDirection:)];
    [swipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [gamePad addGestureRecognizer:swipeUp];
    
    scoreArray = [[NSMutableArray alloc]init];
    
    settingButton = [[UIButton alloc]initWithFrame:CGRectMake(320-45, 10, 35, 35)];
    [settingButton setImage:[UIImage imageNamed:@"setting70.png"] forState:UIControlStateNormal];
    [settingButton addTarget:self action:@selector(settings:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:settingButton];
    
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    musicOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"music"];
    soundOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"sound"];
    
    if (musicOn)
        [appDelegate.audioPlayer play];
    
    [self settingPage];
    
    tutorialMode = [[NSUserDefaults standardUserDefaults]integerForKey:@"tutorial"];
    if (tutorialMode == 1)
        [self showTutorial1];
}

- (void)settingPage
{
    settingBG = [[UIView alloc]initWithFrame:self.view.frame];
    settingBG.frame = CGRectOffset(settingBG.frame, 0, -568);
    settingBG.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.800];
    [self.view addSubview:settingBG];
    
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, 35, 35)];
    [backButton setImage:[UIImage imageNamed:@"back70.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(settings:) forControlEvents:UIControlEventTouchDown];
    [settingBG addSubview:backButton];
    
    CGFloat xCord = 40;
    CGFloat yGap = 100;
    CGFloat fontSize = 30;
    
    CGFloat centerY = (self.view.frame.size.height - 45*4 - (yGap-45)*3)/2 ;

    // Sound
    soundButton = [[UIButton alloc]initWithFrame:CGRectMake(xCord, centerY, 45, 45)];
    [soundButton setImage:[UIImage imageNamed:@"soundOn90.png"] forState:UIControlStateNormal];
    [soundButton addTarget:self action:@selector(turnSound) forControlEvents:UIControlEventTouchDown];
    [settingBG addSubview:soundButton];
    
    CustomLabel *soundLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(xCord+80, centerY, 90, 45) fontSize:fontSize];
    soundLabel.text = @"Sound";
    soundLabel.textAlignment = NSTextAlignmentLeft;
    [settingBG addSubview:soundLabel];
    
    soundOnLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(xCord+65+90+30, centerY, 90, 45) fontSize:25];
    [self setSoundOnLabel];
    [settingBG addSubview:soundOnLabel];
    
    // Music
    musicButton = [[UIButton alloc]initWithFrame:CGRectMake(xCord, centerY+yGap, 45, 45)];
    [musicButton setImage:[UIImage imageNamed:@"musicOn90.png"] forState:UIControlStateNormal];
    [musicButton addTarget:self action:@selector(turnMusic) forControlEvents:UIControlEventTouchDown];
    [settingBG addSubview:musicButton];
    
    CustomLabel *musicLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(xCord+80, centerY+yGap, 90, 45) fontSize:fontSize];
    musicLabel.text = @"Music";
    musicLabel.textAlignment = NSTextAlignmentLeft;
    [settingBG addSubview:musicLabel];
    
    musicOnLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(xCord+65+90+30, centerY+yGap, 90, 45) fontSize:25];
    [self setMusicOnLabel];
    [settingBG addSubview:musicOnLabel];
    
    // Rating
    rateButton = [[UIButton alloc]initWithFrame:CGRectMake(xCord, centerY+yGap*2, 45, 45)];
    [rateButton setImage:[UIImage imageNamed:@"rating90.png"] forState:UIControlStateNormal];
    [rateButton addTarget:self action:@selector(rateThisApp) forControlEvents:UIControlEventTouchDown];
    [settingBG addSubview:rateButton];
    
    CustomLabel *ratingLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(xCord+80, centerY+yGap*2, 120, 45) fontSize:fontSize];
    ratingLabel.text = @"Rate Me";
    ratingLabel.textAlignment = NSTextAlignmentLeft;
    [settingBG addSubview:ratingLabel];
    
    // Tutorial
    tutorial = [[UIButton alloc]initWithFrame:CGRectMake(xCord, centerY+yGap*3, 45, 45)];
    [tutorial setImage:[UIImage imageNamed:@"tutorial90.png"] forState:UIControlStateNormal];
    [tutorial addTarget:self action:@selector(startTutorial) forControlEvents:UIControlEventTouchDown];
    [settingBG addSubview:tutorial];
    
    CustomLabel *tutorialLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(xCord+80, centerY+yGap*3, 120, 45) fontSize:fontSize];
    tutorialLabel.text = @"Tutorial";
    tutorialLabel.textAlignment = NSTextAlignmentLeft;
    [settingBG addSubview:tutorialLabel];
}

-(void)settings:(UIButton *)button
{
    [self buttonAnimation:button];
    [particle playButtonSound];
    if (!isSetting) {
        
        isSetting = YES;
        
        [UIView animateWithDuration:0.5 animations:^{
            
            settingBG.frame = CGRectOffset(settingBG.frame, 0, 568);
            settingButton.alpha = 0;
        }];
        
    } else {
        
        isSetting = NO;
        [UIView animateWithDuration:0.5 animations:^{
            
            settingBG.frame = CGRectOffset(settingBG.frame, 0, -568);
            settingButton.alpha = 1;

        }];
    }
}

- (void)turnMusic
{
    [self buttonAnimation:musicButton];
    [particle playButtonSound];
    if (musicOn) {
        musicOn = NO;
        [appDelegate.audioPlayer stop];
    } else {
        musicOn = YES;
        [appDelegate.audioPlayer play];
    }
    [self setMusicOnLabel];
    [[NSUserDefaults standardUserDefaults] setBool:musicOn forKey:@"music"];
}

- (void)turnSound
{
    [self buttonAnimation:soundButton];
    [particle playButtonSound];
    if (soundOn)
        soundOn = NO;
    else
        soundOn = YES;
    [self setSoundOnLabel];
    [[NSUserDefaults standardUserDefaults] setBool:soundOn forKey:@"sound"];
}

-(void)setSoundOnLabel
{
    if (!soundOn) {
        //soundOnLabel.textColor = [UIColor whiteColor];
        soundOnLabel.text = @"OFF";
        [soundButton setImage:[UIImage imageNamed:@"soundOff90.png"] forState:UIControlStateNormal];
    }
    else {
        //soundOnLabel.textColor = RedDotColor;
        soundOnLabel.text = @"ON";
        [soundButton setImage:[UIImage imageNamed:@"soundOn90.png"] forState:UIControlStateNormal];
    }
}

-(void)setMusicOnLabel
{
    if (!musicOn) {
        //musicOnLabel.textColor = [UIColor whiteColor];
        musicOnLabel.text = @"OFF";
        [musicButton setImage:[UIImage imageNamed:@"musicOff90.png"] forState:UIControlStateNormal];
        [appDelegate.audioPlayer stop];
    } else {
        //musicOnLabel.textColor = BlueDotColor;
        musicOnLabel.text = @"ON";
        [musicButton setImage:[UIImage imageNamed:@"musicOn90.png"] forState:UIControlStateNormal];
        [appDelegate.audioPlayer play];
    }
}

#pragma mark - Game Over

-(void)gameOver
{
    gamePad.userInteractionEnabled = NO;
    [snake setGameoverImage];
    gameIsOver = YES;
}

#pragma mark - Move
-(void)swipeDirection:(UISwipeGestureRecognizer *)sender
{
    if (gamePad.userInteractionEnabled) {
        
        if (tutorialMode==1) {

            [self showTutorial2];
        }
        
        SnakeNode *head = [snake.snakeBody firstObject];
        [head.layer removeAllAnimations];
        
        gamePad.userInteractionEnabled = NO;
        
        MoveDirection dir;
        switch (sender.direction) {
            case UISwipeGestureRecognizerDirectionDown:
                dir = kMoveDirectionDown;
                break;
            case UISwipeGestureRecognizerDirectionUp:
                dir = kMoveDirectionUp;
                break;
            case UISwipeGestureRecognizerDirectionLeft:
                dir = kMoveDirectionLeft;
                break;
            case UISwipeGestureRecognizerDirectionRight:
                dir = kMoveDirectionRight;
                break;
        }
        
        [snake moveAllNodesBySwipe:dir complete:^{
            
            if (snake.combos == 0 ) {
                
                [snake createBody:^ {
                    [self actionsAfterMove];
                }];
                
            } else {
                
                if (tutorialMode==2) {
                    
                    [self showTutorial3];
                }
                
                [self actionsAfterMove];

            }
        }];
    }
}

- (void)actionsAfterMove
{
    totalCombos += snake.combos;
    combosToCreateBomb += snake.combos;
    snake.combos = 0;

    // Create Bomb
    if (combosToCreateBomb > 2) {
        
        if (tutorialMode==3)
            [self showTutorial4];
        
        combosToCreateBomb = 0;
        
        gamePad.userInteractionEnabled = NO;
        
        [gamePad createBombWithReminder:snake.reminder body:[snake snakeBody] complete:^{
            
            [snake cancelPattern:^{
                
                if([snake checkIsGameover])
                    [self gameOver];
                else
                    gamePad.userInteractionEnabled = YES;
                
            }];

        }];
    }
    else {
        
        gamePad.userInteractionEnabled = YES;
        if([snake checkIsGameover]) {
            [particle playGameoverSound];
            [self gameOver];
        }
    }
}

- (BOOL)moveDirecton:(UISwipeGestureRecognizerDirection)swipeDirection
{
    MoveDirection headDirection = [snake headDirection];
    
    switch (headDirection) {
        case kMoveDirectionUp:
            if (swipeDirection == UISwipeGestureRecognizerDirectionDown)
                return NO;
            break;
        case kMoveDirectionDown:
            if (swipeDirection == UISwipeGestureRecognizerDirectionUp)
                return NO;
            break;
        case kMoveDirectionLeft:
            if (swipeDirection == UISwipeGestureRecognizerDirectionRight)
                return NO;
            break;
        case kMoveDirectionRight:
            if (swipeDirection == UISwipeGestureRecognizerDirectionLeft)
                return NO;
            break;
    }
    return YES;
}

#pragma mark - Replay

- (void)replayGame
{
    nextNode.hidden = NO;
    nextLabel.hidden = NO;
    gamePad.userInteractionEnabled = YES;
    scoreLabel.text = @"0";
    score = 0;
    totalCombos = 0;
    [snake resetSnake];
    [gamePad reset];
    gameIsOver = NO;
    [snake updateNextNode:nextNode animation:NO];
}

#pragma mark - Snake Delegate

-(void)showReplayView:(NSInteger)totalBombs
{
    GameStatsViewController *controller =  [[GameStatsViewController alloc]init];
    controller.bombs = totalBombs;
    controller.combos = totalCombos;
    controller.score = score;
    controller.gameImage = [self captureView:self.view];
    controller.delegate = self;
    [self presentViewController:controller animated:YES completion:nil];
}

-(void)updateScore:(NSInteger)s
{
    ScoreObject *so = [[ScoreObject alloc]initWithScore:s];
    [scoreArray addObject:so];
    
    if (!changeScoreTimer.isValid) {
        ScoreObject *scoreObject = [scoreArray firstObject];
        scoreGap = scoreObject.score;
        changeScoreTimer = [NSTimer scheduledTimerWithTimeInterval:scoreObject.interval target:self selector:@selector(changeScore) userInfo:nil repeats:YES];
    }
}

-(void)changeScore
{
    scoreGap--;
    score++;
    scoreLabel.text = [numFormatter stringFromNumber:[NSNumber numberWithInteger:score]];
    
    if (scoreGap == 0)
    {
        [changeScoreTimer invalidate];

        [scoreArray removeObjectAtIndex:0];
        
        if ([scoreArray count]>0) {
            ScoreObject *scoreObject = [scoreArray firstObject];
            scoreGap = scoreObject.score;
            changeScoreTimer = [NSTimer scheduledTimerWithTimeInterval:scoreObject.interval
                                                                target:self
                                                              selector:@selector(changeScore)
                                                              userInfo:nil
                                                               repeats:YES];
        }
    }
}
- (UIImage *)captureView:(UIView *)view
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

-(void)buttonAnimation:(UIButton *)button
{
    CGAffineTransform t = button.transform;
    
    [UIView animateWithDuration:0.15 animations:^{
        
        button.transform = CGAffineTransformScale(t, 0.85, 0.85);

    } completion:^(BOOL finished) {
        
        button.transform = t;
    }];
}

-(void)rateThisApp
{
    if ([self checkInternetConnection]) {
        
        SKStoreProductViewController *storeController = [[SKStoreProductViewController alloc] init];
        storeController.delegate = self;
        
        NSDictionary *productParameters = @{ SKStoreProductParameterITunesItemIdentifier :@"916465725"};
        
        [storeController loadProductWithParameters:productParameters completionBlock:^(BOOL result, NSError *error) {
            if (result) {
                
                [self presentViewController:storeController animated:YES completion:nil];
                
            }
        }];
    }
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Tutorial

-(void)startTutorial
{
    [self replayGame];
    [self settings:tutorial];
    tutorialMode = 1;
    [self showTutorial1];
}

 -(void)showTutorial1
{
    tutorial1BG = [[UIView alloc]initWithFrame:CGRectMake(0, -130, 320, 130)];
    tutorial1BG.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tutorial1BG];
    
    scoreLabel.hidden = YES;
    settingButton.hidden = YES;
    
    // 1. Swipe
    CustomLabel *swipeText = [[CustomLabel alloc]initWithFrame:CGRectMake(0,10, 320, 35) fontSize:30];
    swipeText.text = @"Swipe to move";
    [tutorial1BG addSubview:swipeText];
    
    UIImageView *swipe = [[UIImageView alloc]initWithFrame:CGRectMake((320-70)/2, 50, 70, 70)];
    swipe.image = [UIImage imageNamed:@"tutorialSwipe140.png"];
    [tutorial1BG addSubview:swipe];
    
    [self showTutorial:tutorial1BG];
}

-(void)showTutorial2
{
    tutorialMode++;
    [self hideTutorial:tutorial1BG complete:^{
        
        tutorial2BG = [[UIView alloc]initWithFrame:CGRectMake(0, -130, 320, 130)];
        tutorial2BG.backgroundColor = [UIColor clearColor];
        [self.view addSubview:tutorial2BG];
        
        // 2. Combo
        CustomLabel *tutComboText = [[CustomLabel alloc]initWithFrame:CGRectMake(0,10, 320, 35) fontSize:30];
        tutComboText.text = @"Move for combo";
        [tutorial2BG addSubview:tutComboText];
        
        UIImageView *tutorialCombo = [[UIImageView alloc]initWithFrame:CGRectMake(0, 50, 320, 70)];
        tutorialCombo.image = [UIImage imageNamed:@"tutorialCombo140.png"];
        [tutorial2BG addSubview:tutorialCombo];
        
        [self showTutorial:tutorial2BG];

    }];
}

-(void)showTutorial3
{
    tutorialMode++;
    [self hideTutorial:tutorial2BG complete:^{
        
        tutorial3BG = [[UIView alloc]initWithFrame:CGRectMake(0, -130, 320, 130)];
        tutorial3BG.backgroundColor = [UIColor clearColor];
        [self.view addSubview:tutorial3BG];
        
        // 3. Bomb
        CustomLabel *tutBombText = [[CustomLabel alloc]initWithFrame:CGRectMake(0,10, 320, 35) fontSize:30];
        tutBombText.text = @"More combo more bomb";
        [tutorial3BG addSubview:tutBombText];
        
        UIImageView *tutorialBomb = [[UIImageView alloc]initWithFrame:CGRectMake(0, 50, 320, 70)];
        tutorialBomb.image = [UIImage imageNamed:@"tutorialCreateBomb140.png"];
        [tutorial3BG addSubview:tutorialBomb];
        
        [self showTutorial:tutorial3BG];
        
    }];
}

-(void)showTutorial4
{
    tutorialMode++;
    [self hideTutorial:tutorial3BG complete:^{
        
        tutorial4BG = [[UIView alloc]initWithFrame:CGRectMake(0, -130, 320, 130)];
        tutorial4BG.backgroundColor = [UIColor clearColor];
        [self.view addSubview:tutorial4BG];
        
        // 3. Bomb
        CustomLabel *tutBombText = [[CustomLabel alloc]initWithFrame:CGRectMake(0,10, 320, 35) fontSize:30];
        tutBombText.text = @"Trigger bomb by combo";
        [tutorial4BG addSubview:tutBombText];
        
        UIImageView *tutorialBomb = [[UIImageView alloc]initWithFrame:CGRectMake(0, 50, 320, 70)];
        tutorialBomb.image = [UIImage imageNamed:@"tutorialBomb140.png"];
        [tutorial4BG addSubview:tutorialBomb];
        
        [self showTutorial:tutorial4BG];
        
    }];
}

-(void)hideTutorial:(UIView *)tutorialView  complete:(void(^)(void))completeBlock
{
    [UIView animateWithDuration:0.5 animations:^{
        
        tutorialView.frame = CGRectOffset(tutorialView.frame, 0, -130);
        
    }completion:^(BOOL finished) {

        [tutorialView removeFromSuperview];
        completeBlock();
    } ];
}

-(void)showTutorial:(UIView *)tutorialView
{
    [UIView animateWithDuration:0.5 animations:^{
        
        tutorialView.frame = CGRectOffset(tutorialView.frame, 0, 130);
        
    }];
}

- (void)hideLastTutorial
{
    if (tutorialMode == 4) {
        
        [self hideTutorial:tutorial4BG complete:^{
            
            scoreLabel.hidden = NO;
            settingButton.hidden = NO;
            
            CGAffineTransform t =  scoreLabel.transform;
            CGAffineTransform t1 =  settingButton.transform;
            
            scoreLabel.transform = CGAffineTransformScale(t1, 0.1, 0.1);
            settingButton.transform = CGAffineTransformScale(t1, 0.1, 0.1);
            
            [UIView animateWithDuration:0.2 animations:^{
                
                scoreLabel.transform = CGAffineTransformScale(t1, 1.2, 1.2);
                settingButton.transform = CGAffineTransformScale(t1, 1.2, 1.2);
                
            }completion:^(BOOL finished) {
                
                scoreLabel.transform = t;
                settingButton.transform = t1;
                tutorialMode = 0;
                
                [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"tutorial"];

            }];
            
        }];
    }
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)checkInternetConnection
{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        UIAlertView *noInternetAlert = [[UIAlertView alloc]initWithTitle: NSLocalizedString(@"No Internet Connection", nil)
                                                                 message:NSLocalizedString(@"Check your internet connection and try again",nil)
                                                                delegate:self cancelButtonTitle:NSLocalizedString(@"Close",nil)
                                                       otherButtonTitles:nil, nil];
        [noInternetAlert show];
        return NO;
    } else {
        return YES;
    }
}

@end
