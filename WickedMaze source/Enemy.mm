//
//  Enemy.mm
//  Wicked Maze
//
//  Created by Albith Delgado on 1/28/12.
//  Copyright 2012 __Albith Delgado__. All rights reserved.
//

#import "Enemy.h"
#import "GameConstants.h"
#import "GameLevel.h"

#include <math.h>   //for Math calculations.

//Special animation tags.
#define IDLE_ANIMATION_TAG 38
#define DEATH_ANIMATION_TAG 39
#define MOVE_ACTION_TAG 40

@implementation Enemy

@synthesize triggerInfo;


//Class constructors.
-(id)initWithWorld:(b2World*)world 
       andPosition:(CGPoint)goalPosition 
             andId:(int)enemyId 
           andType:(int)myEnemyType
    andOrientation:(int)enemyOrientation

{
	if ((self = [super init]))
	{
		[self createEnemyWithWorld:world andPosition:goalPosition 
                             andId:enemyId andType:myEnemyType
                        andOrientation:(int)enemyOrientation];	
	}
	return self;
}

+(id)  enemyWithWorld:(b2World*)world 
          andPosition:(CGPoint)goalPosition 
                andId:(int)enemyId 
              andType:(int)myEnemyType
       andOrientation:(int)enemyOrientation

{
	return [[[self alloc] initWithWorld:world andPosition:goalPosition 
                                  andId:enemyId andType:myEnemyType   
                         andOrientation:(int)enemyOrientation] autorelease];

}


#pragma mark -create Enemy object in Box2d world.

-(void) createEnemyWithWorld:(b2World*)world 
                 andPosition:(CGPoint)goalPosition 
                       andId:(int)enemyId 
                     andType:(int)myEnemyType
              andOrientation:(int)enemyOrientation

{
	
    
    //1.Calling the superClass gameEntity function:
    [super loadEntity:myEnemyType atPosition:goalPosition 
            withWorld:world andOrientation:enemyOrientation]; 
    entityType= ENEMIES_TAG;
    
    //Updating the sprite's tag.
    sprite.tag= enemyId;
    isEnemyTouched=FALSE;
    
    //2. Creating the flyball enemy's idle animation.
    NSMutableArray *tempFrames = [NSMutableArray array];
    
    if(myEnemyType== ENEMY_FLYBALL_TYPE)  //invincible enemies need no death animations.
        {    
                for (int i =0 ; i < 2; i++) {
                        
                        CCSpriteFrame *frame;
                        
                        frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                                [NSString stringWithFormat:@"mosquito%d.png", i]];
                        
                        [tempFrames addObject:frame];    
                }     
        
            id tempEnemyAnimation = [CCAnimation animationWithFrames:tempFrames delay:0.3f] ;   
            
            enemyAnimation = [[CCRepeatForever actionWithAction:
                            [CCAnimate actionWithAnimation:tempEnemyAnimation restoreOriginalFrame:NO]] retain];
            
            [enemyAnimation setTag:IDLE_ANIMATION_TAG];
        
                //5. Running the idle animation.
                    [sprite runAction:enemyAnimation];
    
        }
 
    //  else if(myEnemyType == ENEMY_SHOOTER_TYPE)
    //  {    
    //      Setup this animation if there are shooter enemies in the level. 
    //      This is currently called by the GameLevel.
    //      Note: this animation could be setup here instead!
    //  }   
    
    //3. Creating the "enemy killed" animation. 
    [tempFrames removeAllObjects]; 
    
    for (int i =0 ; i < 4; i++) {
        
        CCSpriteFrame *frame;
        
        frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                 [NSString stringWithFormat:@"smoke%d.png", i]];
        
        [tempFrames addObject:frame];
        
    }     
    
    id smokeAnimation = [CCAnimation animationWithFrames:tempFrames delay:0.15f] ;   
    deathAnimation = [[CCAnimate actionWithAnimation:smokeAnimation restoreOriginalFrame:NO] retain];
    
    [deathAnimation setTag:DEATH_ANIMATION_TAG];
    
    
    //4. Creating the "enemy killed" fast animation.
    
    [tempFrames removeAllObjects]; 
    
    for (int i =0 ; i < 3; i++) {
        
        CCSpriteFrame *frame;
        
        frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                 [NSString stringWithFormat:@"bling%d.png", i]];
        
        [tempFrames addObject:frame];
        
    }     
    
    id blingAnimation = [CCAnimation animationWithFrames:tempFrames delay:0.15f] ;   
    
    deathAnimation2 = [[CCAnimate actionWithAnimation:blingAnimation restoreOriginalFrame:NO] retain];
    [deathAnimation2 setTag:DEATH_ANIMATION_TAG];
    
    //5. Setting Trigger Info to No Value. 
        //triggerInfo refers to actions or sequences that can be triggered if 
            //this enemy is defeated.
        //This is used in the game to open a barrier, only if several enemies are defeated.
            //By default, enemies do not trigger any actions.
        self.triggerInfo= NO_TRIGGER;
}


