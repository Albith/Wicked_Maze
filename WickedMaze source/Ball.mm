//
//  Ball.m
//  Wicked Maze
//
//  Created by Albith Delgado on 12/17/11.
//  Copyright 2012 Albith Delgado. All rights reserved.
//
//  This class manipulates the Ball's b2body and sprite, 
//      based on the Ball's current health and collision state.
//


#import "Ball.h"
#import "GameConstants.h"
#import "GameLevel.h"
#include <math.h>


@implementation Ball

@synthesize spawnPoint;


//Constructors
-(id) initWithWorld:(b2World*)world andPosition:(CGPoint)ballPosition
{
	if ((self = [super init]))
	{
		[self createBallInWorld:world andPosition:ballPosition];
		
	}
	return self;
}

+(id) ballWithWorld:(b2World*)world andPosition:(CGPoint)ballPosition
{
	return [[[self alloc] initWithWorld:world andPosition:ballPosition] autorelease];
}


#pragma mark -create Ball in Box2d world.

-(void) createBallInWorld:(b2World*)world andPosition:(CGPoint)ballPosition
{
	
//1.Setting iVars. setting HP value.
    health=maxBallHP;
    spawnPoint=ballPosition;
    isBallBeingPushedBack=FALSE;

    
//2.Calling the superClass's entity setup.
    //This way we set up the sprite and physics body information.
    [super loadEntity:PLAYER_TAG atPosition:ballPosition 
            withWorld:world andOrientation:DEFAULT_ORIENTATION];
    
    
//3.Setting up the deathAnimation.
    //This animation consists of the ball cracking and breaking.
    NSMutableArray *deathFrames = [NSMutableArray array];
    
    for (int i =0 ; i < 5; i++) {
        
        CCSpriteFrame *frame;
        
        frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                 [NSString stringWithFormat:@"ballDeath%d.png", i]];
        
        [deathFrames addObject:frame];
        
    }     
    
    id tempDeathAnim = [CCAnimation animationWithFrames:deathFrames delay:0.15f] ;   
    deathAnimation = [[CCAnimate actionWithAnimation:tempDeathAnim restoreOriginalFrame:NO] retain];
    
}


//This method handles collisions from all enemies, spikes and bullets in the game,
    //by reading the normals of the object collided with,
    //as well as the ball's velocity at the time of the collision.
