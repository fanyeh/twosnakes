//
//  TwoSnakesGameController.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/4/29.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "TwoSnakesGameController.h"
#import "Snake.h"
#import "SnakeDot.h"
#import "SnakeButton.h"

@interface TwoSnakesGameController () <UIAlertViewDelegate>
{
    Snake *playerSnake;
    NSTimer *moveTimer;
    NSTimer *dotTimer;
    NSMutableArray *dotArray;
    float timeInterval;
    NSInteger numDotAte;
    NSInteger chain;
    NSInteger level;
    NSInteger combos;
    BOOL pauseGame;
    UILabel *exclamation;
    NSTimer *countDownTimer;
    NSInteger counter;
    NSInteger maxCombos;
    NSInteger score;
    
    SnakeButton *snakeButton;
}

@property (weak, nonatomic) IBOutlet UIView *snakeHeadView;
@property (weak, nonatomic) IBOutlet UIView *gamePad;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (weak, nonatomic) IBOutlet UIView *leftEye;
@property (weak, nonatomic) IBOutlet UIView *rightEye;
@property (weak, nonatomic) IBOutlet UILabel *comboLabel;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UILabel *countDownLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UIView *snakeMouth;


@end

@implementation TwoSnakesGameController

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
    
    // View Settings
    playerSnake = [[Snake alloc]initWithSnakeHead:_snakeHeadView andDirection:kMoveDirectionLeft];
    [self createAllDots];
    _levelLabel.text = [NSString stringWithFormat:@"Levle : %ld",level];
    
    _leftEye.layer.cornerRadius = _leftEye.frame.size.width/2;
    _rightEye.layer.cornerRadius = _rightEye.frame.size.width/2;
    
    _leftEye.layer.borderWidth = 1.5;
    _leftEye.layer.borderColor = [[UIColor whiteColor]CGColor];
    
    _rightEye.layer.borderWidth = 1.5;
    _rightEye.layer.borderColor = [[UIColor whiteColor]CGColor];
    
    _snakeMouth.layer.cornerRadius = _snakeMouth.frame.size.width/2;
    _snakeMouth.layer.borderWidth = 0.5;
    _snakeMouth.layer.borderColor = [[UIColor whiteColor]CGColor];
    
    playerSnake.gamePad = _gamePad;
    _gamePad.layer.borderWidth = 1;
    
    exclamation = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    exclamation.hidden = YES;
    exclamation.text = @"!";
    exclamation.textColor = [UIColor blackColor];
    exclamation.textAlignment = NSTextAlignmentCenter;
    exclamation.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
    [_gamePad addSubview:exclamation];
    _gamePad.layer.cornerRadius = 5;
    
    snakeButton = [[SnakeButton alloc]initWithTitle:@"Play"];
    UITapGestureRecognizer *snakeButtonTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(startCoundDown)];
    [snakeButton addGestureRecognizer:snakeButtonTap];
    
    [self.view addSubview:snakeButton];

    // Game Settings
    timeInterval = 0.2;
    numDotAte = 0;
    chain = 2;
    level = 1;
    pauseGame = NO;
    counter =  3;
    maxCombos = 0;
    score = 0;
}

- (void)countDown
{
    if (counter == 0) {
        [countDownTimer invalidate];
        counter = 3;
        _countDownLabel.text = [NSString stringWithFormat:@"%ld",counter];
        _countDownLabel.hidden = YES;
        [self startGame];
    }
    else {
        _countDownLabel.text = [NSString stringWithFormat:@"%ld",counter];
        counter--;
    }
}

- (void)startCoundDown
{
    [snakeButton changeState];
    //countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown) userInfo:nil repeats:YES];

}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self.view];
    [playerSnake setTurningNode:location];
}

