//
//  Collectible.mm
//  Wicked Maze
//
//  Created by Albith Delgado on 1/21/12.
//  Copyright 2012 __Albith Delgado__. All rights reserved.
//

#import "Collectible.h"
#import "GameConstants.h"

//Constants to specify the two animations coins will execute.
#define SPIN_ANIMATION_TAG 33
#define SPARKLE_ANIMATION_TAG 34

@implementation Collectible

//Constructors.
-(id)initWithWorld:(b2World*)world andPosition:(CGPoint)goalPosition andId:(int)collectibleId 
{
	if ((self = [super init]))
	{
		[self createCollectibleInWorld:world andPosition:goalPosition andId:collectibleId];
			
	}
	return self;
}

+(id)  collectibleWithWorld:(b2World*)world andPosition:(CGPoint)goalPosition andId:(int)collectibleId
{
	return [[[self alloc] initWithWorld:world andPosition:goalPosition andId:collectibleId] autorelease];
}


#pragma mark -create Collectible in Box2d world.

-(void) createCollectibleInWorld:(b2World*)world andPosition:(CGPoint)goalPosition andId:(int)collectibleId
{
    //1.Calling the superClass gameEntity function:  
    [super loadEntity:COINS_TAG atPosition:goalPosition 
            withWorld:world  andOrientation:DEFAULT_ORIENTATION];
    
    //updating the sprite's tag and entityType.
        sprite.tag= collectibleId;
        entityType= COINS_TAG;
    
    //Now creating the collectible's two animations.

    //2. Creating the spinning animation.
        NSMutableArray *tempFrames = [NSMutableArray array];
    
        for (int i =0 ; i < 8; i++) {
        
            CCSpriteFrame *frame;
        
            frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                     [NSString stringWithFormat:@"coin%d.png", i]];
        
            [tempFrames addObject:frame];
        
        }     
    
        id tempSpinAnimation = [CCAnimation animationWithFrames:tempFrames delay:0.1f] ;   
    
        spinAnimation = [[CCRepeatForever actionWithAction:
                        [CCAnimate actionWithAnimation:tempSpinAnimation restoreOriginalFrame:NO]] retain];
    
        [spinAnimation setTag:SPIN_ANIMATION_TAG];
    
    
    //3. Creating the "item collected" animation.
        [tempFrames removeAllObjects]; 
    
        for (int i =0 ; i < 3; i++) {
        
            CCSpriteFrame *frame;
        
            frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                     [NSString stringWithFormat:@"sparkles%d.png", i]];
        
            [tempFrames addObject:frame];
        }     
    
        id tempSparkleAnimation = [CCAnimation animationWithFrames:tempFrames delay:0.15f] ;   
    
        sparkleAnimation = [[CCAnimate actionWithAnimation:tempSparkleAnimation restoreOriginalFrame:NO] retain];
     
        [sparkleAnimation setTag:SPARKLE_ANIMATION_TAG];
    
    
    //4. Running the spinning animation.
        [sprite runAction:spinAnimation];
      
}


#pragma mark -item Collected

-(void)itemCollected
{
    
    //NSLog(@"Collectible.mm: Item is Collected.");
    
   //1. remove the item's b2Body.  It will stop existing in the physics simulation.
    entityType= BODY_TO_DESTROY;    
    
    //2. stop the Spinning Animation.
    [sprite stopActionByTag:SPIN_ANIMATION_TAG];
    
    //3. start the Sparkle Animation.
    //4. once the Sparkle Animation is finished, make the Collectible's sprite invisible.
    
    id spriteInvisible= [CCCallBlock actionWithBlock:
                         ^{
                             
                             sprite.visible=FALSE;
                             
                         }];
    
    
    [sprite runAction:[CCSequence actions:sparkleAnimation, 
                                          spriteInvisible, 
                                          nil]];

    //Health is added to the Ball after collecting a coin.
        //This change is called in the collision handler.    
}


-(void) dealloc
{
    //Releasing the two animations.
	[spinAnimation release];
    [sparkleAnimation release];
    
	[super dealloc];
}


@end
