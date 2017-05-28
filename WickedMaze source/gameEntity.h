//
//  gameEntity.h
//  Wicked Maze
//
//  Created by Albith Delgado on 1/15/12.
//  Copyright 2012 Albith Delgado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"

//gameEntity is a base class for all the in-game elements.
    //All in-game Elements consist of a sprite (a visual representation)
    //and a physics body (its representation in the physics simulation)
    //the entityType is used to 
        //distinguish between different entity instances and body types.

//This is based on a class with the same name and attributes posted
    //by Ray Wenderlich on his website.

@interface gameEntity : CCNode {
    
    CCSprite* sprite;
    b2Body* body;
    
    int entityType; 
}

@property (readonly, nonatomic) CCSprite* sprite;
@property (readonly, nonatomic) b2Body* body;
@property (assign) int entityType;


//---Class constructors.
+(id) newEntity:(int)myEntityType atPosition:(CGPoint)entityPosition 
      withWorld:(b2World*)world andOrientation:(int)entityOrientation;

-(id) initEntity:(int)myEntityType atPosition:(CGPoint)entityPosition 
       withWorld:(b2World*)world andOrientation:(int)entityOrientation;

-(void) loadEntity:(int)entityType atPosition:(CGPoint)entityPosition 
         withWorld:(b2World*)world andOrientation:(int)entityOrientation;


//Helper function to create b2Bodies from Physics Editor Shapes
-(void) makeb2BodyFromCollisionFile:(NSString*)collisionFileName 
                       andLayerName:(NSString*)layerName;           

//5.18.2012 Helper Function: Added Fixture Data Argument.
-(void) makeb2BodyFromCollisionFile:(NSString*)collisionFileName 
                       andLayerName:(NSString*)layerName   
                andFixtureUserData:(NSString*)fixtureUserData;

//Used to manually set the entity's position, without applying physics forces.
-(void)setEntityPosition:(CGPoint)entityPosition;

//Not using this method.
    //Making rotationJoints.
        //-(void) makeRotationJoinWithWorld:(b2World*)world;  //for movable rotating parts.

-(void)removeBody;

@end
