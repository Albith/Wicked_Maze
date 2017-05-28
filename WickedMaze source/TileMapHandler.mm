//
//  TileMapHandler.mm
//  Wicked Maze
//
//  Created by Albith Delgado on 11. 7. 12..
//  Copyright 2011 __Albith Delgado__. All rights reserved.
//

#import "TileMapHandler.h"
#import "GameLevel.h"
#import "GlobalFunctions.h"
#import "GameConstants.h"

#define PTM_RATIO 32 //refers to the pixels to meters ratio.

@implementation TileMapHandler

@synthesize tileMap;
@synthesize gameLevelInstance;


- (id) init:(GameLevel *)levelInstance
{
	if( (self=[super init]) )
	{
    //First, we get a copy of the gameScene.
	self.gameLevelInstance=levelInstance;

    //Then, we load the tileMap.       
    tileMap = [CCTMXTiledMap tiledMapWithTMXFile:
                  [NSString stringWithFormat:@"level%d.tmx", self.gameLevelInstance.currentLevel]];
	
    //Loading a test tileMap.
        //tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"level3.tmx"];
            
    tileMap.anchorPoint = ccp(0, 0);
	    
    if(isDebugDrawing)    
        [self.gameLevelInstance addChild:tileMap z:-1];
	else 
        [self.gameLevelInstance.gameLayer addChild:tileMap z:-1];
    
    //preparing the level.    
    [self prepareLevel];
    
    }
	
	return self;
}