-(void)ballAttacked:(b2Vec2)collisionNormal
{
    
    //0. Only running the method if it's not running already.
        //(The ball has an invulnerability period once it has been hurt)
    if(!isBallBeingPushedBack)
    {     
        //1. Health is deducted.  
        isBallBeingPushedBack=TRUE;        
        health--;
        
        if(health==0)
        {
            //The ball cracks, and a sound play. 
           
            [self runBallDeath];  
            [[GameSoundManager sharedManager] playSoundEffect:BALL_BREAK_SOUND]; 
        }
        else
        {  
            //The ball has been hurt, health is deducted.

            [[GameSoundManager sharedManager] playSoundEffect:HURT_SOUND];
                        
            //2. The ball's sprite is updated. 
            //Note: this should be titled ballSprite_changed, for specificity.
            [self ballChanged];
            
            //3.pushing the ball.
            b2Vec2 playerVelocity= body->GetLinearVelocity();
            
            //This force vector will contain the pushback force.
            b2Vec2 force;
            //NSLog(@"Player Velocity X %f, Y %f", playerVelocity.x, playerVelocity.y);
            
            
            //3a: Let's check the Collision Normal value, and the Gravity value.
            
            //Collision case 1: The ball has been attacked from above.
                //Modifying the ball's force vector's Y component.
            if(collisionNormal.y<-0.5f)
            {  
                //We take into account the ball's velocity, and act accordingly.

                if(playerVelocity.y < minMaxVelocity)
                {
                    //NSLog(@"Y: Ceiling collision. Velocity.Y is low, constant used.");
                    
                    force.y=9*collisionNormal.y;       
                }
                else
                {   
                    //NSLog(@"Y: Ceiling collision. Velocity.Y is used.");   
                    
                    force.y= 1.8f*playerVelocity.y*collisionNormal.y;         
                }  
                
            }    
            //Collision case 2: The ball has been attacked from below.
            else if(collisionNormal.y > 0.5f)
            {
                
                if(playerVelocity.y > -minMaxVelocity)
                {
                    
                    //NSLog(@"Y: Floor collision. Velocity.Y is low, constant used.");
                    
                    force.y=9*collisionNormal.y;      
                    
                }
                else
                { 
                    //NSLog(@"Y: Floor collision. Velocity.Y is used.");
                       
                    force.y=2.4f*playerVelocity.y*collisionNormal.y;
                }
                
                
            }        
            
            //Collision case 3: The ball has been attacked from the right side.
                //Modifying the ball's force vector's X component.
            if(collisionNormal.x<-0.5f)
            {  
                
                if(playerVelocity.x < minMaxVelocity)
                {    
                    //NSLog(@"X: Right Wall collision. Velocity.X is low, constant used.");
                        
                    force.x=9*collisionNormal.x;
                }
                else
                {    
                    //NSLog(@"X: Right Wall collision. Velocity.X is used.");   
                    
                    force.x= 1.5f*playerVelocity.x*collisionNormal.x;
                }
                
            }    
            
            //Collision case 4: The ball has been attacked from the left side.
            else if (collisionNormal.x > 0.5f)
            {
                
                if(playerVelocity.x > -minMaxVelocity)
                {   
                    //NSLog(@"X: Left Wall collision. Velocity.X is low, constant used.");   
                    
                    force.x=ballAttackedForce*collisionNormal.x; 
                }
                else
                {
                    //NSLog(@"X: Left Wall collision. Velocity.Y is used.");   
                    
                    force.x= 1.5f*playerVelocity.x*collisionNormal.x;
                }        
                
            }             
            
    //3B: Capping the force values according to our range.
            
            //First, stopping a floating point bug.
                 //Rounding out a floating point force.x number.
            force.x= roundf(force.x);
            
            //NSLog(@"Ball.mm: Force.x before clamping is %f", force.x);


            //Now clamping down the force vector.
            if(force.x > 0)
            {
                //NSLog(@"force.x >0");
                
                force.x= fminf(force.x, BULLET_minMaxForceAppliedToBall);
            }
            else if(force.x < 0)
            { 
                //NSLog(@"force.x <0");
                
                force.x= fmaxf(force.x , -BULLET_minMaxForceAppliedToBall);
            }
            
            if(force.y > 0)
            { 
                //NSLog(@"force.y >0");             
                
                force.y= fminf(force.y, BULLET_minMaxForceAppliedToBall);
                
            }
            else if(force.y < 0)
            { 
                
                //NSLog(@"force.y <0");
                         
                force.y= fmaxf(force.y , -BULLET_minMaxForceAppliedToBall);
                
            }
            
            //NSLog(@"Ball.mm, ballAttackedWithBULLET(): Pushback Force is X %f, Y %f", force.x, force.y);        
            

        //3C. Finally, pushing the ball.
        body->ApplyLinearImpulse(force, body->GetWorldCenter());
            
            
            //4. In addition: stopping the linear Impulse after 0.3f seconds.
            [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.4f], 
                             
                             [CCCallBlock actionWithBlock:
                              ^{                                    
                                  body->SetLinearVelocity(b2Vec2(0,0));
                                  body->SetAngularVelocity(0.1f);                         
                              }]  , 
                             
                             nil]];
            
            //5. Make the ball flash a yellow color.
                    id spriteYellowed= [CCCallBlock actionWithBlock:
                                        ^{
                                            
                                            sprite.color= ccYELLOW;
                                            
                                            //NSLog(@"Yellowing.");            
                                        }];
                    
                    
                    
                    
                    id spriteInDefault= [CCCallBlock actionWithBlock:
                                        ^{
                                            sprite.color= ccWHITE;  
                                            //NSLog(@"To Default.");         
                                        }];
                    
                    
                    id pushBackActionDone= [CCCallBlock actionWithBlock:
                                            ^{ 
                                                isBallBeingPushedBack=FALSE;
                                                //NSLog(@"Ball.mm: Ball Hurt sequence done.");
                                            }];
            
            id flashYellowAction= [CCRepeat actionWithAction: 
                                   
                                   [CCSequence actions: spriteYellowed, 
                                    [CCDelayTime actionWithDuration:0.1f], 
                                    spriteInDefault,
                                    [CCDelayTime actionWithDuration:0.1f],
                                    nil]
                                   
                                    times:7] ;  //This flashing sequence will occur 7 times.
            
            
            //Running the complete sequence.
            [self runAction:[CCSequence actions:flashYellowAction, 
                                                [CCDelayTime actionWithDuration:0.3f],
                                                 pushBackActionDone, nil] ];
            
        }
        
    } 
    else 
    {}//NSLog(@"Ball.mm , ballAttackedWithBullet() already running.");
    
    
}

