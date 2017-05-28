//
//  Goal.h
//  Wicked Maze
//
//  Created by Albith Delgado on 12/26/11.
//  Copyright 2011 __Albith Delgado__. All rights reserved.
//

//This is another class that inherits from gameEntity.
    //It doesn't extend it in any meaningful way, 
    //so this class could be removed in the future.

#import "gameEntity.h"


@interface Goal : gameEntity {
    
    
}

//Constructors
+(id) goalWithWorld:(b2World*)world andPosition:(CGPoint)goalPosition;
-(id) initWithWorld:(b2World*)world andPosition:(CGPoint)goalPosition;
-(void) createGoalInWorld:(b2World*)world andPosition:(CGPoint)goalPosition;


@end