- (void) prepareLevel {
	
//-----------1. Loading and preparing TMX Collision Spaces.  
    
    //coordinates data from the tilemap.
    
    int x ;
    int y ;
    int w ;
    int h ;

    //Obtaining our collision space data from the tileMap
    CCTMXObjectGroup *collisionObjects = [tileMap objectGroupNamed:@"Collisions"];
	
    if(collisionObjects != nil)    
    {    
        //Data in this 'Collisions' layer 
            //describes polygonal and rectangular-shaped collision areas.
        NSMutableDictionary * objPoint;        
    
        for (objPoint in [collisionObjects objects]) {
            x = [[objPoint valueForKey:@"x"] intValue];
            y = [[objPoint valueForKey:@"y"] intValue];
            w = [[objPoint valueForKey:@"width"] intValue];
            h = [[objPoint valueForKey:@"height"] intValue];	
            
            //Checking for polygons.            
            if(w==0)
            {
                //Element is a POLYGON Collision Box.
                    //NSLog(@"New Point.");
               
               //Set up the polygonal data for parsing. (Using helper functions for some of this)
                NSString* polygonString=(NSString *)[objPoint objectForKey:@"points"];
                NSMutableArray* polygonPoints= [[GlobalFunctions myGlobalFunctions] getPointsFromString:polygonString];
                BOOL clockWiseCheck= [self arePolygonPointsClockWise:polygonPoints];
                
                //Add the polygonal physics body to the simulation.
                [self addPolygonAt:ccp(x*0.5f,y*0.5f) withPoints:polygonPoints arePointsClockWise:clockWiseCheck 
                dynamic:false rotation:0 friction:1 density:0.5f restitution:0.6f boxId:STAGE_COLLISION];
            }
            
            else
            {         
                //Element is a RECTANGULAR Collision Box.   
                    //Less data parsing is required.
                    //NSLog(@"Square Collision Box information: X %d, Y %d, width %d, height %d",x,y,w,h);   
            
                CGPoint _point=ccp(x+w/2,y+h/2);
                CGPoint _size=ccp(w,h);
                
                //Add the rectangular physics body to the simulation.
                [self addRectAt:_point withSize:_size dynamic:false rotation:0 friction:1 density:0.5f restitution:0.6f boxId:STAGE_COLLISION];
        
            
            }
            
        }

    }   
    
    else
    {
        
        NSLog(@"in TileMapHandler.mm: Collisions Layer is missing.");
        
        //[self.gameLevelInstance setSpecialCollisionWithFile:@"earthstage0_collision.plist" ];
        
    }
    
//----------->    
    
    //2. Getting Spikes information from the Spikes Collisions Layer.
    CCTMXObjectGroup *spikeObjects = [tileMap objectGroupNamed:@"Spike Collisions"];
	
    if(spikeObjects != nil)          //Collisions are square shaped and defined in the tilemap.
    {    
        NSMutableDictionary * objPoint;        
        
        for (objPoint in [spikeObjects objects]) {
            x = [[objPoint valueForKey:@"x"] intValue];
            y = [[objPoint valueForKey:@"y"] intValue];
            w = [[objPoint valueForKey:@"width"] intValue];
            h = [[objPoint valueForKey:@"height"] intValue];	   
            
            //NSLog(@"Polygon Description: %@", [objPoint description]);
            
            //Checking for polygonal spikes collision areas.
            if(w==0)
            {
                //Element is a POLYGON Collision Box.
                
                NSString* polygonString=(NSString *)[objPoint objectForKey:@"points"];
                NSMutableArray* polygonPoints= [[GlobalFunctions myGlobalFunctions] getPointsFromString:polygonString];
                BOOL clockWiseCheck= [self arePolygonPointsClockWise:polygonPoints];
    
                [self addPolygonAt:ccp(x*0.5f,y*0.5f) withPoints:polygonPoints arePointsClockWise:clockWiseCheck dynamic:false rotation:0 friction:1 density:0.5f restitution:0.6f boxId:SPIKES_TAG];             
            }
            
            else
            {                 
                //Element is a SQUARE Collision Box.
                    //NSLog(@"Square Collision Box information: X %d, Y %d, width %d, height %d",x,y,w,h);   
                
                CGPoint _point=ccp(x+w/2,y+h/2);
                CGPoint _size=ccp(w,h);
                  
                [self addRectAt:_point withSize:_size dynamic:false rotation:0 
                friction:1 density:0.5f restitution:0.6f boxId:SPIKES_TAG];        
            }
            
        }
        
    }   

    
//3.  Getting Moving Platforms / moving spikes information.
    
    //We are accessing 3 different layer for these 3 platform types.
        //      a.staticPlatforms
        //      b.polyLinePlatforms
        //      c.rotatingPlatforms
    
    //a. Fetching static Platforms data from its layer.
    CCTMXObjectGroup *platformsObjects = [tileMap objectGroupNamed:@"staticPlatforms"];
    
    if([[platformsObjects objects] count] > 0)
    {  
        [self.gameLevelInstance addStaticPlatformsWithArray:[platformsObjects objects]];    
    
        NSLog(@"Retrieved static Platforms.");
    }
        
    //b. Fetching polyLine Platforms data from its layer.
    platformsObjects = [tileMap objectGroupNamed:@"polyLinePlatforms"];
    
    if([[platformsObjects objects] count] > 0)
    {
        [self.gameLevelInstance addPolyLinePlatformsWithArray:[platformsObjects objects]];    
    
        NSLog(@"Retrieved polyLine Platforms.");
    }
        
    //c. Fetching rotating Platforms data from its layer.
    platformsObjects = [tileMap objectGroupNamed:@"rotatingPlatforms"];
    
    if([[platformsObjects objects] count] > 0)
    {
        [self.gameLevelInstance addRotatingPlatformsWithArray:[platformsObjects objects]];    
    
        NSLog(@"Retrieved rotating Platforms.");
    
    }    

//end of platform Loading.        
    

//4. Getting Game Objects Information.
    CCTMXObjectGroup *gameObjects = [tileMap objectGroupNamed:@"Game Objects"];
    
    if([[gameObjects objects] count] > 0)
    {  
        [self.gameLevelInstance setUpGameObjectsWithObjectGroup:gameObjects];
        
        NSLog(@"Retrieved Game Objects.");
    }
    
//5. Getting Barriers (if any) in Mutable Array Form.
    
    //CCTMXObjectGroup *barrierObjects = [tileMap objectGroupNamed:@"Barriers"];
    gameObjects = [tileMap objectGroupNamed:@"Barriers"];

    
    if([[gameObjects objects] count] > 0)
    {  
        [self.gameLevelInstance createBarriersWithMutableArray:[gameObjects objects]];
        
        NSLog(@"Retrieved Barriers.");
    }
    

//6. Getting Collectibles in Mutable Array Form.
    
    //CCTMXObjectGroup *collectibleObjects = [tileMap objectGroupNamed:@"Collectibles"];
    gameObjects = [tileMap objectGroupNamed:@"Collectibles"];

    
    if([[gameObjects objects] count] > 0)
    {  
        [self.gameLevelInstance createCollectiblesArrayWithMutableArray:[gameObjects objects]];
    
        NSLog(@"Retrieved Collectibles.");
    }
 
   
//7. Getting Enemies in Mutable Array Form.
    //      a.staticEnemies
    //      b.polyLineEnemies
    //      c.orbitingEnemies
    
    //a. static Enemies: both shooters and flyballs will go here.
        CCTMXObjectGroup *enemiesObjects = [tileMap objectGroupNamed:@"staticEnemies"];
        CCTMXObjectGroup *shooterObjects = [tileMap objectGroupNamed:@"shooters"];

    
        if( ( [[enemiesObjects objects] count] > 0) || ( [[shooterObjects objects] count] > 0) )
        {
            [self.gameLevelInstance addStaticEnemiesWithMutableArray:[enemiesObjects objects]
                                    andShootersArray:[shooterObjects objects]];    
    
            NSLog(@"Retrieved static Enemies.");
        }
    //b. polyLine Enemies
        enemiesObjects = [tileMap objectGroupNamed:@"polyLineEnemies"];
    
        if([[enemiesObjects objects] count] > 0)
        {   
            [self.gameLevelInstance addPolyLineEnemiesWithMutableArray:[enemiesObjects objects]];    
    
            NSLog(@"Retrieved polyLine Enemies.");
        }
//end of enemy loading.

} //End of tileMap data loading.