-(void)changeDirection
{
    if ([playerSnake changeDirectionWithGameIsOver:NO ]) {
        [moveTimer invalidate];

        NSString *alertTitle = @"Game Over";

        // Set score record
        if (score > [[NSUserDefaults standardUserDefaults]integerForKey:@"highestScore"]) {
            [[NSUserDefaults standardUserDefaults]setInteger:score forKey:@"highestScore"];
            alertTitle = @"New Score Record";
        }
        
        if (level > [[NSUserDefaults standardUserDefaults]integerForKey:@"highestLevel"]) {
            [[NSUserDefaults standardUserDefaults]setInteger:score forKey:@"highestLevel"];
            alertTitle = @"New Level Record";
        }
        
        if (maxCombos > [[NSUserDefaults standardUserDefaults]integerForKey:@"maxCombo"]) {
            [[NSUserDefaults standardUserDefaults]setInteger:score forKey:@"highestScore"];
            alertTitle = @"New Combo Record";
        }
        
        UIAlertView *gameOverAlert = [[UIAlertView alloc]initWithTitle:alertTitle message:nil delegate:self cancelButtonTitle:@"Restart" otherButtonTitles:nil , nil];
        [gameOverAlert show];

    } else {
        [self isEatingDot];
    }
}

#pragma mark - Game state

- (IBAction)pauseGame:(id)sender
{
    if (!pauseGame) {
        pauseGame = YES;
        [moveTimer invalidate];
        [_pauseButton setTitle:@"Continue" forState:UIControlStateNormal];
    } else {
        pauseGame = NO;
        
        moveTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(changeDirection) userInfo:nil repeats:YES];
        [_pauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    }
}

- (void)startGame
{
    moveTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(changeDirection) userInfo:nil repeats:YES];
    dotTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(showDots) userInfo:nil repeats:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Game settings
    timeInterval = 0.2;
    countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    _countDownLabel.hidden = NO;
    numDotAte = 0;
    chain = 2;
    level = 1;
    score = 0;
    
    // View settings
    for (UIView *v in [playerSnake snakeBody]) {
        [v removeFromSuperview];
    }
    _snakeHeadView.frame = CGRectMake(147, 147, 20, 20);
    
    for (SnakeDot *d in dotArray) {
        d.hidden = NO;
        d.smallDot.backgroundColor = [self dotColor];
    }

    _scoreLabel.text = [NSString stringWithFormat:@"%ld",score];

    _levelLabel.text = [NSString stringWithFormat:@"Levle : %ld",level];

    [playerSnake resetSnake:_snakeHeadView andDirection:[playerSnake headDirection]];
    [_gamePad addSubview:_snakeHeadView];
}

#pragma mark - Combo

- (BOOL)checkCombo:(void(^)(void))completeBlock
{

    UIColor *repeatColor;
    NSInteger startIndex = 0;
    NSInteger endIndex = 0;
    NSMutableArray *snakeBody = [playerSnake snakeBody];
    for (UIView *v in snakeBody) {
        if (![repeatColor isEqual:v.backgroundColor]) {
            repeatColor = v.backgroundColor;
            startIndex = [snakeBody indexOfObject:v];
            endIndex = startIndex;
        } else {
            endIndex = [snakeBody indexOfObject:v];
        }
        
        if (endIndex - startIndex == chain) {
            // Invalidate timer if there combo
            exclamation.hidden = NO;

            
            switch ([playerSnake headDirection]) {
                case kMoveDirectionUp:
                    exclamation.frame = CGRectOffset([playerSnake snakeHead].frame, -21, 0);
                    break;
                case kMoveDirectionDown:
                    exclamation.frame = CGRectOffset([playerSnake snakeHead].frame, -21, 0);
                    break;
                case kMoveDirectionRight:
                    exclamation.frame = CGRectOffset([playerSnake snakeHead].frame, 0, -21);
                    break;
                case kMoveDirectionLeft:
                    exclamation.frame = CGRectOffset([playerSnake snakeHead].frame, 0, -21);
                    break;
            }
            _leftEye.alpha = 0;
            _rightEye.alpha = 0;
            
            // Shake snake head
            if (!playerSnake.isRotate) {
                [playerSnake startRotate];
            }
            
            _snakeMouth.backgroundColor = v.backgroundColor;

            
            [UIView animateWithDuration:1 animations:^{
                
                _leftEye.layer.borderWidth = 0.5;
                _rightEye.layer.borderWidth = 0.5;
                _leftEye.alpha = 1;
                _rightEye.alpha = 1;

                for (NSInteger i = startIndex ; i < endIndex +1 ; i ++) {
                    UIView *u = snakeBody[i];
                    u.layer.borderWidth = 1;
                }
                
            } completion:^(BOOL finished) {
                
                _leftEye.layer.borderWidth = 1.5;
                _rightEye.layer.borderWidth = 1.5;
                
                for (NSInteger i = startIndex ; i < endIndex +1 ; i ++) {
                    UIView *u = snakeBody[i];
                    u.layer.borderWidth = 0;
                }
                combos++;
                if (combos > maxCombos) {
                    maxCombos = combos;
                }
                _comboLabel.text =  [NSString stringWithFormat:@"Combo : %ld",maxCombos];
                [self cancelSnakeBodyByColor:v.backgroundColor complete:completeBlock];
            }];

            return YES;
        }
    }
    completeBlock();
    return NO;
}

