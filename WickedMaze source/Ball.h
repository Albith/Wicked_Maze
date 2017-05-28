//
//  Ball.h
//  Wicked Maze
//
//  Created by Albith Delgado on 12/17/11.
//  Copyright 2012 Albith Delgado. All rights reserved.
//

//This class describes the Ball object, 
    //the object the player explores the game with.

    //Unlike other objects in the game, it has a health parameter.

#import "gameEntity.h"

@interface Ball : gameEntity {
    
    CGPoint spawnPoint;
    int health;
    BOOL isBallBeingPushedBack;

    id deathAnimation;
        
}

//The spawnPoint is saved, in case the ball breaks.
@property (readonly, nonatomic) CGPoint spawnPoint;


//------Constructors.
+(id) ballWithWorld:(b2World*)world andPosition:(CGPoint)ballPosition;
-(id) initWithWorld:(b2World*)world andPosition:(CGPoint)ballPosition;
-(void) createBallInWorld:(b2World*)world andPosition:(CGPoint)ballPosition;

//------

-(void)ballAttacked:(b2Vec2)collisionNormal;
-(void)ballAttackedByBulletWithNormal:(b2Vec2)collisionNormal;

-(void)ballHealead;
-(void)ballChanged; //Called when the ball has been hit, or cracked.


//running the deathAnimation.
-(void)runBallDeath;


@end