- (void) addRectAt:(CGPoint)p withSize:(CGPoint)size dynamic:(BOOL)d rotation:(long)r friction:(long)f density:(long)dens restitution:(long)rest boxId:(int)boxId
{
	//CCLOG(@"Add rect %0.2f x %02.f",p.x,p.y);
	
	//Define the dynamic body.
	//Set up a 1m squared box in the physics world
	b2BodyDef bodyDef;
	bodyDef.angle = r;
	
	if(d)
		bodyDef.type = b2_dynamicBody;
    else
        bodyDef.type = b2_staticBody;
    
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);

    //Creating the box2D body. 
    b2Body *body = gameLevelInstance.world->CreateBody(&bodyDef);

	// Define another box shape for our physics body.
	b2PolygonShape boxShape;
	boxShape.SetAsBox(size.x*0.5f/PTM_RATIO, size.y*0.5f/PTM_RATIO);//These are mid points for our 1m box
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &boxShape;	
	fixtureDef.density = dens;
	fixtureDef.friction = f;
	fixtureDef.restitution = rest;
	
    //Setting User Data IN THE FIXTURE.
        //Box2D user data can be any data type, here we are setting it as a string. 
    if(boxId==SPIKES_TAG)
    {
        fixtureDef.userData=@"S";   
    } 
    else   //userData for box areas that are not meant for spikes.
    {
        fixtureDef.userData=@"F";
    } 
    
    body->CreateFixture(&fixtureDef);
}

//Used in conjuction with an array of Polygon points.
    //This is useful when creating a polygonal box2D body,
    //where the order of point declaration matters.
