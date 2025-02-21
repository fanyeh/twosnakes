//
//  TutorialViewController.m
//  Bomb Blocks
//
//  Created by Jack Yeh on 2014/9/23.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "TutorialViewController.h"
#import "ParticleView.h"
#import "CustomLabel.h"
#import "ClassicGameController.h"

@interface TutorialViewController ()
{
    UIView *blockTypeView;
    UIView *bombTypeView;
    CustomLabel *howToPlayLabel;
    CGFloat titleSize;
    CGFloat titlePosY;
    CGRect nextButtonFrame;
    CGRect previousButtonFrame;
    UIButton *mainNextButton;
    UIButton *mainCloseButton;
    NSString * language;
    CGFloat blockFontSize;
    CGFloat subFontSize;
    CGFloat shiftX;
}
@property (weak, nonatomic) IBOutlet UILabel *tut1;
@property (weak, nonatomic) IBOutlet UILabel *tut2;
@property (weak, nonatomic) IBOutlet UILabel *tut3;
@property (weak, nonatomic) IBOutlet UILabel *tut4;
@property (weak, nonatomic) IBOutlet UIView *labelGroupView;
@property (weak, nonatomic) IBOutlet UIImageView *tut1ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *tut2ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *tut3ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *tut4ImageView;

@end

@implementation TutorialViewController

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
    // Do any additional setup after loading the view from its nib.
    
    UIImageView *bgImageView;
    if (_bgImage)
        bgImageView = [[UIImageView alloc]initWithImage:_bgImage];
    else
        bgImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Background.png"]];
    [self.view addSubview:bgImageView];
    [self.view sendSubviewToBack:bgImageView];
    
    _tut1.text = [NSString stringWithFormat:@"%@", NSLocalizedString(@"Swipe to move blocks", nil)];
    _tut2.text = [NSString stringWithFormat:@"%@", NSLocalizedString(@"Line up blocks to cancel blocks", nil)];
    _tut3.text = [NSString stringWithFormat:@"%@", NSLocalizedString(@"Cancel more blocks to pop bombs", nil)];
    _tut4.text = [NSString stringWithFormat:@"%@", NSLocalizedString(@"Line up with blocks to trigger bomb", nil)];
    
    
    language = [[NSLocale preferredLanguages] objectAtIndex:0];
    titleSize = 45;
    titlePosY = 10;
    blockFontSize = 19;
    subFontSize = 16;
    CGFloat nextButtonSize = 35;

    if ([language isEqualToString:@"ja"]||screenHeight < 568) {
        blockFontSize = 16;
        titleSize = 35;
        blockFontSize = 16;
        subFontSize = 14;
        _tut1.font = [UIFont fontWithName:@"DINAlternate-Bold" size:blockFontSize];
        _tut2.font = [UIFont fontWithName:@"DINAlternate-Bold" size:blockFontSize];
        _tut3.font = [UIFont fontWithName:@"DINAlternate-Bold" size:blockFontSize];
        _tut4.font = [UIFont fontWithName:@"DINAlternate-Bold" size:blockFontSize];
    }
    
    if(screenHeight > 568 && IS_IPhone) {
        titlePosY = 30;
        titleSize = titleSize + 5;
        shiftX = screenWidth - _labelGroupView.frame.size.width;
        _labelGroupView.frame = CGRectMake(0, _labelGroupView.frame.origin.y, screenWidth, _labelGroupView.frame.size.height);
        blockFontSize = 20;

        if (screenHeight > 667) {
            [self shiftViewForIpad:_tut1 shiftValueX:shiftX*0.7 shiftValueY:-10];
            [self shiftViewForIpad:_tut1ImageView shiftValueX:shiftX*0.4 shiftValueY:10];
            
            [self shiftViewForIpad:_tut3 shiftValueX:shiftX*0.7 shiftValueY:80];
            [self shiftViewForIpad:_tut3ImageView shiftValueX:shiftX*0.4 shiftValueY:100];
            
            [self shiftViewForIpad:_tut2 shiftValueX:shiftX*1.2 shiftValueY:40];
            [self shiftViewForIpad:_tut2ImageView shiftValueX:shiftX*0.9 shiftValueY:60];

            [self shiftViewForIpad:_tut4 shiftValueX:shiftX*1.0 shiftValueY:110];
            [self shiftViewForIpad:_tut4ImageView shiftValueX:shiftX*0.6 shiftValueY:130];
            
            _tut1.frame = CGRectMake(_tut1.frame.origin.x, _tut1.frame.origin.y, _tut1.frame.size.width/1.5, _tut1.frame.size.height);
            _tut2.frame = CGRectMake(_tut2.frame.origin.x, _tut2.frame.origin.y, _tut2.frame.size.width/1.5, _tut2.frame.size.height);
            _tut3.frame = CGRectMake(_tut3.frame.origin.x, _tut3.frame.origin.y, _tut3.frame.size.width/1.6, _tut3.frame.size.height);
            _tut4.frame = CGRectMake(_tut4.frame.origin.x, _tut4.frame.origin.y, _tut4.frame.size.width/1.4, _tut4.frame.size.height);
            
            
        } else {
            
            [self shiftViewForIphone:_tut1 shiftValueX:shiftX*0.7 shiftValueY:-10];
            [self shiftViewForIphone:_tut1ImageView shiftValueX:shiftX*0.4 shiftValueY:10];
            
            [self shiftViewForIphone:_tut3 shiftValueX:shiftX*0.7 shiftValueY:60];
            [self shiftViewForIphone:_tut3ImageView shiftValueX:shiftX*0.4 shiftValueY:80];
            
            [self shiftViewForIphone:_tut2 shiftValueX:shiftX*1.2 shiftValueY:40];
            [self shiftViewForIphone:_tut2ImageView shiftValueX:shiftX*0.9 shiftValueY:60];
            
            [self shiftViewForIphone:_tut4 shiftValueX:shiftX*1.0 shiftValueY:90];
            [self shiftViewForIphone:_tut4ImageView shiftValueX:shiftX*0.6 shiftValueY:110];
            
            _tut1.frame = CGRectMake(_tut1.frame.origin.x, _tut1.frame.origin.y, _tut1.frame.size.width/1.5, _tut1.frame.size.height);
            _tut2.frame = CGRectMake(_tut2.frame.origin.x, _tut2.frame.origin.y, _tut2.frame.size.width/1.4, _tut2.frame.size.height);
            _tut3.frame = CGRectMake(_tut3.frame.origin.x, _tut3.frame.origin.y, _tut3.frame.size.width/1.5, _tut3.frame.size.height);
            _tut4.frame = CGRectMake(_tut4.frame.origin.x, _tut4.frame.origin.y, _tut4.frame.size.width/1.4, _tut4.frame.size.height);
            
            if ([language isEqualToString:@"ja"]||screenHeight < 568)
                blockFontSize = 17;

        }

        _tut1.font = [UIFont fontWithName:@"DINAlternate-Bold" size:blockFontSize];
        _tut2.font = [UIFont fontWithName:@"DINAlternate-Bold" size:blockFontSize];
        _tut3.font = [UIFont fontWithName:@"DINAlternate-Bold" size:blockFontSize];
        _tut4.font = [UIFont fontWithName:@"DINAlternate-Bold" size:blockFontSize];
        
    } else if (IS_IPad) {
        _tut1.font = [UIFont fontWithName:@"DINAlternate-Bold" size:blockFontSize/IPadMiniRatio];
        _tut2.font = [UIFont fontWithName:@"DINAlternate-Bold" size:blockFontSize/IPadMiniRatio];
        _tut3.font = [UIFont fontWithName:@"DINAlternate-Bold" size:blockFontSize/IPadMiniRatio];
        _tut4.font = [UIFont fontWithName:@"DINAlternate-Bold" size:blockFontSize/IPadMiniRatio];
        
        shiftX = screenWidth - _labelGroupView.frame.size.width;
        _labelGroupView.frame = CGRectMake(0, _labelGroupView.frame.origin.y, screenWidth, _labelGroupView.frame.size.height);
        
        [self shiftViewForIpad:_tut1 shiftValueX:shiftX*0.6 shiftValueY:90];
        [self shiftViewForIpad:_tut1ImageView shiftValueX:shiftX*0.65 shiftValueY:130];
        
        [self shiftViewForIpad:_tut3 shiftValueX:shiftX*0.6 shiftValueY:230];
        [self shiftViewForIpad:_tut3ImageView shiftValueX:shiftX*0.6 shiftValueY:280];
        
        [self shiftViewForIpad:_tut2 shiftValueX:shiftX*1.1 shiftValueY:150];
        [self shiftViewForIpad:_tut2ImageView shiftValueX:shiftX*1.1 shiftValueY:190];
        
        [self shiftViewForIpad:_tut4 shiftValueX:shiftX*1.1 shiftValueY:250];
        [self shiftViewForIpad:_tut4ImageView shiftValueX:shiftX*1.1 shiftValueY:300];

        titleSize = titleSize/IPadMiniRatio;
        titlePosY = 50;
        nextButtonSize = 60;
    } else if (screenHeight < 568) {
        
        [self shiftViewIPhone4:_tut1];
        [self shiftViewIPhone4:_tut2];
        [self shiftViewIPhone4:_tut3];
        [self shiftViewIPhone4:_tut4];

        [self shiftViewIPhone4:_tut1ImageView];
        [self shiftViewIPhone4:_tut2ImageView];
        [self shiftViewIPhone4:_tut3ImageView];
        [self shiftViewIPhone4:_tut4ImageView];
    }
    
    nextButtonFrame = CGRectMake(screenWidth-(nextButtonSize+10),screenHeight-(nextButtonSize+10),nextButtonSize,nextButtonSize);
    previousButtonFrame = CGRectMake(10,screenHeight-(nextButtonSize+10),nextButtonSize,nextButtonSize);
    
    mainNextButton = [[UIButton alloc]initWithFrame:nextButtonFrame];
    [mainNextButton setImage:[UIImage imageNamed:@"nextButton.png"] forState:UIControlStateNormal];
    [mainNextButton addTarget:self action:@selector(nextToBlock:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:mainNextButton];
    
    mainCloseButton = [[UIButton alloc]initWithFrame:previousButtonFrame];
    [mainCloseButton setImage:[UIImage imageNamed:@"closeButton.png"] forState:UIControlStateNormal];
    [mainCloseButton addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:mainCloseButton];

    howToPlayLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(0, titlePosY, screenWidth, titleSize) fontSize:titleSize-5];
    howToPlayLabel.text = NSLocalizedString(@"How To Play",nil);
    [self.view addSubview:howToPlayLabel];

    _labelGroupView.center = self.view.center;
}

