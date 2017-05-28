//
//  gameEntity.m
//  Wicked Maze
//
//  Created by Albith Delgado on 1/15/12.
//  Copyright 2012 Albith Delgado. All rights reserved.
//

#import "gameEntity.h"
#import "GameConstants.h"
#import "GB2ShapeCache.h"


@implementation gameEntity

@synthesize body,sprite, entityType;

//------This next constructor is only for use when creating platforms.
+(id) newEntity:(int)myEntityType atPosition:(CGPoint)entityPosition 
      withWorld:(b2World*)world andOrientation:(int)entityOrientation
{
    return [[[self alloc] initEntity:myEntityType atPosition:entityPosition 
                           withWorld:world andOrientation:entityOrientation] autorelease];
    
}


-(id) initEntity:(int)myEntityType atPosition:(CGPoint)entityPosition 
       withWorld:(b2World*)world andOrientation:(int)entityOrientation
{
    
	if ((self = [super init]))
	{
		[self loadEntity:myEntityType atPosition:entityPosition 
               withWorld:world andOrientation:entityOrientation];
		
		
	}
	return self;    
    
}
    

//Setting up the entity according to its type and orientation.
    //Note: the level tiles are not set up as entities.
-(void) loadEntity:(int)myEntityType atPosition:(CGPoint)entityPosition 
         withWorld:(b2World*)world andOrientation:(int)entityOrientation
{
    
//0.Checking that the Box2D physics world has already been created. 
    //This must be true in order to proceed.
    NSAssert(world != NULL, @" gameEntity.m: world is null!");
    [self removeBody];
    
//1. Setting up the sprite.
    NSString* spriteFrameName;
  
    //this variable used for loading barrier entities.
    bool isEntityBarrier= FALSE;

//----------defining the Ball, Key, Goal and Coins sprite filenames.
    
    switch (myEntityType) {
        case PLAYER_TAG:
            spriteFrameName= @"playerBall.png";
            NSLog(@"Player Ball loaded.");
            break;
        
        case KEY_TAG:
            spriteFrameName= @"keySprite.png";
            NSLog(@"Key loaded.");
            break;    
        
        case GOAL_TAG:
            spriteFrameName= @"vortex.png";
            NSLog(@"Goal loaded.");
            break;     
            
        case COINS_TAG:
            spriteFrameName= @"coin0.png";
            break;
       
//--------defining Barrier Sprites filenames.           
        
        case DUMMY_TILE_BARRIER_TYPE:
            spriteFrameName= @"dummyTile.png";
            isEntityBarrier=TRUE;
            break;    
        
        case BROKEN_TILE_BARRIER_TYPE:
            spriteFrameName= @"brokenTile.png";
            isEntityBarrier=TRUE;
            break;    
            
        case WOOD_BARRIER_TYPE:
           spriteFrameName= @"woodBarrier.png";
            isEntityBarrier=TRUE;
            break;
        
        case HARD_BARRIER_SMALL_TYPE:
            spriteFrameName= @"steelBarrierSmall.png";
            isEntityBarrier=TRUE;
            break;    
            
        case CAGE_BARRIER_TYPE:
            spriteFrameName= @"cage4x.png";
            isEntityBarrier=TRUE;
            break;     

//--------defining Enemy Sprites filenames.
            
        case ENEMY_FLYBALL_TYPE:
            spriteFrameName= @"mosquito0.png";
            break;    
            
        case ENEMY_SHOOTER_TYPE:
            spriteFrameName= @"shooter0.png";
            break;     
            
        case ENEMY_BULLET_TYPE:
            spriteFrameName= @"shooterBullet0.png";
            break;     
            
//--------defining Platform Sprites filenames.
        
        case SPIKE_STAR_TYPE:
            spriteFrameName= @"spikeStar.png";
            break;     
            
        case SPIKE_PLATFORM_TYPE:
            spriteFrameName= @"spikePlatformSmall3Tiles.png";
            break;
            
        case PLATFORM_SMALL_TYPE:
            spriteFrameName= @"platformSmall3Tiles.png";
            break;
         
        case PLATFORM_MEDIUM_TYPE:
            spriteFrameName= @"platformMedium6Tiles.png";
            break;    
         
        case PLATFORM_LONG_TYPE:
            spriteFrameName= @"platformLong9Tiles.png";
            break;
            
        case CIRCLE_SMALL_TYPE:
            spriteFrameName= @"circleSmall3x.png";
            break;
            
        case CIRCLE_MED_TYPE:
            spriteFrameName= @"circleMed4x.png";
            break;
            
        case CIRCLE_HUGE_TYPE:
            spriteFrameName= @"circleLarge6x.png";
            break;
        
        case CROSS_TYPE:
            spriteFrameName= @"crossPlatform4x.png";
            break;    
        
        case TRIANGLE_REGULAR_TYPE:
            spriteFrameName= @"trianglePlatform8x5y.png";
            break;    
         
        case TRIANGLE_HUGE_TYPE:
            spriteFrameName= @"trianglePlatform10x6_25y.png";
            break;    
            
//------------end of Platform Sprites filename setup.   
            
        default:
            NSLog(@"gameEntity.m: incorrect entity Type entered.");
            break;
    
    }
    
    
        //Finally, initializing the Sprite according to its filename.
        sprite = [CCSprite spriteWithSpriteFrameName:spriteFrameName];
        sprite.tag= myEntityType;

    
//--------2. ROTATING our entity (Barrier or Platform) as needed.
    //This is based on the entityOrientation variable.

    switch (entityOrientation) 
    {
    
        case UPSIDE_DOWN_ORIENTATION:
            [sprite setRotation:180];            
            break;
         
        case FACING_LEFT_ORIENTATION:    
            [sprite setRotation:90];
            break;

        case FACING_RIGHT_ORIENTATION:    
            [sprite setRotation:-90]; 
            break;
            
        default:
            //do Nothing. the Sprite orientation is unmodified.
            break;
    }
    

//---------3. If the entity is a barriier:
            //SHIFTING the Barrier Position so the Barrier Break Animation doesn't offset.
            //We don't want to change the Anchor Point this time. 
    
    if(isEntityBarrier)
    {
        
        sprite.position= ccp(
                               (entityPosition.x + [sprite boundingBox].size.width*0.5f) , 
                                (entityPosition.y + [sprite boundingBox].size.height*0.5f)
                                        );
    }    
    
    
    //3a. If an enemy shooter is being created, 
            //let's check orientation and assign a position accordingly.
            //previously modifying the sprite's anchor point.
    else if(myEntityType==ENEMY_SHOOTER_TYPE)
    {
        //NSLog(@"gameEntity.mm: changing Shooter position based on its orientation.");
        switch(entityOrientation)
        {
            case FACING_LEFT_ORIENTATION:    
                //sprite.anchorPoint=ccp(1, 0.5f);
                sprite.position= ccp(
                                     (entityPosition.x - [sprite boundingBox].size.width*0.5f) , 
                                     entityPosition.y  );
                break;
                
            case FACING_RIGHT_ORIENTATION:    
                //sprite.anchorPoint=ccp(0, 0.5f);
                sprite.position= ccp(
                                     (entityPosition.x + [sprite boundingBox].size.width*0.5f) , 
                                     entityPosition.y );
                break;    
             
            case UPSIDE_DOWN_ORIENTATION:    
                //sprite.anchorPoint=ccp(0.5f, 0);
                sprite.position= ccp(
                                     entityPosition.x , 
                                     (entityPosition.y + [sprite boundingBox].size.height*0.5f)
                                     );
                break;    
             
            default:    
                //sprite.anchorPoint=ccp(0.5f,  1);
                sprite.position= ccp(
                                     entityPosition.x , 
                                     (entityPosition.y - [sprite boundingBox].size.height*0.5f)
                                     );
                break;    
                
                
        }    
    }
    
    else   
         sprite.position = entityPosition;

    [self addChild:sprite];
	
	
   
//---------4. Defining Body Type, Position, and User Data.
    //A. Body Type: 
        //can be dynamic(the player ball is), kinematic(useful for platforms), or static.
    
    b2BodyDef  bodyDef;
    
        if(myEntityType==PLAYER_TAG)        
        {
            bodyDef.type = b2_dynamicBody;
            bodyDef.bullet = true;   
        }
         
        else if(myEntityType==ENEMY_BULLET_TYPE)
        {
        
        bodyDef.type = b2_dynamicBody;    
        //bodyDef.bullet = TRUE;

        bodyDef.fixedRotation=TRUE;
        
        NSLog(@"gameEntity.mm: created the Bullet.");
        }
    
        //Setting platform-type objects as kinematic.
        else if ( (myEntityType>=SPIKE_STAR_TYPE) )      
            bodyDef.type = b2_kinematicBody;
        
        //By default, entities are static bodies.
        else
            bodyDef.type = b2_staticBody;
//----------

    //B. Setting the body positions 
            //according to the spawnPoint specified in the tileMap.
    
            //Not using this currently.
        //        if(isEntityBarrier)   //b2BodyDef's position is offset, following the anchor point (0,0)
        //            bodyDef.position.Set(
        //                                 (entityPosition.x + [sprite boundingBox].size.width*0.5f)/PTM_RATIO , 
        //                                 (entityPosition.y + [sprite boundingBox].size.height*0.5f)/PTM_RATIO
        //                                 );
        //
        //        else

        bodyDef.position.Set(sprite.position.x/PTM_RATIO, sprite.position.y/PTM_RATIO);
	

    //C. Setting the bodies' User Data.
        //This is a way to easily access gameEntity data
        //through the physics bodies, say in a collision handling routine.
        bodyDef.userData = self;
	
    
    //D. Finally, create the box 2d body (b2Body) inside the physics world.
        body = world->CreateBody(&bodyDef);

//----------	
    
//4. --------Defining the physics body shape, according to the entityType.
	
switch (myEntityType) 
    {
        
        case PLAYER_TAG:
        {
            //The ball has a circle physics body shape.
            b2CircleShape circle;
            circle.m_radius = 17.0/PTM_RATIO;
             
            // Define the dynamic body fixture.
            b2FixtureDef fixtureDef;
            fixtureDef.shape = &circle;	
            fixtureDef.density = 0.8f;
            fixtureDef.friction = 1.2f;
            fixtureDef.restitution= 0.2f;
            body->CreateFixture(&fixtureDef);
            
        }
            break;
           
        case GOAL_TAG:
        {
            //The goal object is shaped like a vortex, hence a circle.
            b2CircleShape circle;
            circle.m_radius = 20.0/PTM_RATIO;
              
            // Define the dynamic body fixture.
            b2FixtureDef fixtureDef;
            fixtureDef.shape = &circle;	
            fixtureDef.density = 0.8f;
            fixtureDef.friction = 1.2f;
            fixtureDef.restitution= 0.2f;
            
            //This object is a sensor. 
                //Similar to Unity's trigger objects, it only detects simple collisions.
            fixtureDef.isSensor = true;
              
            body->CreateFixture(&fixtureDef);
        }
            break;
        
            
        case COINS_TAG:
        
            [self makeb2BodyFromCollisionFile:@"coin" andLayerName:@"coin0"];
       
            break;
        
 
//--------------------------ENEMY b2Body Shapes:-------------------

    //Note: similar to Sprite Batch Nodes, b2Body Caches facilitate creating 
        //many copies of box2D objects for better performance.

            
        case ENEMY_FLYBALL_TYPE:    
        
            [self makeb2BodyFromCollisionFile:@"mosquitoCollision" andLayerName:@"mosquito0"];
        
            break;
            
            
        case SPIKE_STAR_TYPE:    
 
            [self makeb2BodyFromCollisionFile:@"spikeStarCollision" 
                                 andLayerName:@"star" 
                           andFixtureUserData:@"S"];
              
            break;

//Note: I'm commenting this enemy type 
        //because its shape is the default shape.

//        case ENEMY_SHOOTER_TYPE:    
//        {
            //The Shooter's b2Body will be a box.
            //The Default Shape will be used then.
            
            //[self makeb2BodyFromCollisionFile:@"shooterEnemyCollision" andLayerName:@"shooter0_temp"];   
//        }   
//            break;    
            
        case ENEMY_BULLET_TYPE:    
            
            [self makeb2BodyFromCollisionFile:@"bulletCollision" andLayerName:@"shooterBullet1"];

            break;  
            
            
//--------------PLATFORM b2Body Shapes. The default case is also used to define the platforms.
        
        case CIRCLE_SMALL_TYPE:             
        {
            b2CircleShape circle;
            circle.m_radius = [sprite boundingBox].size.height*0.5f/PTM_RATIO;
                    
            // Define the dynamic body fixture. 
            //This restricts the movement or rotation of the platform.
            b2FixtureDef fixtureDef;
            fixtureDef.shape = &circle;	
            fixtureDef.density = 2.5f;
            fixtureDef.friction = 1;
            fixtureDef.restitution= 1.4f;
            
            body->CreateFixture(&fixtureDef);  
        }
            
            break;
        
        case CIRCLE_MED_TYPE:
        {
            b2CircleShape circle;
            circle.m_radius = [sprite boundingBox].size.height*0.5f/PTM_RATIO;
            
            // Define the dynamic body fixture.
            b2FixtureDef fixtureDef;
            fixtureDef.shape = &circle;
            fixtureDef.density = 2.5f;
            fixtureDef.friction = 1;
            fixtureDef.restitution= 1.4f;
            
            body->CreateFixture(&fixtureDef);  
        }
            
            break;
            
        
         //This case is treated the Same way as the CIRCLE_SMALL one.
        case CIRCLE_HUGE_TYPE:              
        {
            b2CircleShape circle;
            circle.m_radius = [sprite boundingBox].size.height*0.5f/PTM_RATIO;
            
            
            // Define the dynamic body fixture.
            b2FixtureDef fixtureDef;
            fixtureDef.shape = &circle;	
            fixtureDef.density = 2.5f;
            fixtureDef.friction = 1;
            fixtureDef.restitution= 1.4f;
            
            body->CreateFixture(&fixtureDef);
            
        }
            
            break;    
         
            
        case CROSS_TYPE:    
            
            [self makeb2BodyFromCollisionFile:@"crossPlatform" andLayerName:@"cross"];
            
            break;    
            
        case TRIANGLE_REGULAR_TYPE:    
            
            [self makeb2BodyFromCollisionFile:@"triangleRegular" andLayerName:@"triangle"];
            //[sprite setAnchorPoint:ccp(0.4, 0.2)];

            
            break;    
         
        case TRIANGLE_HUGE_TYPE:    
            
            [self makeb2BodyFromCollisionFile:@"triangleHuge" andLayerName:@"triangle"];
            //[sprite setAnchorPoint:ccp(0.38, 0.29)];
            
            break;
            
    
//-------------SPIKE PLATFORM.   This is long!
            
        case SPIKE_PLATFORM_TYPE:           //Creating a Box for the b2Body
        {
            
            // This particular shape is more complex,
                //because it consists of two boxes:
                //one box for the platform portion
                //another box for the spikes portion.
            
            b2PolygonShape platformBox, spikeBox;
            float32 hx, hy;
            
            
            //0. Creating our polygonShapes for our Box, 
                //depending on the orientation.
            switch(entityOrientation)
            {
                case FACING_LEFT_ORIENTATION:
                    
                    hx= [sprite boundingBox].size.width*0.25f/PTM_RATIO;
                    hy= [sprite boundingBox].size.height*0.5f/PTM_RATIO;
                    
                    platformBox.SetAsBox(hx, hy, b2Vec2(hx,0), 0);
                    spikeBox.SetAsBox(hx, hy, b2Vec2(-hx,0), 0);
                    
                    break;    
                    
                    
                case FACING_RIGHT_ORIENTATION:
                    
                    hx= [sprite boundingBox].size.width*0.25f/PTM_RATIO;
                    hy= [sprite boundingBox].size.height*0.5f/PTM_RATIO;
                    
                    platformBox.SetAsBox(hx, hy, b2Vec2(-hx,0), 0);
                    spikeBox.SetAsBox(hx, hy, b2Vec2(hx,0), 0);
                    
                    break;
                            
                    
                case UPSIDE_DOWN_ORIENTATION:   //Spikes in Platform facing Up.
                    
                    hx= [sprite boundingBox].size.width*0.5f/PTM_RATIO;
                    hy= [sprite boundingBox].size.height*0.25f/PTM_RATIO;
                    
                    platformBox.SetAsBox(hx, hy, b2Vec2(0,-hy), 0);
                    spikeBox.SetAsBox(hx, hy, b2Vec2(0,hy), 0);
                    
                    break;
                    
                    
                default:        //Spikes in Platform facing Down.
                    
                    hx= [sprite boundingBox].size.width*0.5f/PTM_RATIO;
                    hy= [sprite boundingBox].size.height*0.25f/PTM_RATIO;
                    
                    platformBox.SetAsBox(hx, hy, b2Vec2(0,hy), 0);
                    spikeBox.SetAsBox(hx, hy, b2Vec2(0,-hy), 0);
                    
                    break;
                
            }
            
            
        //Fixture 1: Platform Part
            
            //Next, define the fixture for the platform part.
            //platformBox.SetAsBox(hx, hy, b2Vec2(0,hy), 0);
           
            // Define the Fixture 1's dynamic body fixture.
                b2FixtureDef fixtureDef;
                fixtureDef.shape = &platformBox;	
                fixtureDef.density = 1;
                fixtureDef.friction = 1;
                fixtureDef.restitution= 1;
            
                body->CreateFixture(&fixtureDef);
            
          
        
        //Fixture 2: Spike Part
  
            //Define the fixture for the spike part.
            //spikeBox.SetAsBox(hx, hy, b2Vec2(0,-hy), 0);
             
            // Define the Fixture 1's dynamic body fixture.
                b2FixtureDef fixtureDef2;
                fixtureDef2.shape = &spikeBox;	
                fixtureDef2.density = 0.5f;
                fixtureDef2.friction = 1;
                fixtureDef2.restitution= 0.6f;
                
                fixtureDef2.userData=@"S";

                body->CreateFixture(&fixtureDef2);
            
 
            NSLog(@"Spike Platform Box created.");
            
            
        }
            
            
            
            
//------DEFAULT b2Body Shape---------------:
            
        default:            //Creating a Box for the b2Body
            {
            
                // Define another box shape for our dynamic body.
                
                b2PolygonShape dynamicBox;
                dynamicBox.SetAsBox([sprite boundingBox].size.width*0.5f/PTM_RATIO, 
                                    [sprite boundingBox].size.height*0.5f/PTM_RATIO);
                
                //These are mid points for our 1m box
                
                // Define the dynamic body fixture.
                b2FixtureDef fixtureDef;
                fixtureDef.shape = &dynamicBox;	
                fixtureDef.density = 0.5f;
                fixtureDef.friction = 1;
                fixtureDef.restitution= 0.6f;
                
                
                body->CreateFixture(&fixtureDef);

                NSLog(@"Default gameEntity Shape (box) created.");
                
                
            }
            
            break;
    } 
 
    
 //END OF SWITCH STATEMENT. #3   
    
    //entityType Data saved here.
    
        entityType=myEntityType;
    
        
}


