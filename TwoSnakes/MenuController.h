//
//  MenuController.h
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/16.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
    kGameStateNew = 0,
    kGameStateContinue
} GameState;
@interface MenuController : UIViewController
@property (nonatomic) GameState state;

- (void)pauseGameOnBackground;
@end
