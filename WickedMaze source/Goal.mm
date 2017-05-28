//
//  Goal.m
//  Wicked Maze
//
//  Created by Albith Delgado on 12/26/11.
//  Copyright 2011 __Albith Delgado__. All rights reserved.
//

#import "Goal.h"
#import "GameConstants.h"


@implementation Goal


-(id)initWithWorld:(b2World*)world andPosition:(CGPoint)goalPosition
{
	if ((self = [super init]))
	{
		[self createGoalInWorld:world andPosition:goalPosition];
		
		
	}
	return self;
}

+(id)  goalWithWorld:(b2World*)world andPosition:(CGPoint)goalPosition
{
	return [[[self alloc] initWithWorld:world andPosition:goalPosition] autorelease];
}


#pragma mark -create Goal in Box2d world.

-(void) createGoalInWorld:(b2World*)world andPosition:(CGPoint)goalPosition
{
	

	
    //1.Calling the superClass gameEntity function:
    
    [super loadEntity:GOAL_TAG atPosition:goalPosition 
            withWorld:world andOrientation:DEFAULT_ORIENTATION];
    
    
    
    //2.Create and run the Goal's Spinning Action!
    
        [sprite runAction:[CCRepeatForever actionWithAction:
                          [CCSequence actions:
                           [CCRotateTo actionWithDuration:3 angle:180],
                           [CCRotateTo actionWithDuration:3 angle:360],
                           nil]
                          
                          ]];
    
}



-(void) dealloc
{
	NSLog(@"stopping Goal action and deallocing.");
    
    [sprite stopAllActions];
    
	[super dealloc];

}



@end
