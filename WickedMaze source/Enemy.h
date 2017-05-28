//
//  Enemy.h
//  Wicked Maze
//
//  Created by Albith Delgado on 1/28/12.
//  Copyright 2012 __Albith Delgado__. All rights reserved.
//

#import "gameEntity.h"

//Enemies in the game are quite simple.
      //They die once they have been attacked.
      //Also, they are stationary, they do not move.

@interface Enemy : gameEntity {
   
    //Each enemy has 3 animations associated.
    id enemyAnimation;  //Idle animation.
    id deathAnimation;
    id deathAnimation2;
    
    //Keeping track of its dead or alive status.
    BOOL isEnemyTouched;
    
}

//4.14.2012   Added actionAfterDestroyed
@property (assign) int triggerInfo;


//Class constructors
+(id) enemyWithWorld:(b2World*)world 
         andPosition:(CGPoint)goalPosition 
               andId:(int)enemyId          
             andType:(int)myEnemyType
      andOrientation:(int)enemyOrientation;

-(id) initWithWorld:(b2World*)world 
        andPosition:(CGPoint)goalPosition 
              andId:(int)enemyId 
            andType:(int)myEnemyType
     andOrientation:(int)enemyOrientation;


-(void) createEnemyWithWorld:(b2World*)world 
                 andPosition:(CGPoint)goalPosition 
                       andId:(int)enemyId 
                     andType:(int)myEnemyType
        andOrientation:(int)enemyOrientation;


//Class methods.
-(void)handleEnemyTouchWithCollisionNormal:(b2Vec2)collisionNormal;
-(void)enemyKilled;
-(void)enemyKilledFast;

//Shooting method; only for Enemy Shooter Types.
-(void)callBulletsWithWait:(float)waitTime
              andShooterId:(int)shooterId;
    


@end
