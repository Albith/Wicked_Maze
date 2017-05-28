//
//  MyContactListener.m
//  Wicked Maze
//
//  Created by Ray Wenderlich on 2/18/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import "MyContactListener.h"
#import "GameLevel.h"

#import "gameEntity.h"
#import "GameConstants.h"

//The contact listener's constructors and destructors.
MyContactListener::MyContactListener(){
    isMovingSpikeTouched=FALSE;
}
MyContactListener::~MyContactListener() {
}

//--Describing the listener's Collision handling methods.

//--Begin Contact is the method that gets called back first, during a collision.
    //We will handle collisions for sensor elements here,
        //objects that are managed simply. (coins, keys and goals are sensors, for instance)
    //Note:BeginContact() and EndContact() are called only once while two objects collide.
void MyContactListener::BeginContact(b2Contact* contact) {

    //NSLog(@"Contact begins.");   
    BOOL isEntityA_aSensor=TRUE;
    isContactSoundPlaying=FALSE;
    
//------0. Fetching the the gameEntity information for the colliding elements.  
    gameEntity* entityA = (gameEntity*)contact->GetFixtureA()->GetBody()->GetUserData();
    gameEntity* entityB = (gameEntity*)contact->GetFixtureB()->GetBody()->GetUserData(); 
    
    
//------1. Checking if either of the two entities are Bullets.

    if(entityA.entityType == ENEMY_BULLETS_TAG)
    {
        //The Bullet has hit something.
            //a.Did the Bullet hit the Player?
        
        if(entityB.entityType == PLAYER_TAG)
        {
            //aa.Player gets hit          
                NSLog(@"Hit by Bullet.");

                //Fetching the bullet's normals. 
                b2WorldManifold worldManifold;
                contact->GetWorldManifold(&worldManifold);
                b2Vec2 contactNormals= worldManifold.normal;

                //Update the player's state according to the normals fetched.
                [[GameLevel sharedGameLevel].player  ballAttacked:contactNormals];
            
            //ab.the current bullet is reset.
            [[GameLevel sharedGameLevel].myBulletManager resetBulletWithId:entityA.sprite.tag ];  
        }
            
        //Or did the Bullet hit a Wall?
        else
        {
            //If entityB is part of the game level, 
                //Check for its user data.

            b2Fixture *fixtureB= contact->GetFixtureB();
            
            //Fetching user data. F stands for 'Floor'
            if([(NSString*)fixtureB->GetUserData() isEqual:@"F"] )            

            {
  
                //aa.Wall gets hit
                //NSLog(@"Bullet touches Wall");
                
                //ab.The bullet is reset, no damage done to the wall.
                [[GameLevel sharedGameLevel].myBulletManager resetBulletWithId:entityA.sprite.tag ];                
                
            }  
            
        }
        
    }
    
    
//----------Performing the exact same check, but with entityB as the bullet.
    else if(entityB.entityType == ENEMY_BULLETS_TAG)
    {
        //The Bullet has hit something.   
        //a.Did the Bullet hit the Player?
        
        if(entityA.entityType == PLAYER_TAG)
        {
            
            //aa.Player gets hit
            //NSLog(@"Bullet touches Player.");            
                NSLog(@"Hit by Bullet.");
            
                b2WorldManifold worldManifold;
                contact->GetWorldManifold(&worldManifold);
                b2Vec2 contactNormals= worldManifold.normal;
            
                [[GameLevel sharedGameLevel].player  ballAttacked:contactNormals];
                    
            //ab.The bullet is reset.
            [[GameLevel sharedGameLevel].myBulletManager resetBulletWithId:entityB.sprite.tag ];                

        }
         
        //Or did the Bullet hit a Wall?
        else
        {
            b2Fixture *fixtureA= contact->GetFixtureA();
            
            if   ([(NSString*)fixtureA->GetUserData() isEqual:@"F"] )            
            {
                //aa.a wall has been hit.
                //NSLog(@"Bullet touches Wall");

                //ab.the bullet is reset.
                [[GameLevel sharedGameLevel].myBulletManager resetBulletWithId:entityB.sprite.tag ];
            }
            
            
        }
    
    }//End of Bullet element collision check.

  
//2. Now Checking for Key, Goal or Collectible Contacts.  for both fixtures.
else
{    
    switch (entityA.entityType) {
        case KEY_TAG:
            [[GameLevel sharedGameLevel] openBarrierOfType:KEY_BARRIER_TYPE];
            [[GameLevel sharedGameLevel] keyCollected];
            break;
        
        case GOAL_TAG:
            //the Level is Finished 
            [[GameSoundManager sharedManager] playSoundEffect:GOAL_SOUND ];
            [[GameLevel sharedGameLevel] levelCleared];
            break;
         
        case COINS_TAG:
            [[GameLevel sharedGameLevel] ItemCollectedWithId: entityA.sprite.tag];
            [[GameSoundManager sharedManager] playSoundEffect:COIN_SOUND ];
            break;
        
        
        default:
            isEntityA_aSensor=FALSE;
            break;
    }

    //if there's no collision with entityA, we check entity B.
    if(!isEntityA_aSensor)   
        switch (entityB.entityType) {
            case KEY_TAG:
                [[GameLevel sharedGameLevel] openBarrierOfType:KEY_BARRIER_TYPE];
                [[GameLevel sharedGameLevel] keyCollected];
                break;
                
            case GOAL_TAG:
                //the Level is Finished 
                [[GameSoundManager sharedManager] playSoundEffect:GOAL_SOUND ];
                [[GameLevel sharedGameLevel] levelCleared];
                break;
                
            case COINS_TAG:
                [[GameLevel sharedGameLevel] ItemCollectedWithId: entityB.sprite.tag];
                [[GameSoundManager sharedManager] playSoundEffect:COIN_SOUND ];
                break;
                      
            default:
                //NSLog(@"No collision with Bullets, Keys, Goals or Collectibles.");
                break;
        }
    
    
}
//------------------End of Key, Coins and Goal collision check. 
         
}