-(void)shiftViewIPhone4:(UIView *)view
{
    view.frame = CGRectOffset(view.frame, 0, -50);
}

-(void)shiftViewForIpad:(UIView *)view shiftValueX:(CGFloat)valueX shiftValueY:(CGFloat)valueY
{
    view.frame = CGRectOffset(view.frame, valueX, valueY);
    view.frame = CGRectMake(view.frame.origin.x,view.frame.origin.y,view.frame.size.width/IPadMiniRatio,view.frame.size.height/IPadMiniRatio);
}

-(void)shiftViewForIphone:(UIView *)view shiftValueX:(CGFloat)valueX shiftValueY:(CGFloat)valueY
{
    view.frame = CGRectOffset(view.frame, valueX, valueY);
    view.frame = CGRectMake(view.frame.origin.x,view.frame.origin.y,view.frame.size.width/0.7,view.frame.size.height/0.7);
}

-(void)nextToBlock:(UIButton *)button
{
    [self buttonAnimation:button];
    _labelGroupView.hidden = YES;
    howToPlayLabel.hidden = YES;
    mainCloseButton.hidden = YES;
    mainNextButton.hidden = YES;
    [self showBlockTypeView];
}

-(void)previousToMain:(UIButton *)button
{
    [self buttonAnimation:button];
    [UIView animateWithDuration:0.5 animations:^{
        blockTypeView.frame = CGRectOffset(blockTypeView.frame, screenWidth, 0);
    }completion:^(BOOL finished) {
        _labelGroupView.hidden = NO;
        howToPlayLabel.hidden = NO;
        mainCloseButton.hidden = NO;
        mainNextButton.hidden = NO;
    }];
}

