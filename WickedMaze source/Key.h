//
//  Key.h
//  Wicked Maze
//
//  Created by Albith Delgado on 3/30/12.
//  Copyright 2012 __Albith Delgado__. All rights reserved.
//

#import "gameEntity.h"

//This class inherits from gameEntity  
    //and doesn't really any parameters.

@interface Key : gameEntity {

    
}

//Constructors
+(id) keyWithWorld:(b2World*)world andPosition:(CGPoint)keyPosition;
-(id) initWithWorld:(b2World*)world andPosition:(CGPoint)keyPosition;
-(void) createKeyInWorld:(b2World*)world andPosition:(CGPoint)keyPosition;

//The Key's member functions
-(void)keyCollected;


@end
