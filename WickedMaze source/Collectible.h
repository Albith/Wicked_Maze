//
//  Collectible.h
//  Wicked Maze
//
//  Created by Albith Delgado on 1/21/12.
//  Copyright 2012 __Albith Delgado__. All rights reserved.
//

#import "gameEntity.h"

//This class is used to manage the creation and collection of coins in the game world.
@interface Collectible : gameEntity {
    
    id spinAnimation;
    id sparkleAnimation;
    
}

//constructors
+(id) collectibleWithWorld:(b2World*)world andPosition:(CGPoint)goalPosition andId:(int)collectibleId;
-(id) initWithWorld:(b2World*)world andPosition:(CGPoint)goalPosition andId:(int)collectibleId;
-(void) createCollectibleInWorld:(b2World*)world andPosition:(CGPoint)goalPosition andId:(int)collectibleId;

//class methods
-(void)itemCollected;

@end