#pragma mark Helper Functions for gameEntity

//Helper function used to create custom Box2d shapes in the physics world.
    //To do this, an external program was used to create custom shapes, 
    //saved to 2 files: a .plist and a .pes file.
-(void) makeb2BodyFromCollisionFile:(NSString*)collisionFileName
                       andLayerName:(NSString*)layerName
{
    [[GB2ShapeCache sharedShapeCache] addShapesWithFile:[NSString stringWithFormat:@"%@.plist",collisionFileName]];
    
    
    //attaching fixtures to Body
    [[GB2ShapeCache sharedShapeCache] 
     addFixturesToBody:body forShapeName:layerName];
    
    //setting anchorPoint of the sprite
    [sprite setAnchorPoint:   [  [GB2ShapeCache sharedShapeCache]    anchorPointForShape:layerName]    ];      

}

//Helper function used to create custom Box2d shapes in the physics world (and with custom fixture data).
    //To do this, an external program was used to create custom shapes, 
    //saved to 2 files: a .plist and a .pes file.
-(void) makeb2BodyFromCollisionFile:(NSString*)collisionFileName
                       andLayerName:(NSString*)layerName
                 andFixtureUserData:(NSString *)fixtureUserData
{
    
    
    [[GB2ShapeCache sharedShapeCache] 
            addShapesWithFile:[NSString stringWithFormat:@"%@.plist",collisionFileName]
          withFixtureUserData:fixtureUserData];
    
    //attaching fixtures to Body
    [[GB2ShapeCache sharedShapeCache] 
     addFixturesToBody:body forShapeName:layerName];
    
    //setting anchorPoint of the sprite
    [sprite setAnchorPoint:   [  [GB2ShapeCache sharedShapeCache]    anchorPointForShape:layerName]];
}

-(void)setEntityPosition:(CGPoint)entityPosition
{  
    //This positioning function is used only by the Bullet Class.

    body->SetTransform(b2Vec2( entityPosition.x/PTM_RATIO,
                              entityPosition.y/PTM_RATIO), 0);
     
    sprite.position=entityPosition;
}


-(void)removeBody
{
    //Removing this entity's' body component from the box2D world.
    if (body != NULL)
	{
		body->GetWorld()->DestroyBody(body);
		body = NULL;
	}        
}


-(void) dealloc
{	
    //Note: by assigning this special tag to the entity,
        //the gameEntity lets the Box2D world remove the body in its physics loop.
        //this is the safest way to destroy the entity's b2Body component.
    sprite.tag= BODY_TO_DESTROY;
	[super dealloc];
}

@end