// Single body color check
- (void)cancelSnakeBodyByColor:(UIColor *)color complete:(void(^)(void))completeBlock
{
    NSMutableArray *snakeBody = [playerSnake snakeBody];
    BOOL completeCheck = YES;
    
    // Remove each body with same color
    for (UIView *v in snakeBody) {
        if ([v.backgroundColor isEqual:color]) {
            NSInteger index = [snakeBody indexOfObject:v];
            [self removeSnakeBodyByIndex:index andColor:v.backgroundColor complete:completeBlock];
            completeCheck = NO;
            break;
        }
    }
    
    // Check if there is other combos
    if (completeCheck)
        [self otherCombo:completeBlock];
}

// Single body removal
-(void)removeSnakeBodyByIndex:(NSInteger)index andColor:(UIColor *)color complete:(void(^)(void))completeBlock
{
    NSMutableArray *snakeBody = [playerSnake snakeBody];
    for (NSInteger i=index; i < [snakeBody count];i++) {
        if (i < [snakeBody count] -1) {
            // Next body
            UIView *currentBody = [snakeBody objectAtIndex:i];
            UIView *nextBody = [snakeBody objectAtIndex:i+1];
            
            [UIView animateWithDuration:0.0 animations:^{
                
                currentBody.backgroundColor = nextBody.backgroundColor;
                
            }];
        }
    }
    
    [UIView animateWithDuration:0.1 animations:^{
        
        playerSnake.snakeTail.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        [playerSnake.snakeTail removeFromSuperview];
        [playerSnake updateTurningNode];
        [playerSnake.snakeBody removeLastObject];
        [self cancelSnakeBodyByColor:color complete:completeBlock];
    }];
}