//The ball's health attribute increases and its sprite is updated.
-(void)ballHealead
{
    health++;
    
    if(health>maxBallHP)
        health=maxBallHP;
    
    else
    {    
        //Performing the sprite change.
        [self ballChanged];
    
        //For now, go from gray to normal color.
    
            id setGraySprite= [CCCallBlock actionWithBlock:
                            ^{
                            
                                [sprite setColor:ccGRAY];
                            
                            }];
        
            id fadeGrayToNormal= [CCTintTo actionWithDuration:0.18f red:255 green:255 blue:255];
    
        [sprite runAction:[CCSequence actions:setGraySprite, fadeGrayToNormal, nil]];
    
    }
    
}

//Performing the sprite change.
-(void)ballChanged
{
    
    //NSLog(@"Ball hit. Health is now %d", health);
    
    //Every health parameter value is connected to a sprite image:
        //3 is full health, 2 is scratched up.
        //1 is near death, 0 goes straight to the death Animation.
    
    NSString* ballFrameName;
    
    switch (health) {
        case 3:
            ballFrameName= @"playerBall.png";
            break;
        
        case 2:
            ballFrameName= @"playerBallHit1.png";
            break;    
            
        case 1:
            ballFrameName= @"playerBallHit2.png";
            break;
        
        default:
            NSLog(@"Ball.mm, ballChanged(): invalid health number.");
            ballFrameName= @"playerBall.png";
            break;
    }
    
    [sprite setDisplayFrame: 
     [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:ballFrameName]];    

}

-(void)runBallDeath
{
    
    //NSLog(@"The player dies.");
        [self stopAllActions];
    
    //0.unscheduling the GameLevel's tick function;        
        [[GameLevel sharedGameLevel] pauseGame];

    //1. Set what to do after animation is done.
        //move the b2Body to the current level's spawn location.
        //reset the sprite's frame.
        //reset health.
        //setBody to be Active once again.
    
        id resetBody= [CCCallBlock actionWithBlock:
                       ^{
                            
                           //NSLog(@"resetting ball Body.");
                           //First, move the b2Body to the original spawnPoint.
                              body->SetTransform(b2Vec2( spawnPoint.x/PTM_RATIO, spawnPoint.y/PTM_RATIO), 0);
                           
                          
                           //reset the b2Body's velocity. 
                                body->SetLinearVelocity(b2Vec2(0,0));
                                body->SetAngularVelocity(0);
                                
                           //reset the sprite's frame.
                                [sprite setDisplayFrame: 
                                [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"playerBall.png"]]; 
                           
                           //reset health.
                                health=maxBallHP;
                                isBallBeingPushedBack=FALSE;    
                           
                           //scroll the camera to the Ball's spawn point.
                           [[GameLevel sharedGameLevel] scrollCameraToBallSpawnPoint];         
                       }];        
    
    //2. Run the animation.
        [sprite runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.4f], 
                                              deathAnimation, 
                                              [CCDelayTime actionWithDuration:0.4f],
                                              resetBody,
                                              nil]];
    
}



-(void) dealloc
{

//Deallocating the deathAnimation that was retained in the init method.    
    [deathAnimation release];
	[super dealloc];

}


@end