void MyContactListener::EndContact(b2Contact* contact) {
    //NSLog(@"Ending contact.");
    
}



//In the PreSolve method we will verify collisions with enemies.
    //We will also play sound effects.
    //Note: Many collisions do not require a special function call to manage it.
        //Rather, we usually just play a particular sound when touching a particular object.

//PreSolve() and PostSolve() are called multiple times within a collision, similar to
    //Unity's 'OnCollisionStay().

void MyContactListener::PreSolve(b2Contact* contact, const b2Manifold* oldManifold) {

 //0. Getting Fixture Data.
        NSString* fixtureA_Data= (NSString*)contact->GetFixtureA()->GetUserData();
        NSString* fixtureB_Data= (NSString*)contact->GetFixtureB()->GetUserData();
    
 //1. Checking The fixtures for contact with the FLOOR and SPIKES. @"F" is Floor and @"S" is Spikes.
        //Playing a sound whenever there is a collision.
        if   (  [fixtureA_Data isEqual:@"F"] || 
               [fixtureB_Data isEqual:@"F"] )           
        {
           
            //Playing a 'Floor' Sound.
            if  (!isContactSoundPlaying)
            {
                
                //NSLog(@"Contact With Barrier or Something else. Sprite A Tag is %d, Sprite B Tag is %d", spriteA.tag, spriteB.tag);
                [[GameSoundManager sharedManager] playSoundEffect:FLOOR_SOUND ];
                isContactSoundPlaying=TRUE;
                
            }
        
        }
    
        //Playing a 'Spike' sound effect.
        else if   (  [fixtureA_Data isEqual:@"S"] || 
                [fixtureB_Data isEqual:@"S"] )           
        {
            isMovingSpikeTouched=TRUE;
            
                //NSLog(@"Contact with spikes. Cue Spike Sound. isMovingSpikeTouched is TRUE.");
                b2WorldManifold worldManifold;
                contact->GetWorldManifold(&worldManifold);
                b2Vec2 contactNormals= worldManifold.normal;
            
            isContactSoundPlaying=TRUE;   
            [[GameLevel sharedGameLevel].player  ballAttacked:contactNormals];
        }
    
//2. Checking for contact with gameEntities.  
        else
        {   
        gameEntity* entityA = (gameEntity*)contact->GetFixtureA()->GetBody()->GetUserData();
        gameEntity* entityB = (gameEntity*)contact->GetFixtureB()->GetBody()->GetUserData(); 


        // Entity A Collision Check. 
            //This check will be performed exactly the same for Entity B.  
        if(entityB.entityType== PLAYER_TAG)  
        {    
            //Now checking for Collision with:
                //Static Enemies, Moving Enemies, Rotating Platforms, Moving Platforms, Barriers.
            
            switch (entityA.entityType) {   
                case ENEMIES_TAG:
                {      
                    //----------This is a static Enemy. Check is the Ball is Hit,
                        //or if the Enemy is  Killed.                  
                    //NSLog(@"Touched enemy number %d.", entityA.sprite.tag);
                               
                        b2WorldManifold worldManifold;
                        contact->GetWorldManifold(&worldManifold);
                        b2Vec2 contactNormals= worldManifold.normal; 
                    
                    //Checking for a Fast Kill 
                        //(this happens if the ball speed is high when colliding with the enemy.)
                    //We assume entityB is the ball.
                        
                        b2Vec2 ballVelocity= entityB.body->GetLinearVelocity();
                        if( (fabsf(ballVelocity.x) > minMaxFastKillVelocity) || 
                           (fabsf(ballVelocity.y) > minMaxFastKillVelocity) )
                        {
                        
                        //NSLog(@"Enemy Fast Kill.");
                            contact->SetEnabled(false);        
                        
                        //Handling enemy Fast Kill.
                            [[GameLevel sharedGameLevel] killEnemyFastWithId:entityA.sprite.tag];
                             
                        }    
                    
                        else
                        {      
                        //Verify the result of the enemy collision (whether health loss or enemy kill) in this method.
                        //NSLog(@"Contact with enemy number %d", enemyIndex);
                            [[GameLevel sharedGameLevel] enemyTouchedWithId:entityA.sprite.tag
                                                             andNormals:contactNormals  
                             ];
                        }
                    
                    }
                    
                    break;
                
                //For Moving Enemies: handle collisions the same as with Static Enemies.    


    //--------PLATFORMS: Moving and Rotating and Static.
                case STATIC_PLATFORMS_TAG:
                {
                    //We're going to play the hardBarrierHit sound.            
                    //Playing a Sound
                    if  ( (!isContactSoundPlaying) && (!isMovingSpikeTouched) )
                    {
                 
                        [[GameSoundManager sharedManager] playSoundEffect:BOUNCY_PLATFORM_SOUND ];
                        isContactSoundPlaying=TRUE;
                        
                    }
                    else
                    {
                        isMovingSpikeTouched=FALSE; 
                    }
                    
                }
                    break;     
                    
                    
      //---Barriers.
                case HARD_BARRIERS_TAG:
                {
                   //We're going to play the hardBarrierHit sound. 
                    
                    //playing a Sound
                    if  ( (!isContactSoundPlaying) && (!isMovingSpikeTouched) )
                    {
                        
                        [[GameSoundManager sharedManager] playSoundEffect:HARD_BARRIER_SOUND ];  
                        isContactSoundPlaying=TRUE;
                        
                    }
                    else
                    {   
                        isMovingSpikeTouched=FALSE;   
                    }
                    
                }
                    break;
                    
                    
                case BREAKABLE_BARRIERS_TAG:
                { 
                    
                    //Handle Barriers.
                    //Barriers must be hit with enough velocity to kill an enemy.
                    
                    b2Vec2 ballVelocity= entityB.body->GetLinearVelocity();
                    
                    //If the ball hits the breakable barrier with enough speed,
                        //the barrier is removed.
                    if( (fabsf(ballVelocity.x) > minBarrierBreakVelocity) || 
                       (fabsf(ballVelocity.y) > minBarrierBreakVelocity) )
                    {
                        //We use the Barrier's Sprite Tag to open the correct Barrier.
                        [[GameLevel sharedGameLevel] openBarrierWithId:entityA.sprite.tag];  
                    }
                    
                    //Else, the barrier is not broken.
                        //Play the unbroken Barrier Sound. 
                    else if  ( (!isContactSoundPlaying) && (!isMovingSpikeTouched) )
                    {
                        [[GameSoundManager sharedManager] playSoundEffect:BREAKABLE_BARRIER_SOUND ];
                        isContactSoundPlaying=TRUE;   
                    }
                    else
                    {
                        isMovingSpikeTouched=FALSE;
                    }
                    
                }
                    
            //The default case: play the Default Floor Sound. No Special Collision Needed.    
            default:
                {
                    
                    //STANDARD COLLISION.
                    //Playing a Sound
                    if  ( (!isContactSoundPlaying) && (!isMovingSpikeTouched) )
                    {
                        [[GameSoundManager sharedManager] playSoundEffect:FLOOR_SOUND ];
                        isContactSoundPlaying=TRUE;
                    }
                    
                    else
                    {
                        //NSLog(@"Moving Platform part touched. isMovingSpikeTouched is FALSE");   
                        isMovingSpikeTouched=FALSE;              
                    }
                            
                }
                    
                    break;
            } 
         
            
            
        }   //---End of Entity B as Player collision check.
            
            
            //else if (entityA.entityType== PLAYER_TAG)
                //Now checking Entity A as Player collision check.
           
            else
            { 
                //Now checking for Collision with:
                //Static Enemies, Moving Enemies, Rotating Platforms, Moving Platforms, Barriers.        
                switch (entityB.entityType) {   
                    case ENEMIES_TAG:
                    { 
                        //----------This is a static Enemy. Check if the Ball is Hit,
                            //or if the Enemy has been killed.               
                        //NSLog(@"Touched enemy number %d.", entityA.sprite.tag);
                        
                        b2WorldManifold worldManifold;
                        contact->GetWorldManifold(&worldManifold);
                        b2Vec2 contactNormals= worldManifold.normal;
                        
                        
                        //Checking for Fast Kill.
                        //We assume entityB is the ball.
                        b2Vec2 ballVelocity= entityA.body->GetLinearVelocity();
                        
                        if( (fabsf(ballVelocity.x) > minMaxFastKillVelocity) || 
                           (fabsf(ballVelocity.y) > minMaxFastKillVelocity) )
                        {
                            
                            //NSLog(@"Enemy Fast Kill.");
                            contact->SetEnabled(false);        
                            
                            //Handling enemy Fast Kill.
                            [[GameLevel sharedGameLevel] killEnemyFastWithId:entityB.sprite.tag];
                            
                        }    
                        
                        else
                        {    
                            //Verify the result of the enemy collision (whether health loss or enemy kill) in this method.
                            //NSLog(@"Contact with enemy number %d", enemyIndex);
                            [[GameLevel sharedGameLevel] enemyTouchedWithId:entityB.sprite.tag
                                                                 andNormals:contactNormals  
                             ];
                        }
                      
                    }
                        
                        break;
                
                        //For Moving Enemies: handle collisions the same as with Static Enemies.    
                            //case MOVING_ENEMIES_TAG:    
                                //    break;
                     
            //---------Checking Platform collisions and playing sounds.  
                    case STATIC_PLATFORMS_TAG:
                    {
                        //We're going to play the hardBarrierHit sound. 
                        //playing a Sound
                        if  ( (!isContactSoundPlaying) && (!isMovingSpikeTouched) )
                        {
                            [[GameSoundManager sharedManager] playSoundEffect:BOUNCY_PLATFORM_SOUND ];     
                            isContactSoundPlaying=TRUE;
                        }
                        else
                        {
                            isMovingSpikeTouched=FALSE;
                        }
                        
                    }
                        break;     
                        
            //---------Checking Barrier Collisions and playing sounds.
                    
                    case HARD_BARRIERS_TAG:
                    {
                        //We're going to play the hardBarrierHit sound. 
                        
                        //playing a Sound
                        if  ( (!isContactSoundPlaying) && (!isMovingSpikeTouched) )
                        {
                            [[GameSoundManager sharedManager] playSoundEffect:HARD_BARRIER_SOUND ];
                            isContactSoundPlaying=TRUE;
                            
                        }
                        else
                        {  
                            isMovingSpikeTouched=FALSE;
                            
                        }
                         
                    }
                        break;
                          
                    case BREAKABLE_BARRIERS_TAG:
                    { 
                        
                        //Handle Barriers collisions.
                        
                        //Barriers must be hit with enough velocity to kill an enemy.
                            b2Vec2 ballVelocity= entityA.body->GetLinearVelocity();
                        
                        if( (fabsf(ballVelocity.x) > minBarrierBreakVelocity) || 
                           (fabsf(ballVelocity.y) > minBarrierBreakVelocity) )
                        {
                            //We use the Barrier's Sprite Tag to open the correct Barrier.
                            [[GameLevel sharedGameLevel] openBarrierWithId:entityA.sprite.tag];                            
                        }
                        

                    //Else, the barrier is not broken.
                        //Play the unbroken Barrier Sound.
                        else if  ( (!isContactSoundPlaying) && (!isMovingSpikeTouched) )
                        {
                            [[GameSoundManager sharedManager] playSoundEffect:BREAKABLE_BARRIER_SOUND ];
                            isContactSoundPlaying=TRUE;                            
                        }
                        else
                        {
                            isMovingSpikeTouched=FALSE;  
                        }
                                                
                    }
                        
                    //The default case: play the Default Floor Sound. No Special Collision Needed.    
                    default:
                    {
                        
                        //STANDARD COLLISION.
                        //Playing a Sound
                        if  ( (!isContactSoundPlaying) && (!isMovingSpikeTouched) )
                        {
                            //NSLog(@"Moving Platform part touched. Playing Floor Sound.");
                            [[GameSoundManager sharedManager] playSoundEffect:FLOOR_SOUND ];
                            isContactSoundPlaying=TRUE;  
                        }
                        else
                        {   
                            //NSLog(@"Moving Platform part touched. isMovingSpikeTouched is FALSE");
                            isMovingSpikeTouched=FALSE;             
                        }
                          
                    }    
                        break;
                }
                
            } //---End of Entity A as Player collision check.
            
            
            
        }  //End of the gameEntities' collision check. 
                
}//--End of the Collision Handler's PreSolve() function.    


void MyContactListener::PostSolve(b2Contact* contact, const b2ContactImpulse* impulse) {
    //Not doing anything in PostSolve().
}