-(BOOL)otherCombo:(void(^)(void))completeBlock
{
//    [moveTimer invalidate];

    UIColor *mouthColor;
    UIColor *repeatColor;
    NSInteger startIndex = 0;
    NSInteger endIndex = 0;
    BOOL hasCombo = NO;
    NSMutableArray *snakeBody = [playerSnake snakeBody];
    
    for (UIView *v in snakeBody) {
        
        if (![repeatColor isEqual:v.backgroundColor]) {
            
            if (hasCombo) {
                // Invalidate timer if there combo
                exclamation.hidden = NO;
                
                switch ([playerSnake headDirection]) {
                    case kMoveDirectionUp:
                        exclamation.frame = CGRectOffset([playerSnake snakeHead].frame, -21, 0);
                        break;
                    case kMoveDirectionDown:
                        exclamation.frame = CGRectOffset([playerSnake snakeHead].frame, -21, 0);
                        break;
                    case kMoveDirectionRight:
                        exclamation.frame = CGRectOffset([playerSnake snakeHead].frame, 0, -21);
                        break;
                    case kMoveDirectionLeft:
                        exclamation.frame = CGRectOffset([playerSnake snakeHead].frame, 0, -21);
                        break;
                }
                _leftEye.alpha = 0;
                _rightEye.alpha = 0;
                
                _leftEye.layer.borderWidth = 0.5;
                _rightEye.layer.borderWidth = 0.5;
                
                _snakeMouth.backgroundColor = mouthColor;

                [UIView animateWithDuration:1 animations:^{
                    
                    _leftEye.alpha = 1;
                    _rightEye.alpha = 1;
                    
                    for (NSInteger i = startIndex ; i < endIndex +1 ; i ++) {
                        UIView *u = snakeBody[i];
                        u.layer.borderWidth = 1;
                    }
                    
                } completion:^(BOOL finished) {
                    
                    _leftEye.layer.borderWidth = 1.5;
                    _rightEye.layer.borderWidth = 1.5;
                    
                    for (NSInteger i = startIndex ; i < endIndex +1 ; i ++) {
                        UIView *u = snakeBody[i];
                        u.layer.borderWidth = 0;
                    }
                    
                    combos++;
                    if (combos > maxCombos) {
                        maxCombos = combos;
                    }
                    
                    _comboLabel.text =  [NSString stringWithFormat:@"Combo : %ld",maxCombos];
                    [self removeSnakeBodyByRangeStart:startIndex andRange:(endIndex - startIndex) + 1 complete:completeBlock];
                }];
                return YES;
            } else {
                repeatColor = v.backgroundColor;
                startIndex = [snakeBody indexOfObject:v];
                endIndex = startIndex;
            }
        } else {
            endIndex = [snakeBody indexOfObject:v];

            if (endIndex - startIndex == chain) {
                mouthColor = repeatColor;
                hasCombo = YES;
            }
            
            if ([v isEqual:[snakeBody lastObject]] && hasCombo) {

                switch ([playerSnake headDirection]) {
                    case kMoveDirectionUp:
                        exclamation.frame = CGRectOffset([playerSnake snakeHead].frame, -21, 0);
                        break;
                    case kMoveDirectionDown:
                        exclamation.frame = CGRectOffset([playerSnake snakeHead].frame, -21, 0);
                        break;
                    case kMoveDirectionRight:
                        exclamation.frame = CGRectOffset([playerSnake snakeHead].frame, 0, -21);
                        break;
                    case kMoveDirectionLeft:
                        exclamation.frame = CGRectOffset([playerSnake snakeHead].frame, 0, -21);
                        break;
                }
                _leftEye.alpha = 0;
                _rightEye.alpha = 0;
                
                _snakeMouth.backgroundColor = mouthColor;

                
                [UIView animateWithDuration:1 animations:^{
                    
                    _leftEye.alpha = 1;
                    _rightEye.alpha = 1;
                    
                    for (NSInteger i = startIndex ; i < endIndex +1 ; i ++) {
                        UIView *u = snakeBody[i];
                        u.layer.borderWidth = 1;
                    }
                    
                } completion:^(BOOL finished) {
                    
                    for (NSInteger i = startIndex ; i < endIndex +1 ; i ++) {
                        UIView *u = snakeBody[i];
                        u.layer.borderWidth = 0;
                    }
                    
                    combos++;
                    if (combos > maxCombos) {
                        maxCombos = combos;
                    }
                    
                    _comboLabel.text =  [NSString stringWithFormat:@"Combo : %ld",maxCombos];
                    [self removeSnakeBodyByRangeStart:startIndex andRange:(endIndex - startIndex) + 1 complete:completeBlock];
                }];
                return YES;
                
            }
        }
        
    }
    // If no other combo call the complete block
    completeBlock();
    return NO;
}

-(void)removeSnakeBodyByRangeStart:(NSInteger)start andRange:(NSInteger)range complete:(void(^)(void))completeBlock
{
    if (range == 0) {
        [self otherCombo:completeBlock];
    } else {
        NSMutableArray *snakeBody = [playerSnake snakeBody];
        for (NSInteger i=start; i < [snakeBody count] -1 ;i++) {
            
            if (i < [snakeBody count] -1) {
            
                // Next body
                UIView *currentBody = [snakeBody objectAtIndex:i];
                UIView *nextBody = [snakeBody objectAtIndex:i+1];
                currentBody.backgroundColor = nextBody.backgroundColor;
            }
        }
        
        [UIView animateWithDuration:0.1 animations:^{
            
            playerSnake.snakeTail.alpha = 0;
            
        } completion:^(BOOL finished) {
            
            [playerSnake.snakeTail removeFromSuperview];
            [playerSnake updateTurningNode];
            [playerSnake.snakeBody removeLastObject];
            [self removeSnakeBodyByRangeStart:start andRange:range-1 complete:completeBlock];
        }];

    }
}


#pragma mark - Dot

