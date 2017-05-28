//
//  Barrier.h
//  Wicked Maze
//
//  Created by Albith Delgado on 3/26/12.
//  Copyright 2012 __Albith Delgado__. All rights reserved.
//

//This class describes breakable and unlockable barriers in the game.
#import "gameEntity.h"

@interface Barrier : gameEntity {
    
    //Barrier breaking Animation.    
    id barrierShatterAnim;
    
    bool isBarrierTouched;
    
    int barrierType;
    
}


@property (assign) int barrierType;


//Barrier initialization.
+(id) barrierWithWorld:(b2World*)world 
         andPosition:(CGPoint)goalPosition 
               andId:(int)enemyId          
             andType:(int)myBarrierType
      andOrientation:(int)barrierOrientation;


-(id) initWithWorld:(b2World*)world 
        andPosition:(CGPoint)goalPosition 
              andId:(int)enemyId 
            andType:(int)myBarrierType
     andOrientation:(int)barrierOrientation;


-(void) createBarrierWithWorld:(b2World*)world 
                 andPosition:(CGPoint)goalPosition 
                       andId:(int)enemyId 
                     andType:(int)myBarrierType
              andOrientation:(int)barrierOrientation;


//Barrier methods.
    -(void)barrierBroken;   //for Breakable Barriers.
    
    //for Hard Barriers, meaning barriers that are only opened with a key, 
        //or after solving a puzzle.
    -(void)barrierRemoved;  

    //just in case...
        //-(void)barrierReset;



@end
