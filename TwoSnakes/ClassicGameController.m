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

@interface ClassicGameController ()
{

    UILabel *scoreLabel;
    NSNumberFormatter *numFormatter; //Formatter for score
    NSInteger score;
    NSInteger numDotAte;
    NSInteger maxCombos;
    float timeInterval; // Movement speed of snake
    BOOL isCheckingCombo;
    
    //    NSTimer *countDownTimer;
    //    NSInteger counter;

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
    // Do any additional setup after loading the view.
    
    // Setup game pad
    self.gamePad = [[GamePad alloc]initGamePad];
    self.gamePad.center = self.view.center;
    UITapGestureRecognizer *gamePadTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(directionChange:)];
    [self.gamePad addGestureRecognizer:gamePadTap];
    [self.view addSubview:self.gamePad];
    
    // Setup snake head
    self.snake = [[Snake alloc]initWithSnakeHeadDirection:kMoveDirectionDown gamePad:self.gamePad headFrame:CGRectMake(147, 189, 20, 20)];
    [self.gamePad addSubview:self.snake];
    
    // Setup score label
    CGFloat labelWidth = 100;
    scoreLabel = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width - labelWidth)/2, 10, labelWidth, 50)];
    scoreLabel.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:20];
    scoreLabel.text = @"Score";
    scoreLabel.textColor = [UIColor blackColor];
    scoreLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:scoreLabel];
    
    numFormatter = [[NSNumberFormatter alloc] init];
    [numFormatter setGroupingSeparator:@","];
    [numFormatter setGroupingSize:3];
    [numFormatter setUsesGroupingSeparator:YES];
    
    // Game Settings
    numDotAte = 0;
    maxCombos = 0;
    score = 0;
    timeInterval = 0.2;
    maxCombos = 0;
}

-(void)changeDirection
{
    [super changeDirection];
    
    if ([self.snake changeDirectionWithGameIsOver:NO]) {
        
        [self.moveTimer invalidate];
        
        UIColor *gameOverColor = [UIColor colorWithRed:0.435 green:0.529 blue:0.529 alpha:1.000];
        
        [self.snake gameOver];
        
        [UIView animateWithDuration:1 animations:^{
            
            for (GameAsset *v in [self.gamePad assetArray]) {
                v.classicAssetLabel.backgroundColor = gameOverColor;
            }
            
            for (UIView *v in [self.snake snakeBody]) {
                if (v.tag > 0) {
                    v.backgroundColor = gameOverColor;
                }
            }
            
        }];
        
    } else {
        for (GameAsset *v in [self.gamePad assetArray]) {
            if (v.hidden) {
                v.hidden = NO;
            }
        }
        [self isEatingDot];
    }
}

#pragma mark - Dot

- (void)isEatingDot
{
    for (GameAsset *v in [self.gamePad assetArray]) {
        if (!v.hidden && CGRectIntersectsRect([self.snake snakeHead].frame, v.frame) && v.gameAssetType != kAssetTypeEmpty) {
            
            self.snake.snakeMouth.hidden = NO;
            
            v.hidden = YES;
            
            [self.gamePad bringSubviewToFront:[self.snake snakeHead]];
            
            [self.gamePad addSubview:[self.snake addSnakeBodyWithAsset:v]];
            
            [self.moveTimer invalidate];
            
            self.gamePad.userInteractionEnabled = NO;
            
            isCheckingCombo = YES;
            
            [self.snake checkCombo:^{
                
                self.gamePad.userInteractionEnabled = YES;
                
                isCheckingCombo = NO;
                
                [self setScore];
                
                if (self.snake.isRotate)
                    [self.snake stopRotate];
                
                [self.snake mouthAnimation:timeInterval];
                
                self.snake.snakeMouth.backgroundColor = [UIColor whiteColor];
                
                // Increase speed for every 30 dots eaten
                if (numDotAte%30==0 && numDotAte != 0)
                    timeInterval -= 0.005;
                
                [self.snake updateExclamationText];
                
                [self.gamePad changeAssetType:v];
                
                if (self.moveTimer.isValid)
                    [self.moveTimer invalidate];
                
                if (!self.gamePause)
                    self.moveTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self
                                                                    selector:@selector(changeDirection)
                                                                    userInfo:nil
                                                                     repeats:YES];
                
            }];
            
            break;
        }
    }
}


#pragma mark - menu controls

- (void)pauseGame
{
    [super pauseGame];
    if (!self.gamePause) {
        [super menuFade:NO];
        self.gamePause = YES;
        [self.moveTimer invalidate];
    } else {
        [self startMoveTimer];
    }
}

- (void)backgroundPauseGame
{
    [super backgroundPauseGame];
    [self.moveTimer invalidate];
}

- (void)resumeGame
{
    [super resumeGame];
    if (!isCheckingCombo)
        self.moveTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                                     target:self
                                                   selector:@selector(changeDirection)
                                                   userInfo:nil
                                                    repeats:YES];
}

- (void)retryGame
{
    [super retryGame];
    numDotAte = 0;
    maxCombos = 0;
    score = 0;
    timeInterval = 0.2;
    maxCombos = 0;
    [self setScore];
    
//    [self.snake snakeHead].alpha = 0;
    [self.snake resetSnake];
    [self.gamePad resetClassicGamePad];
    [self startMoveTimer];
}

- (void)backToMenu
{
    [self.moveTimer invalidate];
    [super backToMenu];
}

- (void)startMoveTimer
{
    [super startMoveTimer];
    self.moveTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self
                                               selector:@selector(changeDirection)
                                               userInfo:nil
                                                repeats:YES];
}

#pragma mark - Setscore

- (void)setScore
{
    NSInteger comboAdder = 50;
    for (int i = 0 ; i < [self.snake combos] ; i ++) {
        score += comboAdder;
        comboAdder *= 2;
    }
    self.snake.combos = 0;
    numDotAte++;
    score++;
    scoreLabel.text = [numFormatter stringFromNumber:[NSNumber numberWithInteger:score]];
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//#pragma mark - Game state
//
//- (void)countDown
//{
//    if (counter == 0) {
//        self.gamePad.userInteractionEnabled = YES;
//        [countDownTimer invalidate];
//        counter = 3;
//
//        [self.gamePad hideAllAssets];
//
//        self.gamePad.alpha = 0;
//        [UIView animateWithDuration:1 animations:^{
//            [self.snake snakeHead].alpha = 1;
//            [self.gamePad setupDotForGameStart:[self.snake snakeHead].frame];
//
//        } completion:^(BOOL finished) {
//
//            moveTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self
//                                                       selector:@selector(changeDirection)
//                                                       userInfo:nil
//                                                        repeats:YES];
//        }];
//    }
//    else {
////        [self.gamePad counterDots:counter];
//        counter--;
//    }
//}
//
//- (void)startCoundDown
//{
//    countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self
//                                                    selector:@selector(countDown)
//                                                    userInfo:nil
//                                                     repeats:YES];
//}

@end