-(BOOL)arePolygonPointsClockWise:(NSMutableArray *)polygonPointsArray
{
    int lineSegmentsSum= 0; 
    int numberOfPoints= [polygonPointsArray count];
    
    //1. looping through the points.
    CGPoint pointA, pointB;
    
    for(int index=0; index< numberOfPoints; index++)
    {
        
        if(index <  (numberOfPoints -1) )
            {
            
                pointA = [[polygonPointsArray objectAtIndex:index] CGPointValue];
    
                pointB = [[polygonPointsArray objectAtIndex:(index + 1)] CGPointValue];
            }
    
        else
            {
            
                pointA = [[polygonPointsArray objectAtIndex:index] CGPointValue];
                
                pointB = [[polygonPointsArray objectAtIndex:0] CGPointValue];

            }
          
     //2. adding information to lineSegmentsSum.
        lineSegmentsSum += ( pointB.x- pointA.x )*( pointB.y + pointA.y );
 
        
    }
    
    if(lineSegmentsSum==0)
        NSLog(@"TileMapHandler.mm, arePolygonPointsClockwise []: Checking Polygon Points ClockWise: Result is 0!");
    
    //By adding the line segments and verifying the sign of the result,
        //we can tell if points are arranged clockwise or counter-clockwise.
    if(lineSegmentsSum > 0)
        return TRUE;
    else 
        return FALSE;

}

//adds a polygonal physics shape to the Box2D world.
- (void) addPolygonAt:(CGPoint)originPoint  withPoints:(NSMutableArray*)polygonPointsArray  arePointsClockWise:(BOOL)isClockWise dynamic:(BOOL)d rotation:(long)r friction:(long)f density:(long)dens restitution:(long)rest boxId:(int)boxId
{
	//CCLOG(@"Add polygon %0.2f x %02.f",p.x,p.y);
	//NSLog(@"Origin Point is: X %f, Y %f", originPoint.x, originPoint.y);
    
	b2BodyDef bodyDef;
	bodyDef.angle = r;
	
	if(d)
		bodyDef.type = b2_dynamicBody;
	
    else
        bodyDef.type = b2_staticBody;
    
    
	bodyDef.position.Set(originPoint.x/PTM_RATIO, originPoint.y/PTM_RATIO);
    
    //Initializing the Box2D body.
    b2Body *body = gameLevelInstance.world->CreateBody(&bodyDef);
    
	// Define a polygon shape for our dynamic body.
	b2PolygonShape myPolygonShape;
	
        //1.Creating my array of vertices.
        int numberOfVertices= [polygonPointsArray count];
        b2Vec2 *myVertices= new b2Vec2[numberOfVertices];
    
    
        //2.Checking the orientation of my points list.
                for(int index=0; index< numberOfVertices; index++)
                {
                
                    CGPoint currentPoint = [[polygonPointsArray objectAtIndex:index] CGPointValue];
                    
                    //NSLog(@"Polygon Points are: X %f, Y %f", tempPoint.x, tempPoint.y );
                            
                        currentPoint= ccp((currentPoint.x + originPoint.x), (currentPoint.y + originPoint.y) );
                    
                    //NSLog(@"Polygon Points are: X %f, Y%f", currentPoint.x, currentPoint.y);
                    
                    //if orientation is counterClockWise, iterate through polygonArray in Ascending order.
                        if(!isClockWise)
                            myVertices[index]= b2Vec2( currentPoint.x/PTM_RATIO, currentPoint.y/PTM_RATIO );
                
                    //if orientation is clockWise, iterate through array in Descending order, starting from the end.
                        else
                            myVertices[(numberOfVertices -1)- index]= b2Vec2( currentPoint.x/PTM_RATIO, currentPoint.y/PTM_RATIO );     
                }
 
    
        //3.Setting my polygon Shape based on the list of vertices I've created.
        myPolygonShape.Set(myVertices, numberOfVertices);        
    
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &myPolygonShape;	
	fixtureDef.density = dens;
	fixtureDef.friction = f;
	fixtureDef.restitution = rest;
	
    //Setting User Data IN THE FIXTURE: 
    if(boxId==SPIKES_TAG)
    {
        fixtureDef.userData=@"S";   
    }    
    
    else
    {
        //Fixture Def shows @"F" for "Floor."
        fixtureDef.userData=@"F";
    }
    
    body->CreateFixture(&fixtureDef);

    //Deleting the array of box2D vectors, it's no longer needed.
    delete myVertices;
 
        
}

- (void) dealloc
{
	// cocos2d will automatically release all the children (Label)
	
    //deleting these two objects.
        self.tileMap = nil;
        self.gameLevelInstance=nil;
	
	// don't forget to call "super dealloc"
	    [super dealloc];
}

@end

