//
//  Key.m
//  Wicked Maze
//
//  Created by Albith Delgado on 3/30/12.
//  Copyright 2012 __Albith Delgado__. All rights reserved.
//

#import "Key.h"
#import "GameConstants.h"

@implementation Key

//Class constructors
-(id)initWithWorld:(b2World*)world andPosition:(CGPoint)keyPosition
{
	if ((self = [super init]))
	{
		[self createKeyInWorld:world andPosition:keyPosition];
	}
	return self;
}

+(id)  keyWithWorld:(b2World*)world andPosition:(CGPoint)keyPosition
{
	return [[[self alloc] initWithWorld:world andPosition:keyPosition] autorelease];
}


#pragma mark -create Goal in Box2d world.

-(void) createKeyInWorld:(b2World*)world andPosition:(CGPoint)keyPosition
{
	
    //1.This is very simple, in fact, this class may not be necessary (since it's so simple).
        //Calling the superClass gameEntity function:
    
    [super loadEntity:KEY_TAG atPosition:keyPosition 
            withWorld:world andOrientation:DEFAULT_ORIENTATION];    
}


-(void)keyCollected
{
    
    //The key's sprite goes invisible and its b2Body is removed.
        //b2Body will be destroyed.  Visibility set to False.
    
    entityType= BODY_TO_DESTROY;    
    sprite.visible= FALSE;
    
    //play effect:
    [[GameSoundManager sharedManager] playSoundEffect:KEY_SOUND];	 
    
}



-(void) dealloc
{
	[super dealloc];   
}




@end
