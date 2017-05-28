//
//  Barrier.m
//  Wicked Maze
//
//  Created by Albith Delgado on 3/26/12.
//  Copyright 2012 __Albith Delgado__. All rights reserved.
//

#import "Barrier.h"
#import "GameConstants.h"

@implementation Barrier

@synthesize barrierType;

//Constructors and initializers
-(id)initWithWorld:(b2World*)world 
       andPosition:(CGPoint)barrierPosition 
             andId:(int)barrierId 
           andType:(int)myBarrierType
    andOrientation:(int)barrierOrientation

{
	if ((self = [super init]))
	{
		[self createBarrierWithWorld:world andPosition:barrierPosition 
                               andId:barrierId andType:myBarrierType
                      andOrientation:barrierOrientation];
		
		
	}
	return self;
}

+(id)  barrierWithWorld:(b2World*)world 
          andPosition:(CGPoint)barrierPosition 
                andId:(int)barrierId 
              andType:(int)myBarrierType
         andOrientation:(int)barrierOrientation

{
	return [[[self alloc] initWithWorld:world andPosition:barrierPosition 
                                  andId:barrierId andType:myBarrierType
                         andOrientation:barrierOrientation] autorelease];
}


#pragma mark -create Barrier in Box2d world.

-(void) createBarrierWithWorld:(b2World*)world 
                 andPosition:(CGPoint)barrierPosition 
                       andId:(int)barrierId 
                     andType:(int)myBarrierType
              andOrientation:(int)barrierOrientation

{
    
    //1.Calling the superClass gameEntity function: Create a Barrier.
    
    [super loadEntity:myBarrierType atPosition:barrierPosition 
            withWorld:world andOrientation:barrierOrientation];
    
    //2.Updating the sprite's tag and flags.
        barrierType= myBarrierType;    
        isBarrierTouched=FALSE;
    
    
        //if the the barrierType is breakable, assign the entityType BREAKABLE_BARRIERS_TAG.
            if( (myBarrierType == WOOD_BARRIER_TYPE) ||  (myBarrierType == DUMMY_TILE_BARRIER_TYPE) || (myBarrierType == BROKEN_TILE_BARRIER_TYPE) )
            {
                sprite.tag= barrierId;
                entityType=BREAKABLE_BARRIERS_TAG;
            }
            else        // else, the Barrier requires getting a Key.  (Other triggers come later)
            {    
                sprite.tag= barrierId;
                entityType= HARD_BARRIERS_TAG;
            }
    

    //If the barrier is breakable, set up the barrier Break Animation.
    switch (myBarrierType) {
        case WOOD_BARRIER_TYPE:
        {
            
            NSMutableArray *shatterFrames = [NSMutableArray array];
            
            for (int i =2 ; i < 6; i++) {
                
                CCSpriteFrame *frame;
                
                frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                         [NSString stringWithFormat:@"woodBarrier%d.png", i]];
                
                [shatterFrames addObject:frame];
                
            }     
            
            id tempShatterAnim = [CCAnimation animationWithFrames:shatterFrames delay:0.15f] ;     
            barrierShatterAnim = [  [CCAnimate actionWithAnimation:tempShatterAnim restoreOriginalFrame:NO] retain];
        }
            break;
        
        case DUMMY_TILE_BARRIER_TYPE:
        {
            
            NSMutableArray *shatterFrames = [NSMutableArray array];  
            
            for (int i =1 ; i < 5; i++) {
                
                CCSpriteFrame *frame;
                
                frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                         [NSString stringWithFormat:@"brokenTile%d.png", i]];
                
                [shatterFrames addObject:frame];
                
            }     
            
            id tempShatterAnim = [CCAnimation animationWithFrames:shatterFrames delay:0.11f] ;   
            
            barrierShatterAnim = [  [CCAnimate actionWithAnimation:tempShatterAnim restoreOriginalFrame:NO] retain];
            //NSLog(@"BARRIER: Making barrier Shatter animation.");        
        }    
            
            break;
            
        case BROKEN_TILE_BARRIER_TYPE:
        {
            NSMutableArray *shatterFrames = [NSMutableArray array];   
            
            for (int i =1 ; i < 5; i++) {
                
                CCSpriteFrame *frame;
                
                frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                         [NSString stringWithFormat:@"brokenTile%d.png", i]];
                
                [shatterFrames addObject:frame];
                
            }     
            
            id tempShatterAnim = [CCAnimation animationWithFrames:shatterFrames delay:0.11f] ;   
            
            barrierShatterAnim = [  [CCAnimate actionWithAnimation:tempShatterAnim restoreOriginalFrame:NO] retain];
            //NSLog(@"BARRIER: Making barrier Shatter animation.");
            
        }    
            break;
            
        default:
            //do nothing: this is a hard Barrier and it won't break! (like unlockable barriers)
            break;
    }
  
    //and we're done!
    
}


//This method is executed for Breakable Barriers.
-(void)barrierBroken
{
        //The barrier is destroyed, an animation is shown.
        //And then the barrier is removed 
            //(the sprite is hidden and the physics body is removed).
    
    if(!isBarrierTouched)
    {
        isBarrierTouched=TRUE; 
        NSLog(@"Barrier has been Broken.");

        
        [[GameSoundManager sharedManager] playSoundEffect:BARRIER_BREAKING_SOUND ];
        entityType= BODY_TO_DESTROY;    

        
        id spriteInvisible= [CCCallBlock actionWithBlock:
                             ^{
                                 
                                 sprite.visible=FALSE;
                                 isBarrierTouched=FALSE;
                             
                             }];
        
        [sprite runAction:[CCSequence actions:barrierShatterAnim, 
                           spriteInvisible, 
                           nil]];
      
    }    
  
}


//Entity removal methods are executed by the physics simulation in its physics loop.
    //We send a message asking for it to be removed.
-(void)barrierRemoved
{
    //Key-opened Barriers will use this method.
    
    //The barrier's sprite goes invisible and its b2Body is removed.
    //b2Body will be destroyed.  Sprite Visibility set to False.
    
    entityType= BODY_TO_DESTROY;    
    sprite.visible= FALSE;    
    
}


-(void) dealloc
{
    if(entityType== BREAKABLE_BARRIERS_TAG)
        [barrierShatterAnim release];
    
    
	[super dealloc];
    
}



@end