#pragma mark -enemy Touched

//Handling enemy touches.
-(void)handleEnemyTouchWithCollisionNormal:(b2Vec2)collisionNormal
{
    
   if(!isEnemyTouched) 
   {    
       
       //NSLog(@"Handling Touch for Enemy number %d.", sprite.tag);
       isEnemyTouched=TRUE;
         
    //1.Get the player's velocity at the time of collision.
        b2Vec2 playerVelocity= [GameLevel sharedGameLevel].player.body->GetLinearVelocity();    
    
    //2.Handle the collision logic, which goes as follows:
        //If the player's velocity is high enough,
        //This enemy is killed.
        //Else, the player takes a hit.     
    
    //NSLog(@"playerVelocity is X %f, Y %f.", playerVelocity.x, playerVelocity.y);
    
    id resultingAction;   
       
    //Checking if the player's velocity is enough to kill the enemy.
    if( (fabsf(playerVelocity.x) > minEnemyKillVelocity ) || (fabsf(playerVelocity.y) > minEnemyKillVelocity ) )
        {   
            //This enemy is killed.
                    //NSLog(@"Enemy number %d is killed.", sprite.tag);  
           resultingAction=  [CCCallBlock actionWithBlock:
                              ^{               
                                  [[GameSoundManager sharedManager] playSoundEffect:SLOW_KILL_SOUND ];
                                  [self enemyKilled];                 
                              }];
           //If the enemy attacked triggers a barrier opening, update the trigger logic.
            if(self.triggerInfo==TRIGGER_ENEMY_GROUP_OPENS_BARRIER)
            {       
                [[GameLevel sharedGameLevel] decreaseCount_ofEnemies_toOpenBarrier];
                //NSLog(@"Barrier enemy hit.");     
            }
        }
    
    else
        {
            //Else, the ball velocity is too low,            
                //so the ball is hit.
            
            //NSLog(@"Handling Touch: Ball hit.");
                //[[GameLevel sharedGameLevel].player  ballAttacked:collisionNormal];
            //NSLog(@"Ball is hurt by enemy number %d",sprite.tag);
 
            resultingAction= [CCCallBlock actionWithBlock:
             ^{       
                    [[GameLevel sharedGameLevel].player  ballAttacked:collisionNormal];                      
             }];
            
        }
    
        id setBoolean= [CCCallBlock actionWithBlock:
                    ^{                    
                        isEnemyTouched=FALSE;
                        //NSLog(@"Handling Enemy Touch DONE."); 
                    }];       
       
       //run the the sequence of actions.
       [self runAction:[CCSequence actions:resultingAction, [CCDelayTime actionWithDuration:1.0f], setBoolean, nil]];
   
   }       
    
}