-(void)nextToBomb:(UIButton *)button
{
    [self buttonAnimation:button];
    blockTypeView.frame = CGRectOffset(blockTypeView.frame, -screenWidth, 0);
    [self showBombTypeView];
}

-(void)previousToBlock:(UIButton *)button
{
    [self buttonAnimation:button];
    [UIView animateWithDuration:0.5 animations:^{
        bombTypeView.frame = CGRectOffset(bombTypeView.frame, screenWidth, 0);
    }completion:^(BOOL finished) {
        blockTypeView.frame = CGRectOffset(blockTypeView.frame, screenWidth, 0);
    }];
}

- (void)showBlockTypeView
{
    blockTypeView = [[UIView alloc]initWithFrame:self.view.frame];
    blockTypeView.frame = CGRectOffset(blockTypeView.frame, screenWidth,0);
    [self.view addSubview:blockTypeView];
    
    UIButton *nextButton = [[UIButton alloc]initWithFrame:nextButtonFrame];
    [nextButton setImage:[UIImage imageNamed:@"nextButton.png"] forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextToBomb:) forControlEvents:UIControlEventTouchDown];
    [blockTypeView addSubview:nextButton];
    
    UIButton *previousButton = [[UIButton alloc]initWithFrame:previousButtonFrame];
    [previousButton setImage:[UIImage imageNamed:@"previousButton.png"] forState:UIControlStateNormal];
    [previousButton addTarget:self action:@selector(previousToMain:) forControlEvents:UIControlEventTouchDown];
    [blockTypeView addSubview:previousButton];
    
    CustomLabel *titleLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(0, titlePosY, screenWidth, titleSize) fontSize:titleSize-5];
    titleLabel.text = NSLocalizedString(@"Block Type",nil);
    [blockTypeView addSubview:titleLabel];
    
    CGFloat imageHeight = 45;
    CGFloat imageWidth = 249;
    CGFloat xCord = (screenWidth - imageWidth)/2;
    CGFloat labelSize = 60;
    CGFloat gapBetweenBlock = 30;
    CGFloat gapOffest = 5;
    CGFloat yStart = titleLabel.frame.origin.y+titleSize+25;
    CGFloat descOffsetX = 20;
    CGFloat descLabelWidth = screenWidth - descOffsetX*2;

    if (screenHeight < 568) {
        labelSize = blockFontSize*2+10;
        
    } else if (screenHeight > 568 && IS_IPhone) {
        yStart = yStart + 15;
        //blockFontSize = 20;
        gapBetweenBlock = 40;
        
        if (screenHeight > 667)
            gapBetweenBlock = 75;
        else if (screenHeight == 667)
            gapBetweenBlock = 50;

    } else if (IS_IPad) {
        yStart = yStart + 30;
        blockFontSize = 30;
        imageHeight = imageHeight/IPadMiniRatio; //75
        imageWidth = imageWidth/IPadMiniRatio; //415
        xCord = (screenWidth - imageWidth)/2;
        gapBetweenBlock = 40/IPadMiniRatio;
    }

    // Level 1
    CustomLabel *level1Label = [[CustomLabel alloc]initWithFrame:CGRectMake(descOffsetX,
                                                                            yStart,
                                                                            descLabelWidth,
                                                                            labelSize)
                                                        fontSize:blockFontSize];
    level1Label.numberOfLines = -1;
    level1Label.lineBreakMode = NSLineBreakByTruncatingTail;
    level1Label.text = NSLocalizedString(@"Type A : Movable , 1 x combo to eliminate", nil);
    [blockTypeView addSubview:level1Label];
    UIImageView *level1Block = [[UIImageView alloc]initWithFrame:CGRectMake(xCord,
                                                                            level1Label.frame.origin.y+labelSize+gapOffest,
                                                                            imageWidth,
                                                                            imageHeight)];
    level1Block.image = [UIImage imageNamed:@"Level1Block.png"];
    
    // Level 2
    CustomLabel *level2Label = [[CustomLabel alloc]initWithFrame:CGRectMake(descOffsetX,
                                                                            level1Block.frame.origin.y+imageHeight+gapBetweenBlock,
                                                                            descLabelWidth,
                                                                            labelSize)
                                                        fontSize:blockFontSize];
    level2Label.numberOfLines = -1;
    level2Label.text = NSLocalizedString(@"Type B : Unmovable , 2 x combo to eliminate", nil);
    [blockTypeView addSubview:level2Label];
    UIImageView *level2Block = [[UIImageView alloc]initWithFrame:CGRectMake(xCord,
                                                                            level2Label.frame.origin.y+labelSize+gapOffest,
                                                                            imageWidth,
                                                                            imageHeight)];
    level2Block.image = [UIImage imageNamed:@"Level2Block.png"];
    
    // Level 3
    CustomLabel *level3Label = [[CustomLabel alloc]initWithFrame:CGRectMake(descOffsetX,
                                                                            level2Block.frame.origin.y+imageHeight+gapBetweenBlock,
                                                                            descLabelWidth,
                                                                            labelSize)
                                                        fontSize:blockFontSize];
    level3Label.numberOfLines = -1;
    level3Label.text = NSLocalizedString(@"Type C : Unmovable , 3 x combo to eliminate", nil);
    [blockTypeView addSubview:level3Label];
    UIImageView *level3Block = [[UIImageView alloc]initWithFrame:CGRectMake(xCord,
                                                                            level3Label.frame.origin.y+labelSize+gapOffest,
                                                                            imageWidth,
                                                                            imageHeight)];
    level3Block.image = [UIImage imageNamed:@"Level3Block.png"];
    
    [blockTypeView addSubview:level1Block];
    [blockTypeView addSubview:level2Block];
    [blockTypeView addSubview:level3Block];
    
    [UIView animateWithDuration:0.5 animations:^{
        blockTypeView.frame = CGRectOffset(blockTypeView.frame,  -screenWidth,0);
    }];
}

