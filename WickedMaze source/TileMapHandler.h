//
//  TileMapHandler.h
//  Wicked Maze
//
//  Created by Albith Delgado on 11.7.12.
//  Copyright 2011 __Albith Delgado__. All rights reserved.
//

//This class is similar to Lucky Warp's TileMapHandler class,
    //but here I've added functionality to 
    //add the tileMap shapes into the Box2D world as static bodies.

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "GameLevel.h"

@class GameLevel;

@interface TileMapHandler : NSObject 
{
    GameLevel *gameLevelInstance;
    NSString* levelName;    
}

@property (nonatomic, retain) CCTMXTiledMap *tileMap;
@property (assign) GameLevel *gameLevelInstance;


//Constructors
- (id) init:(GameLevel *)levelInstance;
- (void) prepareLevel;

- (void) addRectAt:(CGPoint)p withSize:(CGPoint)size dynamic:(BOOL)d 
         rotation:(long)r friction:(long)f density:(long)dens 
         restitution:(long)rest boxId:(int)boxId;

//Helper functions for processing tileMap data and adding bodies to the Box2D world.
    //Parsing a Tiled Polygon.
- (void)addPolygonAt:(CGPoint)originPoint withPoints:(NSMutableArray*)polygonPointsArray 
        arePointsClockWise:(BOOL)isClockWise  dynamic:(BOOL)d rotation:(long)r 
        friction:(long)f density:(long)dens restitution:(long)rest boxId:(int)boxId;

//Function used when creating Box2d Polygons.
-(BOOL)arePolygonPointsClockWise:(NSMutableArray *)polygonPointsArray;


@end
