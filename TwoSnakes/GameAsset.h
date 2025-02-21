//
//  GameAsset.h
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/22.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kAssetTypeYellow,
    kAssetTypeRed,
    kAssetTypeBlue,
    kAssetTypeGreen
} AssetType;

typedef enum {
    kBombTypeExplodeBlock = 0,
    kBombTypeExplodeVertical,
    kBombTypeExplodeHorizontal,
    kBombTypeSquareExplode,
    kBombTypeRandom
} BombType;

typedef struct {
    BombType bombType;
} Bomb;


@interface GameAsset : UIView

@property (nonatomic) AssetType gameAssetType;

@end