-(void)enemyKilled
{
    
        //Verify if the current enemy is a shooter.
        [[GameLevel sharedGameLevel] checkIfShooterHitWithId:sprite.tag];
    
        //1. Remove the item's b2Body
        entityType= BODY_TO_DESTROY;    
        
        //2. Stop the idle Animation, if the enemy is a Flyball.
        [sprite stopActionByTag:IDLE_ANIMATION_TAG];
       
        //3. Start the Death Animation. 
        //4. Once the Death Animation is finished, make the Collectible's sprite invisible.

        id spriteInvisible= [CCCallBlock actionWithBlock:
                             ^{                 
                                 sprite.visible=FALSE;  
                             }];
                
        [sprite runAction:[CCSequence actions:deathAnimation,
                                              [CCDelayTime actionWithDuration:0.2f],
                                              spriteInvisible, 
                                              nil]];
}

//This method plays the special death animation,
    //activated when the ball hits the enemy at a high enough speed.
-(void)enemyKilledFast
{  
    //Only running if an enemy touch is not being processed.
    if(!isEnemyTouched)
    {   
    //0.Play the Correct sound.
        [[GameSoundManager sharedManager] playSoundEffect:FAST_KILL_SOUND ];
  
        isEnemyTouched=TRUE;        
        //NSLog(@"Enemy number %d dying Fast.", sprite.tag);

    //1. Checking if killing this enemy triggers any action.
        
        if(self.triggerInfo==TRIGGER_ENEMY_GROUP_OPENS_BARRIER)
        {
            [[GameLevel sharedGameLevel] decreaseCount_ofEnemies_toOpenBarrier];       
            NSLog(@"Barrier enemy hit.");    
        }
        
    //2. Check if a shooter enemy was Killed
        [[GameLevel sharedGameLevel] checkIfShooterHitWithId:sprite.tag];
         
    //1. Remove the item's b2Body
    entityType= BODY_TO_DESTROY;    
        
    //2. Stop the Spinning Animation, if the enemy is a Flyball type.
    [sprite stopActionByTag:IDLE_ANIMATION_TAG];
    
    //3. start the Death Animation.
    //4. once the Death Animation is finished, make the Collectible's sprite invisible.
    
    id spriteInvisible= [CCCallBlock actionWithBlock:
                         ^{         
                             sprite.visible=FALSE;
                             isEnemyTouched=FALSE;  
                         }];
    
    
    [sprite runAction:[CCSequence actions:deathAnimation2,
                       [CCDelayTime actionWithDuration:0.2f],
                       spriteInvisible, 
                       nil]];
    
    }
    
}


//This method also initiates the bullet shooting procedure, in case the current enemy is a shooter:
-(void)startBulletAnimationsWithWait:(float)waitTime andShooterId:(int)shooterId
{
    //1.Set the enemy's Frame to opened Mouth, shoot a bullet. 
    //Hold Frame for 0.5 seconds.
        id openMouthAction= [CCCallBlock actionWithBlock:
                             ^{
                                 [sprite setDisplayFrame: 
                                  [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"shooter1.png"]];
                                //Shoot!
                                 [[GameLevel sharedGameLevel].myBulletManager shootNextForEnemy:shooterId];                        
                             }];
    
    //2.Set the enemy's Frame to a closed Mouth. 
    //Hold Frame for 2 seconds.
        id closeMouthAction= [CCCallBlock actionWithBlock:
                         ^{                        
                             [sprite setDisplayFrame: 
                              [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"shooter0.png"]];                           
                         }];
    
    //3. Setting up the complete animation.
        enemyAnimation= [[CCRepeatForever actionWithAction:[CCSequence actions:openMouthAction,
                                                       [CCDelayTime actionWithDuration:2], 
                                                       closeMouthAction,
                                                       [CCDelayTime actionWithDuration:waitTime], nil]] retain];
    
        [enemyAnimation setTag:IDLE_ANIMATION_TAG];
    
        //Run the shooting animation on the current enemy.
        [sprite runAction:enemyAnimation];
}



-(void) dealloc
{
    //deallocating our enemy animations.
	[enemyAnimation release];
    [deathAnimation release];
    [deathAnimation2 release];
    
	[super dealloc];
}


@end