- (void)isEatingDot
{
    for (SnakeDot *d in dotArray) {
        if (!d.hidden) {
            if (CGRectIntersectsRect([playerSnake snakeHead].frame, d.frame)) {
                _snakeMouth.hidden = NO;
                _snakeMouth.backgroundColor = [UIColor whiteColor];
                
                d.hidden = YES;
                score += 10;


                _scoreLabel.text = [NSString stringWithFormat:@"%ld",score];
                
                [_gamePad addSubview:[playerSnake addSnakeBodyWithColor:d.smallDot.backgroundColor]];
                // Check if any snake body can be cancelled
                
                combos = 0;
                [moveTimer invalidate];
                [self checkCombo:^{
                    
                    if (playerSnake.isRotate) {
                        [playerSnake stopRotate];
                    }
                    

                    
                    // Increase speed for every 30 dots eaten
                    if (numDotAte%30==0 && numDotAte != 0) {
                        level++;
                        _levelLabel.text = [NSString stringWithFormat:@"Levle : %ld",level];
                        timeInterval -= 0.005;
                        
                        if (moveTimer.isValid)
                            [moveTimer invalidate];
                        
                        moveTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(changeDirection) userInfo:nil repeats:YES];
                    } else {
                        // If moveTimer is not valid (means there's combo) , restart the timer again
                        if (!moveTimer.isValid)
                            moveTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(changeDirection) userInfo:nil repeats:YES];
                    }
                    numDotAte++;
                    [self setScore];
                    combos = 0;
                    exclamation.hidden = YES;
                    
                    
                }];
                
                break;
            }
        }
        _snakeMouth.hidden = YES;

//        _snakeMouth.backgroundColor = [UIColor colorWithWhite:0.200 alpha:1.000];
    }
}

- (void)setScore
{
    NSInteger comboAdder = 50;
    for (int i = 0 ; i < combos ; i ++) {
        score += comboAdder;
        comboAdder *= 2;
    }
}

- (void)showDots
{
    for (SnakeDot *d in dotArray) {
        if (d.hidden) {
            d.smallDot.backgroundColor = [self dotColor];
            d.alpha = 0;
            [UIView animateWithDuration:1 animations:^{
                d.alpha = 1;
            }];
            d.hidden = NO;
        }
    }
}

- (void)createAllDots
{
    dotArray = [[NSMutableArray alloc]init];
    CGFloat dotPosX;
    CGFloat dotPosY;
    for (int i = 0 ; i < 14; i ++ ) {
        for (int j = 0 ; j < 17 ; j++) {
            if (i%2==1 && j%2==1) {
                
                dotPosX = i * 21;
                dotPosY = j * 21;
                
                SnakeDot *dot = [[SnakeDot alloc]initWithFrame:CGRectMake(dotPosX, dotPosY, 20, 20)];
                dot.layer.cornerRadius = 8;
                dot.smallDot.backgroundColor = [self dotColor];
                [_gamePad addSubview:dot];
                [_gamePad sendSubviewToBack:dot];
                [dotArray addObject:dot];
            }
        }
    }
    
    [self.view bringSubviewToFront:_snakeHeadView];

}

-(UIColor *)dotColor
{
    int index;
    if (level < 10) {
        index = arc4random()%4;
    }else if (level > 10) {
        index = arc4random()%5;
    } else if (level > 20) {
        index = arc4random()%6;
    }


    UIColor *color;
    switch (index) {
        case 0:
            color = [UIColor colorWithRed:1.000 green:0.208 blue:0.545 alpha:1.000];
            break;
        case 1:
            color = [UIColor colorWithRed:0.004 green:0.690 blue:0.941 alpha:1.000];
            break;
        case 2:
            color = [UIColor colorWithRed:0.682 green:0.933 blue:0.000 alpha:1.000];
            break;
        case 3:
            color = [UIColor colorWithRed:1.000 green:0.733 blue:0.125 alpha:1.000];
            break;
        case 4:
            color = [UIColor colorWithRed:0.592 green:0.408 blue:0.820 alpha:1.000];
            break;
        case 5:
            color = [UIColor colorWithRed:0.435 green:0.529 blue:0.529 alpha:1.000];
            break;
    }
    
    return color;
}

#pragma mark - Hide statu bar

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