-(void)showBombTypeView
{
    bombTypeView = [[UIView alloc]initWithFrame:self.view.frame];
    bombTypeView.frame = CGRectOffset(bombTypeView.frame, screenWidth, 0);
    [self.view addSubview:bombTypeView];
    
    UIButton *closeButton = [[UIButton alloc]initWithFrame:nextButtonFrame];
    [closeButton setImage:[UIImage imageNamed:@"closeButton.png"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchDown];
    [bombTypeView addSubview:closeButton];
    
    UIButton *previousButton = [[UIButton alloc]initWithFrame:previousButtonFrame];
    [previousButton setImage:[UIImage imageNamed:@"previousButton.png"] forState:UIControlStateNormal];
    [previousButton addTarget:self action:@selector(previousToBlock:) forControlEvents:UIControlEventTouchDown];
    [bombTypeView addSubview:previousButton];
    
    CustomLabel *titleLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(0, titlePosY, screenWidth, titleSize) fontSize:titleSize-5];
    titleLabel.text = NSLocalizedString(@"Bomb Type",nil);
    [bombTypeView addSubview:titleLabel];
    
    CGFloat imageSize = 45;
    CGFloat xCord = 10;
    CGFloat xGap = 20;
    CGFloat yOffset = imageSize+40;
    CGFloat labelWidth = screenWidth - (xCord+imageSize+xGap+5);
    CGFloat fontSize = 21;
    CGFloat yStart = titleLabel.frame.origin.y+titleSize+40;
    CGFloat descLabelHeight = 50;
    CGFloat descLabelWidth = labelWidth;
    
    if (screenHeight < 568) {
        yStart = yStart - 15;
        yOffset = yOffset - 10;
        fontSize = 20;
    } else if (screenHeight > 568 && IS_IPhone) {
        yStart = yStart + 15;
        fontSize = 23;
        subFontSize = 17;
        descLabelWidth = descLabelWidth - 5;
        
        if (screenHeight > 667)
            yOffset = yOffset + 25;
        else if (screenHeight == 667)
            yOffset = yOffset + 10;

    } else if (IS_IPad) {
        imageSize = 75;
        fontSize = 38;
        subFontSize = 26;
        xCord = 30;
        yOffset = imageSize + 40/IPadMiniRatio;;
        xGap = xGap/IPadMiniRatio;
        labelWidth = screenWidth - (xCord+imageSize+xGap+5);
        yStart = yStart + 20;
        descLabelWidth = labelWidth;
        descLabelHeight = fontSize/21*50;
    }
    
    // Vertical Bomb Image -------------------------------------------------- //
    UIImageView *verticalBombView = [[UIImageView alloc]initWithFrame:CGRectMake(xCord,
                                                                                 yStart ,
                                                                                 imageSize,
                                                                                 imageSize)];
    verticalBombView.image = [UIImage imageNamed:@"verticalBomb.png"];
    
    // Vertical Bomb Name
    CustomLabel *verticalLabel  = [[CustomLabel alloc]initWithFrame:CGRectMake(xCord+imageSize+xGap,
                                                                               yStart-10,
                                                                               labelWidth,
                                                                               fontSize)
                                                           fontSize:fontSize];
    verticalLabel.text = NSLocalizedString(@"V-Bomb", nil) ;
    verticalLabel.textAlignment = NSTextAlignmentLeft;
    
    // Vertical Bomb Description
    CustomLabel *verticalDescLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(xCord+imageSize+xGap,
                                                                                  yStart-10,
                                                                                  descLabelWidth,
                                                                                  descLabelHeight)
                                                              fontSize:subFontSize];
    
    verticalDescLabel.frame = CGRectOffset(verticalDescLabel.frame, 0, fontSize);
    verticalDescLabel.textAlignment = NSTextAlignmentLeft;
    verticalDescLabel.numberOfLines = -1;
    verticalDescLabel.text = NSLocalizedString(@"Trigger to eliminate all blocks/bombs in vertical line",nil);
    verticalDescLabel.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];
    
    [bombTypeView addSubview:verticalBombView];
    [bombTypeView addSubview:verticalLabel];
    [bombTypeView addSubview:verticalDescLabel];
    
    // Horizontal Bomb Image -------------------------------------------------- //
    UIImageView *horizontalBombView = [[UIImageView alloc]initWithFrame:verticalBombView.frame];
    horizontalBombView.frame = CGRectOffset(verticalBombView.frame, 0, yOffset);
    horizontalBombView.image = [UIImage imageNamed:@"horizontalBomb.png"];
    
    // Horiztiontal Bomb Name
    CustomLabel *horizontalLabel  = [[CustomLabel alloc]initWithFrame:verticalLabel.frame
                                                             fontSize:fontSize];
    horizontalLabel.frame = CGRectOffset(verticalLabel.frame, 0, yOffset);
    horizontalLabel.text = NSLocalizedString(@"H-Bomb", nil);
    horizontalLabel.textAlignment = NSTextAlignmentLeft;
    
    // Horizontal Bomb Description
    CustomLabel *horizontalDescLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(horizontalLabel.frame.origin.x,
                                                                                    horizontalLabel.frame.origin.y,
                                                                                    descLabelWidth,
                                                                                    descLabelHeight)
                                                                fontSize:subFontSize];
    
    horizontalDescLabel.frame = CGRectOffset(horizontalDescLabel.frame, 0, fontSize);
    horizontalDescLabel.textAlignment = NSTextAlignmentLeft;
    horizontalDescLabel.numberOfLines = -1;
    horizontalDescLabel.text = NSLocalizedString(@"Trigger to eliminate all blocks/bombs in horizo​​ntal line",nil);
    horizontalDescLabel.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];

    [bombTypeView addSubview:horizontalBombView];
    [bombTypeView addSubview:horizontalLabel];
    [bombTypeView addSubview:horizontalDescLabel];
    
    // Random Bomb Image -------------------------------------------------- //
    UIImageView *randomBombView = [[UIImageView alloc]initWithFrame:horizontalBombView.frame];
    randomBombView.frame = CGRectOffset(horizontalBombView.frame, 0, yOffset);
    randomBombView.image = [UIImage imageNamed:@"randomBombTut.png"];
    
    // Random Bomb Name
    CustomLabel *randomLabel  = [[CustomLabel alloc]initWithFrame:horizontalLabel.frame
                                                         fontSize:fontSize];
    randomLabel.frame = CGRectOffset(horizontalLabel.frame, 0, yOffset);
    randomLabel.text = NSLocalizedString(@"R-Bomb", nil);
    randomLabel.textAlignment = NSTextAlignmentLeft;
    
    // Random Bomb Description
    CustomLabel *randomDescLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(randomLabel.frame.origin.x,
                                                                                randomLabel.frame.origin.y,
                                                                                descLabelWidth,
                                                                                descLabelHeight)
                                                            fontSize:subFontSize];
    
    randomDescLabel.frame = CGRectOffset(randomDescLabel.frame, 0, fontSize);
    randomDescLabel.textAlignment = NSTextAlignmentLeft;
    randomDescLabel.numberOfLines = -1;
    randomDescLabel.text = NSLocalizedString(@"Trigger to randomly swap all blocks postion",nil);
    randomDescLabel.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];

    [bombTypeView addSubview:randomBombView];
    [bombTypeView addSubview:randomLabel];
    [bombTypeView addSubview:randomDescLabel];
    
    // Circle Bomb Image -------------------------------------------------- //
    UIImageView *circleBombView = [[UIImageView alloc]initWithFrame:randomBombView.frame];
    circleBombView.frame = CGRectOffset(randomBombView.frame, 0, yOffset);
    circleBombView.image = [UIImage imageNamed:@"circleBomb.png"];
    
    // Circle Bomb Name
    CustomLabel *circleLabel  = [[CustomLabel alloc]initWithFrame:randomLabel.frame
                                                         fontSize:fontSize];
    circleLabel.frame = CGRectOffset(randomLabel.frame, 0, yOffset);
    circleLabel.text = NSLocalizedString(@"S-Bomb", nil);
    circleLabel.textAlignment = NSTextAlignmentLeft;

    // Circle Bomb Description
    CustomLabel *circleDescLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(circleLabel.frame.origin.x,
                                                                                circleLabel.frame.origin.y,
                                                                                descLabelWidth,
                                                                                descLabelHeight)
                                                            fontSize:subFontSize];
    
    circleDescLabel.frame = CGRectOffset(circleDescLabel.frame, 0,fontSize);
    circleDescLabel.textAlignment = NSTextAlignmentLeft;
    circleDescLabel.numberOfLines = -1;
    circleDescLabel.text = NSLocalizedString(@"Trigger to eliminate blocks/bombs within the circle",nil);
    circleDescLabel.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];

    [bombTypeView addSubview:circleBombView];
    [bombTypeView addSubview:circleLabel];
    [bombTypeView addSubview:circleDescLabel];
    
    // Color Bomb Image -------------------------------------------------- //
    UIImageView *colorBombView = [[UIImageView alloc]initWithFrame:circleBombView.frame];
    colorBombView.frame = CGRectOffset(circleBombView.frame, 0, yOffset);
    colorBombView.image = [UIImage imageNamed:@"colorBomb.png"];
    
    // Color Bomb Name
    CustomLabel *colorLabel  = [[CustomLabel alloc]initWithFrame:circleLabel.frame
                                                        fontSize:fontSize];
    colorLabel.frame = CGRectOffset(circleLabel.frame, 0, yOffset);
    colorLabel.text =NSLocalizedString(@"C-Bomb", nil);
    colorLabel.textAlignment = NSTextAlignmentLeft;
    
    // // Color Bomb Description
    CustomLabel *colorDescLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(colorLabel.frame.origin.x,
                                                                               colorLabel.frame.origin.y,
                                                                               descLabelWidth,
                                                                               descLabelHeight)
                                                           fontSize:subFontSize];
    
    colorDescLabel.frame = CGRectOffset(colorDescLabel.frame, 0, fontSize);
    colorDescLabel.textAlignment = NSTextAlignmentLeft;
    colorDescLabel.numberOfLines = -1;
    colorDescLabel.text = NSLocalizedString(@"Trigger to eliminate blocks/bombs with same color",nil);
    colorDescLabel.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];

    [bombTypeView addSubview:colorBombView];
    [bombTypeView addSubview:colorLabel];
    [bombTypeView addSubview:colorDescLabel];
    
    [UIView animateWithDuration:0.5 animations:^{
        bombTypeView.frame = CGRectOffset(bombTypeView.frame, -screenWidth,0);
    }];
}

- (void)doneAction:(UIButton *)sender
{
    [self buttonAnimation:sender];
    if ([[NSUserDefaults standardUserDefaults]integerForKey:@"tutorial"] == 1) {
        
        [[NSUserDefaults standardUserDefaults]setInteger:0 forKey:@"tutorial"];
        ClassicGameController *classicGameController =  [[ClassicGameController alloc]init];
        [self presentViewController:classicGameController animated:YES completion:nil];

    } else
        [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)buttonAnimation:(UIButton *)button
{
    [_particleView playSound:kSoundTypeButtonSound];

    CGAffineTransform t = button.transform;
    
    [UIView animateWithDuration:0.15 animations:^{
        
        button.transform = CGAffineTransformScale(t, 0.85, 0.85);
        
    } completion:^(BOOL finished) {
        
        button.transform = t;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}
@end
