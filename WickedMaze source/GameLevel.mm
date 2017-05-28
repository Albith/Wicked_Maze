//
//  GameLevel.mm
//  Wicked Maze
//
//  Created by Albith Delgado on 12/16/11.
//  Copyright __Albith Delgado__ 2011. All rights reserved.
//

#import "GameLevel.h"
#import "GameConstants.h"

#import "GlobalFunctions.h"
#import "GB2ShapeCache.h"

#import "TitleScreen.h"

//Including the parent class for all game elements.
#import "gameEntity.h"


@implementation GameLevel


@synthesize gameLayer;
@synthesize world, myTileMapHandler, myBulletManager, currentLevel;
@synthesize player, isEnemyCheckInProgress, isInPauseMenu;

//Setting up our gameLevel Singleton instance.
static GameLevel* instanceOfGameLevel;
+(GameLevel*) sharedGameLevel;
{
	//NSAssert(instanceOfGameScene != nil, @"GameScene instance not yet initialized!");
	if(instanceOfGameLevel == nil)
        return nil;
    else return instanceOfGameLevel;
}

//Setting up our scene to accept touches.
- (void) onEnterTransitionDidFinish
{
       [super onEnterTransitionDidFinish];    
        
        if(!isDebugDrawing)
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:1 swallowsTouches:YES];    
}

//Constructors.
+(CCScene *) sceneWithLevel:(int)levelNumber;
{
	// 'Scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'Layer' is an autorelease object.
	GameLevel *layer = [GameLevel node];
    [layer initWithLevel:levelNumber];

	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

//Initializing the gameLevel instance.
-(id) initWithLevel:(int)levelNumber
{
	// Always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		
        //1. Loading the game's artwork.
            CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
            [frameCache addSpriteFramesWithFile:@"ballSprites.pv.plist"];
        
        //Playing our Music track.
            //If it's not playing, start playing it.
            if(![[GameSoundManager sharedManager].soundEngine isBackgroundMusicPlaying])
            {
                [[GameSoundManager sharedManager] playSong:TEST_SONG ];
            }
        
        numberOfShooters=0;
        
        //Game level instance.
            instanceOfGameLevel=self;
            currentLevel= levelNumber;
        
        //Enable touches and the accelerometer (Touches if Debug Drawing is off)
            self.isAccelerometerEnabled = YES;
		
		//Creating a gravity vector.
		b2Vec2 gravity;
                //Setting ballGravity to 0 for now.
                    ballGravity= b2Vec2(0,0);
        		
    //0. Creating the Box2d World.
        bool doSleep = false;
        world = new b2World(gravity, doSleep);
		world->SetContinuousPhysics(true);

       
    
    //1.Enable debug drawing if needed, 
        //by setting the isDebugDrawing variable to true.    
        if(isDebugDrawing)     
        {	
            NSLog(@"In Debug Drawing.");
            
            // Debug Draw functions
            m_debugDraw = new GLESDebugDraw( PTM_RATIO );
            world->SetDebugDraw(m_debugDraw);
            
            uint32 flags = 0;
            flags += b2DebugDraw::e_shapeBit;
            
            //Uncomment this section as needed.
            //		flags += b2DebugDraw::e_jointBit;
            //		flags += b2DebugDraw::e_aabbBit;
            //		flags += b2DebugDraw::e_pairBit;
            //		flags += b2DebugDraw::e_centerOfMassBit;
            
            m_debugDraw->SetFlags(flags);		     
        }	      		

    //2.Else, set our pause and game layers.    
        else 
        {
            self.isTouchEnabled = YES;  // For accesing the Pause menu.
            isInPauseMenu=FALSE;
            
            //Start up our 2 main cocos2D nodes.
                gameLayer= [CCNode node];
                [self addChild:gameLayer];
                
                //The pauseLayer slightly grays out the gameLayer,
                    //so we're setting up a color.
                pauseLayer= [CCLayerColor layerWithColor:ccc4(0,0,0,0)];
                [self addChild:pauseLayer];
            
            //Creating our Pause Menu.
            [self createPauseMenu];
        }
        
        //Setting up our accelerometer values.
        prevX=0, prevY=0;
        accelX=0, accelY=-10.0f;    
     
        
    //2.5 Initalize Collectible and Enemy Arrays.
        collectiblesArray= [[NSMutableArray alloc] init];    
        enemiesArray=[[NSMutableArray alloc] init];
        barriersArray= [[NSMutableArray alloc] init];
        
        numberOfEnemies_beforeBarrierOpened_Count=0;
        isEnemyCheckInProgress=FALSE;
        
        //mapping the platforms Dictionary
        [self mapPlatformDictionary];
        
    //3. In case we do not use the Tilemap for level data. 
        //Note: not using this section of code for this version of the game.   
            // if(currentLevel==-1)    
            // {  
            //     load plist for the level.
                
            //     Load other elements: level, player, goal.
            //     [self loadPlist]; //player, goal.
            //     [self setSpecialCollisionWithFile:[NSString stringWithFormat:@"Maze%d_collisionShapes.plist", currentLevel]];
            // }    
     
    else
    {
        //Tilemap Handler. All gameLayer objects get loaded up here.
            myTileMapHandler= [[TileMapHandler alloc] init:self];   
    }
  
        //4. Create the contact listener,
            contactListener = new MyContactListener();
            world->SetContactListener(contactListener);
		
        
        //5.Activate the shooter enemies, if any.
                if(numberOfShooters>0)
                    [self startShootersActions];

        //6. Calling the main game loop.
            NSLog(@"calling Selector Loops.");
                [self schedule: @selector(gameLoop:)];
            
            if(isDebugDrawing)
                [self schedule: @selector(scrollLevel)];
            else 
                [self schedule: @selector(scrollGameLayer)];

    }
	return self;

}

#pragma mark Pause Menu Functions

-(void)createPauseMenu
{
    //1.Populate the pauseLayer node with:
        //"Paused" text
            pausedText= [CCLabelBMFont labelWithString:@"Paused" fntFile:@"GlyphsForDemo.fnt"];
            
            //pausedText.anchorPoint= ccp(0,0);
            pausedText.position= ccp(160, 430);
            pausedText.scale= 1.1;
    
            //pausedText.visible= NO;
            pausedText.opacity=0;
    
                [pauseLayer addChild:pausedText];
        
        //"Back To Menu" text.
            backToMenuText= [CCLabelBMFont labelWithString:@"back \nto \nmenu" fntFile:@"GlyphsForDemo.fnt"];

    
            backToMenuText.anchorPoint= ccp(0,1);
            backToMenuText.position= ccp(13, 200);
    
            //backToMenuText.visible= NO;
            backToMenuText.opacity=0;
            //backToMenuText.color=(ccColor3B){239,224,184};

    
                [pauseLayer addChild:backToMenuText];
            
        //"Continue" text.
            continueText= [CCLabelBMFont labelWithString:@"resume" fntFile:@"GlyphsForDemo.fnt"];

            continueText.anchorPoint= ccp(0,1);
            continueText.position= ccp(169, 162);
            
            continueText.scale= 0.9;
    
            //continueText.visible= NO;
            continueText.opacity=0;
            //continueText.color=(ccColor3B){239,224,184};
                [pauseLayer addChild:continueText];

    //2. Enlarging our Bounding Boxes to accomodate more space for scren touches.
            [continueText setContentSize:
             CGSizeMake( continueText.contentSize.width, continueText.contentSize.height*1.3 )];
    
    //3. Creating the playerRect.
        int midPointX= 160, midPointY= 240;
        int PauseRectSize= 68;
        
        playerRectForPauseMenu= CGRectMake(midPointX- PauseRectSize*0.5, 
                                        midPointY- PauseRectSize*0.5, 
                                        PauseRectSize, 
                                       PauseRectSize);

}

-(void)goToPauseMenu
{
    
    //1.Pause the schedulers in the game.
    [self pauseGame];
    
    //Increasing the opacity of the pauseLayer.
        pauseLayer.opacity= 84;
    
    //2.Fade in all the Paused Menu Elements.
    for(CCLabelBMFont *pauseMenuText in [pauseLayer children])
    {
        [pauseMenuText runAction:[CCFadeIn actionWithDuration:0.2f ]];   
    }
    
}

//This method is called from the pause menu,
    //coming back to the main gameplay.
-(void)backToGame
{
    //1.Turn off the Paused Menu Elements.
    for(CCLabelBMFont *pauseMenuText in [pauseLayer children])
    { 
        pauseMenuText.opacity=0;   
    }
    
    //Make the pauseLayer itself invisible.
    pauseLayer.opacity=0;
    
    //2.Restart the schedulers in the game.
    [self restartGame];       
}

#pragma mark Level Cleared

//Replaces the current level scene for a new scene with the next level.
-(void)levelCleared
{
    
    NSLog(@"levelCleared is called.");
    
   if( currentLevel < NUMBER_OF_LEVELS )
   {
       NSLog(@"Going to next level.");
       [[CCDirector sharedDirector] replaceScene:[GameLevel sceneWithLevel:(currentLevel+1)]];   
   }
    
   else
   {
       //Since this is a demo version, 
            //the game returns the player to the Title Screen
            //when all levels are cleared.
       NSLog(@"You finished the game!");
       [[CCDirector sharedDirector] replaceScene:[TitleScreen scene]];       
   } 
}


#pragma mark Initializing Game Objects and Physics Editor Collisions.

//This function calls the setup methods for all the tileMap data.
-(void)setUpGameObjectsWithObjectGroup:(CCTMXObjectGroup *)gameObjectsGroup
{
    int x, y;

    //1. Fetch The Player Ball's spawnPoint.    
        NSDictionary *spawnPointInfo = [gameObjectsGroup objectNamed:@"PlayerStart"];
            x = [[spawnPointInfo valueForKey:@"x"] intValue];
            y = [[spawnPointInfo valueForKey:@"y"] intValue];    
        NSLog(@"retrieved player Ball x, y.");
        [self setUpPlayerBallWithPoint:ccp(x,y)];    
      
    //2. Fetching location information for our Goal.
        NSDictionary *goalPosition = [gameObjectsGroup objectNamed:@"Goal"];
            x = [[goalPosition valueForKey:@"x"] intValue];
            y = [[goalPosition valueForKey:@"y"] intValue];   
        [self setUpGoalWithPoint:ccp(x,y)];  

    //3. Fetching a Key, if any.
        NSDictionary *keyInfo= [gameObjectsGroup objectNamed:@"Key"];
            
            if(keyInfo != nil)
            {
                x = [[keyInfo valueForKey:@"x"] intValue];
                y = [[keyInfo valueForKey:@"y"] intValue];
    
                [self createKeyWithPoint:ccp(x,y)];
            }    

}


//----The setup methods for the main game elements.------

-(void)setUpPlayerBallWithPoint:(CGPoint)ballPosition
{ 
    player = [Ball ballWithWorld:world andPosition:ballPosition];
    
    if(isDebugDrawing)
    {
        [self addChild:player ];    
        [self centerGameCameraToPlayer:player.sprite.position];
    }
        
    else 
    {   
        [gameLayer addChild:player ];    
        [self centerGameLAYERCameraToPlayer:player.sprite.position];  
    } 
    
}

-(void)setUpGoalWithPoint:(CGPoint)goalPosition
{

    myGoal = [Goal goalWithWorld:world andPosition:goalPosition];
    
    if(isDebugDrawing)
        [self addChild:myGoal];    
    else 
        [gameLayer addChild:myGoal];
}

-(void)createKeyWithPoint:(CGPoint)keyPosition
{
    
    myKey = [Key keyWithWorld:world andPosition:keyPosition];
    
    if(isDebugDrawing)
        [self addChild:myKey ];    
    else 
        [gameLayer addChild:myKey];   
}

//Not a setup method, but it's called when a key is collected.
-(void)keyCollected
{
    [myKey keyCollected];   
}

#pragma mark Barrier Functions.

//Barrier setup and management methods.

-(void)createBarriersWithMutableArray:(NSMutableArray*)barriersMutableArray
{   
    int index=0;
    
    for(NSDictionary* barrierInfo in barriersMutableArray)
    {       
        //1. Retrieving Data from Array.
        
            //a. Position
            int x = [[barrierInfo valueForKey:@"x"] intValue];
            int y = [[barrierInfo valueForKey:@"y"] intValue];  
         
            //b. Barrier Type
            NSString* type = [barrierInfo valueForKey:@"name"]; 
            NSNumber* barrierTypeResult = [platformKinds objectForKey:type];

            //c. Trigger to open the Barrier.
            NSString* triggerType = [barrierInfo valueForKey:@"type"]; 
        
            //d. Checking our Orientation Data, if any.
            int barrierOrientation= [self getEntityOrientationID:[barrierInfo valueForKey:@"orientation"]];
        
        //2. Creating our Barrier.
            Barrier* newBarrier= [Barrier barrierWithWorld:world 
                                   andPosition:ccp(x,y) 
                                         andId:index 
                                       andType:[barrierTypeResult intValue]
                                andOrientation:barrierOrientation];
        
        //3. Setting our Barrier's trigger.
            if([triggerType isEqual:@"group"])
            { 
                newBarrier.barrierType= TRIGGER_ENEMY_GROUP_OPENS_BARRIER;
            }
        
            else if([triggerType isEqual:@"key"])
            { 
                //NSLog(@"Barrier setup as a Key Barrier.");
                newBarrier.barrierType= KEY_BARRIER_TYPE;
            }
       
            else
            {
                newBarrier.barrierType= BREAKABLE_BARRIER_TYPE;
            }
        
        //4.adding to GameLevel as a child, and to barriersArray.
            
            if(isDebugDrawing)
                [self addChild:newBarrier];
            else 
                [gameLayer addChild:newBarrier];   
        
            [barriersArray insertObject:newBarrier atIndex:index];
        
            //updating my counter.
                index++;        
    }
  
}


-(void)openBarrierOfType:(int)barrierType
{
    NSLog(@"Opening Barrier.");
    
    for(Barrier *tempBarrier in barriersArray)
    {
        //Assuming there is only one instance of the barrier with that barrierType
        if(tempBarrier.barrierType == barrierType)
        { 
            
            [tempBarrier barrierRemoved];
            NSLog(@"Special Barrier has been removed.");
        }
    }
}

-(void)openBarrierWithId:(int)barrierId
{
    Barrier* tempBarrier= [barriersArray objectAtIndex:barrierId];   
    [tempBarrier barrierBroken];
}

-(void)decreaseCount_ofEnemies_toOpenBarrier
{
    NSLog(@"Enemy barrier count is %d.",numberOfEnemies_beforeBarrierOpened_Count); 
    numberOfEnemies_beforeBarrierOpened_Count--;
    
    if(numberOfEnemies_beforeBarrierOpened_Count==0)
    {    
        NSLog(@"Barrier opened.");
        
        [self openBarrierOfType:TRIGGER_ENEMY_GROUP_OPENS_BARRIER];
        
        [[GameSoundManager sharedManager] playSoundEffect:KEY_SOUND ];
    }
 
}


#pragma mark Physics Editor Level Setup.

//---Method that loads level data from a plist 
    //---created in a Physics Editor.

-(void)loadPlist
{
    
    CGPoint playerStartPosition;
    CGPoint goalPosition;
    
    //Reading plist. Getting path from the app bundle.
        
        NSString *pListPath = [[NSBundle mainBundle] pathForResource:
                      [NSString stringWithFormat:@"Maze%d_objects", currentLevel] ofType:@"plist"];
    
    //Build the array from the plist   
        NSDictionary *pListContents=[NSDictionary dictionaryWithContentsOfFile:pListPath];
    
    //Retrieving values from pList.
        playerStartPosition.x= [[[pListContents objectForKey:@"playerStart"]  objectForKey:@"x"] intValue]; 
        playerStartPosition.y= [[[pListContents objectForKey:@"playerStart"]  objectForKey:@"y"] intValue]; 

        goalPosition.x= [[[pListContents objectForKey:@"goal"]  objectForKey:@"x"] intValue]; 
        goalPosition.y= [[[pListContents objectForKey:@"goal"]  objectForKey:@"y"] intValue]; 

    //Loading ball.
    [self setUpPlayerBallWithPoint:playerStartPosition];    
    
    //Loading goal.
    [self setUpGoalWithPoint:goalPosition];    

}


-(void)setSpecialCollisionWithFile:(NSString*)collisionFileName
{
    
    [[GB2ShapeCache sharedShapeCache] addShapesWithFile:collisionFileName];
    
    //IF USING A CCSPRITE:
   levelSprite= [CCSprite spriteWithFile:[NSString stringWithFormat:@"Maze%d.png", currentLevel]];
       
   
       levelSprite.anchorPoint=ccp(0,0);
       levelSprite.position=ccp(0,0);
   
       [self addChild:levelSprite];
   
   CCSprite* levelSprite2= [CCSprite spriteWithFile:@"testMaze0_1.png"];
   
   
       levelSprite2.anchorPoint=ccp(0,0);
       levelSprite2.position=ccp(591,0);
   
       [self addChild:levelSprite2];
   
    myTileMapHandler.tileMap.anchorPoint=ccp(0,0);
    
    
       CCSprite* degasBackgd= [CCSprite spriteWithFile:@"degas_ballerinas.png"];
           
           degasBackgd.anchorPoint=ccp(0,0);
           degasBackgd.position=ccp(0,0);
           
           [self addChild:degasBackgd z:-1];

    //End of the graphics setup, Setting up the physics body.
        //b2Body 
        b2BodyDef collisionBodyDef;
        collisionBodyDef.type =b2_staticBody ;
        
        collisionBodyDef.position.Set(0, 0);
        //collisionBodyDef.userData = levelSprite;
        b2Body* levelBody= world->CreateBody(&collisionBodyDef);        
        
        //attaching fixtures to Body
        [[GB2ShapeCache sharedShapeCache] 
        addFixturesToBody:levelBody forShapeName:[NSString stringWithFormat:@"Maze%d", currentLevel]];
        
        //setting anchorPoint of the sprite
        [myTileMapHandler.tileMap setAnchorPoint:[
                                    [GB2ShapeCache sharedShapeCache]
                                    anchorPointForShape:[NSString stringWithFormat:@"Maze%d", currentLevel]]];

}


#pragma mark Functions for Scrolling The Stage

//Maintains the camera positioned over the player ball.
    //Used during Debug Mode.


-(void)scrollLevel
{
//1.Get playerVelocity.
    b2Vec2 playerVelocity = player.body->GetLinearVelocity();

    if( ( (playerVelocity.x< -kMinScrollVelocity) || (playerVelocity.x> kMinScrollVelocity) ) ||
       ( (playerVelocity.y< -kMinScrollVelocity) || (playerVelocity.y> kMinScrollVelocity) )   ) 
    {    
        [self centerGameCameraToPlayer:player.sprite.position];
    }
        
}

-(void)centerGameCameraToPlayer:(CGPoint)ballPosition
{
    
    CGPoint nodePosition=self.position;
    
    nodePosition.x= 160- (int)ballPosition.x;
    nodePosition.y= 240- (int)ballPosition.y;
    
    
   [self setPosition:nodePosition];
    
}

//Maintains the camera positioned over the player ball.
    //Used outside of Debug Mode. 
    //it sets the gameLayer's position.    
-(void)centerGameLAYERCameraToPlayer:(CGPoint)ballPosition
{
    CGPoint gameLayerPosition=self.gameLayer.position;
    
    //casting ball Position to int. This seems to help the flickering.
    gameLayerPosition.x= 160- (int)ballPosition.x;
    gameLayerPosition.y= 240- (int)ballPosition.y;
    
    [gameLayer setPosition:gameLayerPosition];  
}



-(void)scrollGameLayer
{ 
    //1.get playerVelocity.
    b2Vec2 playerVelocity = player.body->GetLinearVelocity();

    if( ( (playerVelocity.x< -kMinScrollVelocity) || (playerVelocity.x> kMinScrollVelocity) ) ||
       ( (playerVelocity.y< -kMinScrollVelocity) || (playerVelocity.y> kMinScrollVelocity) )   )
    {    
        [self centerGameLAYERCameraToPlayer:player.sprite.position];  
    }   
    
}

//This method sets up a camera transition whenever the player loses all their health.
    //The ball cracks, and the camera scrolls from the death location,
    //all the way to spawn point at the start of the level.
-(void)scrollCameraToBallSpawnPoint
{
    //1. Unschedule the automatic scrolling.
        //[self unschedule:@selector(scrollLevel:)];
    NSLog(@"Moving the camera");
    
    //get current Ball Point. 
    CGPoint endPoint= ccp( 160- player.spawnPoint.x, 240- player.spawnPoint.y  );    
     
    if(isDebugDrawing)
        [self runAction:[CCSequence actions:
                    [CCMoveTo actionWithDuration:0.7f position:endPoint],

                    [CCCallBlock actionWithBlock:
                     ^{
                         NSLog(@"Running camera move action.");
                        //reschedule the Ball's auto-scrolling.
                         //[self schedule:@selector(scrollLevel:)];
                         //[self resumeSchedulerAndActions];
                         [self restartGame];
                         
                     }], 
                    nil ]  ];
    
    else 
        [gameLayer runAction:[CCSequence actions:
                         [CCMoveTo actionWithDuration:0.7f position:endPoint],
                         
                         [CCCallBlock actionWithBlock:
                          ^{
                              NSLog(@"Running camera move action.");
                              //reschedule the Ball's auto-scrolling.
                              //[self schedule:@selector(scrollLevel:)];
                              //[self resumeSchedulerAndActions];
                              [self restartGame];
                              
                          }],   
                         nil ]  ];
    
}

#pragma mark Returning our gameEntity Orientation ID.

//Used to determine the orientation of platforms, barriers and shooting enemies
    //spawned from tileMap data.
-(int)getEntityOrientationID:(NSString*)orientationString
{
    
    int entityOrientation= DEFAULT_ORIENTATION;    
    
    if([orientationString isEqual:@""])   //Do Nothing if the String is Empty.
    {}
    
    else if([orientationString isEqual:@"upsideDown"])
        entityOrientation= UPSIDE_DOWN_ORIENTATION;
    
    else if([orientationString isEqual:@"facingRight"] || [orientationString isEqual:@"side"] )
        entityOrientation= FACING_RIGHT_ORIENTATION;
    
    else if([orientationString isEqual:@"facingLeft"])
        entityOrientation= FACING_LEFT_ORIENTATION;
     
    return entityOrientation;
    
}


#pragma mark Creating and Running the Platforms 

//Initializes a dictionary that translates 
    //platform constant values into platform image file names.
-(void)mapPlatformDictionary
{
    platformKinds = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithInteger:PLATFORM_SMALL_TYPE], @"platformSmall",
                           
                           [NSNumber numberWithInteger:PLATFORM_MEDIUM_TYPE], @"platformMedium",
                           
                           [NSNumber numberWithInteger:PLATFORM_LONG_TYPE], @"platformLong",
                           
                           [NSNumber numberWithInteger:CIRCLE_SMALL_TYPE], @"circleSmall",
                     
                           [NSNumber numberWithInteger:CIRCLE_MED_TYPE], @"circleMed",
                     
                           [NSNumber numberWithInteger:CIRCLE_HUGE_TYPE], @"circleHuge",
                           
                           [NSNumber numberWithInteger:CROSS_TYPE], @"crossPlatform",
                           
                           [NSNumber numberWithInteger:TRIANGLE_REGULAR_TYPE], @"triangleSmall",

                           [NSNumber numberWithInteger:TRIANGLE_HUGE_TYPE], @"triangleBig",

                            [NSNumber numberWithInteger:SPIKE_STAR_TYPE], @"spikeStar",
                     
                           [NSNumber numberWithInteger:SPIKE_PLATFORM_TYPE], @"spikePlatform",                        
                        
                            [NSNumber numberWithInteger:BROKEN_TILE_BARRIER_TYPE], @"brokenTile", 

                            [NSNumber numberWithInteger:DUMMY_TILE_BARRIER_TYPE], @"dummyTile", 

                           [NSNumber numberWithInteger:WOOD_BARRIER_TYPE], @"woodBarrier", 
                     
                           [NSNumber numberWithInteger:HARD_BARRIER_SMALL_TYPE], @"steelBarrierSmall", 
                     
                           [NSNumber numberWithInteger:CAGE_BARRIER_TYPE], @"goalCage", 
   
                           nil];
}


-(void)addStaticPlatformsWithArray:(NSMutableArray*)platformsMutableArray
{
    
    for(NSDictionary* platformInfo in platformsMutableArray)
    {    
        //1. Getting our static Platform's data.
            //a. Position        
            int x = [[platformInfo valueForKey:@"x"] intValue];
            int y = [[platformInfo valueForKey:@"y"] intValue];  
        
            //b. Platform's Name.
            NSString* platformName=[platformInfo valueForKey:@"name"];  
            
            //c.our Platform Identifier is fetched from the Dictionary.
                NSNumber* platformTypeResult = [platformKinds objectForKey:platformName];
        
                //if no Platform Name is found, then the Type is set to default.
                if(platformTypeResult == nil)
                {
                    platformTypeResult= [NSNumber numberWithInteger:PLATFORM_SMALL_TYPE];   
                }
        
            //d. Checking our Orientation Data, if any.
            int platformOrientation= [self getEntityOrientationID:[platformInfo valueForKey:@"orientation"]];
        
        //2.Create a gameEntity object with the Platform type.  
            gameEntity* platformEntity= [gameEntity newEntity:[platformTypeResult intValue] 
                                                   atPosition:ccp(x,y) 
                                                    withWorld:world
                                               andOrientation:platformOrientation];
        
                //a. No special collision is needed, so a Static Tag is used.
                   
                    platformEntity.sprite.tag= STATIC_PLATFORMS_TAG;
                    platformEntity.entityType= STATIC_PLATFORMS_TAG;
        
        //3.Add Platform to GameLevel.  We're done.        
            if(isDebugDrawing)
                [self addChild:platformEntity];
            else 
                [gameLayer addChild:platformEntity];
          
    }
    
}



-(void)addPolyLinePlatformsWithArray:(NSMutableArray*)platformsMutableArray
{
    //1. Setting an index for later reference of our platform Speeds, Start and End Points.
    int index= 0;
    
    //2. allocing our Moving Platform Data Arrays.
    
        int numberOfPlatforms= [platformsMutableArray count];

        platformSpeedsVector=(CGPoint*) malloc(numberOfPlatforms*sizeof(CGPoint));
        platformStartPointsArray=(CGPoint*) malloc(numberOfPlatforms*sizeof(CGPoint));
        platformEndPointsArray=(CGPoint*) malloc(numberOfPlatforms*sizeof(CGPoint));
    
    for(NSDictionary* platformInfo in platformsMutableArray)
    {
        //3.Getting Platform Info from our Mutable Array
        
            //a. Position
                int x = [[platformInfo valueForKey:@"x"] intValue];
                int y = [[platformInfo valueForKey:@"y"] intValue];  
        
            //b. Getting our Platform Identifier from our Platform Name.
                NSString* platformName=[platformInfo valueForKey:@"name"]; 
                NSNumber* platformTypeResult = [platformKinds objectForKey:platformName];
 
                if(platformTypeResult == nil)
                {
                    //Setting our  platformType by Default.
                    platformTypeResult= [NSNumber numberWithInteger:PLATFORM_SMALL_TYPE];
                }
        
            //c. Checking our Orientation Data, if any.
                int platformOrientation= [self getEntityOrientationID:[platformInfo valueForKey:@"orientation"]];
        
        
                //Debugging the platformOrientation result.
                    //NSLog(@"Platform Orientation is: %d", platformOrientation );
        
            //d. Initializing Movement Data.
                NSString* moveString=(NSString *)[platformInfo objectForKey:@"points"];
                NSMutableArray* movePoints= [[GlobalFunctions myGlobalFunctions] getPointsFromString:moveString];
        
                //aa. Defining Start and EndPos. Switching EndPos with StartPos if necessary.
                    CGPoint tempStartPoint, tempEndPoint;
                    tempStartPoint= ccp(x,y);
                    tempEndPoint= ccpAdd([[GlobalFunctions myGlobalFunctions] getPointFromArray:movePoints], tempStartPoint );        

                //bb. Assigning platform Speed.
                    float platformSpeed=  [[platformInfo valueForKey:@"time"] floatValue];
                    int deltaX= tempEndPoint.x - tempStartPoint.x;
                    int deltaY= tempEndPoint.y - tempStartPoint.y;
        
                //cc.----Setting deltaX and deltaY's sign.
        
                    int deltaXSign= 1;
                    int deltaYSign= 1;
        
                    if(deltaX < 0)
                        deltaXSign= -1;
        
                    if(deltaY < 0)
                        deltaYSign= -1;
        
                //dd.----assigning the platform Speed Vector.
                    if(deltaX == 0)
                        {
                    
                            //NSLog(@"Platform %d has a deltaX of %d, says deltaX is 0.", index, deltaX);
                        
                            platformSpeedsVector[index]= ccp(0, deltaYSign*platformSpeed);
                        
                        }
            
                    else if(deltaY == 0)
                        {
                
                            //NSLog(@"Platform %d has a deltaY of %d, says deltaY is 0.", index, deltaY);
                        
                            platformSpeedsVector[index]= ccp(deltaXSign*platformSpeed, 0);

                        }
        
            
                    else
                    {
                        if(fabsf(deltaX) > fabsf(deltaY))
                        {
                        
                        
                            float speedRatio= fabsf((float)deltaY/(float)deltaX);
                        
                        
                            //NSLog(@"Platform %d has a speed ratio of %f, dX > dY.", index, speedRatio);
                        
                            platformSpeedsVector[index]=ccp(deltaXSign*1*platformSpeed,
                                                        deltaYSign*speedRatio*platformSpeed); 
                        }
                
                        else
                        {
                            float speedRatio= fabsf((float)deltaX/(float)deltaY);

                            //Debugging our speed ratio.
                                //NSLog(@"Platform %d has a speed ratio of %f, dY > dX.", index, speedRatio);

                            platformSpeedsVector[index]=ccp(deltaXSign*speedRatio*platformSpeed,
                                                            deltaYSign*1*platformSpeed);    
                        }
                   
                    }
        
                //ee.------Assigning Start and End Position information and switching if necessary.
                    platformStartPointsArray[index]= tempStartPoint;
                    platformEndPointsArray[index]= tempEndPoint;  
        
                    if(tempStartPoint.x > tempEndPoint.x) 
                        {  
            
                            platformStartPointsArray[index].x= tempEndPoint.x;
                            platformEndPointsArray[index].x= tempStartPoint.x;        
            
                        }
        
                    if(tempStartPoint.y > tempEndPoint.y) 
                        {  
                    
                            platformStartPointsArray[index].y= tempEndPoint.y;
                            platformEndPointsArray[index].y= tempStartPoint.y;        
            
                        }
     

        //Debugging our moving platform attributes we've created:  
            //        NSLog(@"Platform number %d information:", index);
            //        NSLog(@"platformStartPoint is X %f, Y %f", platformStartPointsArray[index].x,
            //                                                   platformStartPointsArray[index].y);
            //        
            //        NSLog(@"platformEndPoint is X %f, Y %f", platformEndPointsArray[index].x,
            //                                                   platformEndPointsArray[index].y);
            //        
            //        NSLog(@"platformSpeedsVector is X %f, Y %f", platformSpeedsVector[index].x,
            //                                                    platformSpeedsVector[index].y);
        
        
//--------END of Moving Platform's Initializing Movement Data-----------------
        
        //4.Create a gameEntity object with the platform type.  
            gameEntity* platformEntity= [gameEntity newEntity:[platformTypeResult intValue] 
                                                   atPosition:ccp(x,y) 
                                                    withWorld:world
                                               andOrientation:platformOrientation];
        
        //5. Assigning an unique tag to our Moving Platform.  
            platformEntity.sprite.tag= index;
            platformEntity.entityType= MOVING_PLATFORMS_TAG;
        
        //6.Finally, add the platformEntity to our GameLevel.  We're done.         
            if(isDebugDrawing)
                [self addChild:platformEntity];
            else 
                [gameLayer addChild:platformEntity];        
        
        //incrementing our index.
            index++;
        
    }     //---End of the polyline platform creation loop.
    
}


-(void)addRotatingPlatformsWithArray:(NSMutableArray*)platformsMutableArray
{
    //0. Preparing an unique id for each Rotating Platform.   
        int index= 0;
    
    //1. allocing our Moving Platform Data Arrays.
        int numberOfPlatforms= [platformsMutableArray count];
        platformRotationSpeedsArray=(float*) malloc(numberOfPlatforms*sizeof(float));
     
    //For each platform in our Mutable Array...
    for(NSDictionary* platformInfo in platformsMutableArray)
    {
        
        //2.Get the our Platform's Data.
        
            //a. Position
            int x = [[platformInfo valueForKey:@"x"] intValue];
            int y = [[platformInfo valueForKey:@"y"] intValue];  
        
            //b. Platform Rotation Speed.
            float rotateSpeed = [[platformInfo valueForKey:@"speed"] floatValue];
        
            //c. Getting a Platform Name string.
            NSString* platformName=[platformInfo valueForKey:@"name"];
        
                    //Fetch a Platform Identifier from the given Platform Name String.
                    NSNumber* platformTypeResult = [platformKinds objectForKey:platformName];
        
                    if(platformTypeResult == nil)
                    {
                        //Setting a default Platform Identifier.
                        platformTypeResult= [NSNumber numberWithInteger:PLATFORM_SMALL_TYPE];
                    }
        
            //d. Checking our Orientation Data, if any.
            int platformOrientation= [self getEntityOrientationID:[platformInfo valueForKey:@"orientation"]];
        
        //3.Create a gameEntity object with the Platform type.  
            gameEntity* platformEntity= [gameEntity newEntity:[platformTypeResult intValue] 
                                                   atPosition:ccp(x,y) 
                                                    withWorld:world 
                                               andOrientation:platformOrientation];
        
        //4. EntityType is set to "Rotating Platforms".
                //and setting an unique Id for this platform.   
                platformEntity.entityType= ROTATING_PLATFORMS_TAG;
                platformEntity.sprite.tag= index;
        
        //5. adding the rotationSpeed to our platformRotationSpeedsArray.    
            platformRotationSpeedsArray[index]=rotateSpeed;
        
        //6.Add rotatingPlatform to our GameLevel.  We're done.          
            if(isDebugDrawing)
                [self addChild:platformEntity];
            else 
                [gameLayer addChild:platformEntity];        
        
            //incrementing our index.
            index++;
          
    } //end of the rotating platform creation loop.
    
}


#pragma mark Creating and Handling Collectibles 

-(void)createCollectiblesArrayWithMutableArray:(NSMutableArray*)collectiblesMutableArray
{
    //setting up our unique counter for each Coin.
    int index=0;
    
    for(NSDictionary* collectibleInfo in collectiblesMutableArray)
        {
            
            //1. Getting our collectibleInfo from the Mutable Array.
                //a. Position
                int x = [[collectibleInfo valueForKey:@"x"] intValue];
                int y = [[collectibleInfo valueForKey:@"y"] intValue];  
            
    
            //2. Creating a new Collectible.
            Collectible* newCollectible= [Collectible collectibleWithWorld:world 
                                                            andPosition:ccp(x,y) 
                                                            andId:index ];
            
            //3. adding Collectible to GameScene as a child, and to the collectiblesArray.
            if(isDebugDrawing)
                [self addChild:newCollectible];
            else 
                [gameLayer addChild:newCollectible];
            
            [collectiblesArray addObject:newCollectible ];
            
            //updating my counter.
            index++;
            
        }
    
}


-(void)ItemCollectedWithId:(int)spriteId
    {
        //NSLog(@"Collecting the Item.");
        //Getting correct Collectible from the fixtureId.
            //calling itemCollected function.    
            Collectible* tempCollectible=(Collectible*)[collectiblesArray objectAtIndex:spriteId];
            [tempCollectible itemCollected];

        //Make the ball gain health.
            [player ballHealead];
    }


#pragma mark Creating and Handling Enemies 

-(void)addStaticEnemiesWithMutableArray:(NSMutableArray*)enemiesMutableArray 
                       andShootersArray:(NSMutableArray *)shootersArray
{ 
    NSLog(@"CREATING ENEMIES.");
    int index=0;
    
//----------1. Looping through the static enemies array.
    if([enemiesMutableArray count] > 0)
        for(NSDictionary* enemyInfo in enemiesMutableArray)
        {
        
        //Getting our static Enemy's data.
            //a. Position
            float x = [[enemyInfo valueForKey:@"x"] floatValue];
            float y = [[enemyInfo valueForKey:@"y"] floatValue];  
            
            //b. Enemy's Trigger.
            NSString* triggerType = [enemyInfo valueForKey:@"type"]; 
        
            Enemy *newEnemy= [Enemy enemyWithWorld:world 
                                andPosition:ccp(x,y) 
                                        andId:index 
                                    andType:ENEMY_FLYBALL_TYPE
                                    andOrientation:DEFAULT_ORIENTATION
                                    ];

            //c.Assigning a unique tag to this Enemy.    
                //newEnemy.sprite.tag= index;
 
            //d. If the Enemy has additional Trigger Data, prepare it!
                if([triggerType isEqual:@"barrier"])
                { 
                    NSLog(@"Barrier Group enemy added.");
                    numberOfEnemies_beforeBarrierOpened_Count++;
                    newEnemy.triggerInfo= TRIGGER_ENEMY_GROUP_OPENS_BARRIER;
                }
        
        //2.adding Enemy to GameLevel as a child, and to our enemiesArray.  
            if(isDebugDrawing)
                [self addChild:newEnemy];
            else 
                [gameLayer addChild:newEnemy];                
        
            [enemiesArray insertObject:newEnemy atIndex:index];

            //updating my counter.
                index++;
        }
    
//-------------.3 Loop through the shooters array 
    numberOfShooters=[shootersArray count];
    
    if(numberOfShooters > 0)
    {      
    //a. load up the BulletManager
        myBulletManager= [BulletManager getBulletManagerWithSize:numberOfShooters andWorld:world];
        
        //adding BulletManager to self.
        if(isDebugDrawing)
            [self addChild:myBulletManager];
        else 
            [gameLayer addChild:myBulletManager];                
                
        int shooterIndex=0;
           
        //prepping our waitTimesArray.
        shooterWaitTimesArray= (float*) malloc(numberOfShooters*sizeof(float));
 
        for(NSDictionary* shooterInfo in shootersArray)
        {
            //1. Getting our Shooter's data.  
        
            //a. Position
            float x = [[shooterInfo valueForKey:@"x"] floatValue];
            float y = [[shooterInfo valueForKey:@"y"] floatValue];  
            
            float waitTime= [[shooterInfo valueForKey:@"wait"] floatValue];
            float bulletSpeed= [[shooterInfo valueForKey:@"speed"] floatValue];

            int shooterOrientation= [self getEntityOrientationID:[shooterInfo valueForKey:@"direction"]];
            
            
            
            //b. Enemy's Trigger.
            NSString* triggerType = [shooterInfo valueForKey:@"type"]; 
            
            
            //c. Creating enemy
            Enemy *shooterEnemy= [Enemy enemyWithWorld:world 
                                       andPosition:ccp(x,y) 
                                             andId:index 
                                           andType:ENEMY_SHOOTER_TYPE
                                            andOrientation:shooterOrientation
                                        ];
            
            //d.Storing Wait Time info.
                shooterWaitTimesArray[shooterIndex]= waitTime;

            
            //dd.Testing Bullets...
                //shooterEnemy.entityType=ENEMIES_TAG;
           
            //e. If the Enemy has additional Trigger Data, prepare it.        
                if([triggerType isEqual:@"barrier"])
                { 
                    
                    NSLog(@"Barrier Group enemy added.");
                    
                    numberOfEnemies_beforeBarrierOpened_Count++;
                    shooterEnemy.triggerInfo= TRIGGER_ENEMY_GROUP_OPENS_BARRIER;
                    
                }
         
          //2.adding shooterEnemy to GameLevel as a child, and to our enemiesArray.
            if(isDebugDrawing)
                [self addChild:shooterEnemy];
            else 
                [gameLayer addChild:shooterEnemy];                
      
            [enemiesArray insertObject:shooterEnemy atIndex:index];


            //3. adding our bullet data that corresponds to this enemy.
            [myBulletManager addBulletGroupDataAt:shooterEnemy.sprite.position
                     withDirection:shooterOrientation
                         andSpeed:bulletSpeed
                            andId:shooterIndex
                          andWorld:world];
         
            //updating my counters.
            index++;
            shooterIndex++;
            
        }//end of the shooter enemy creation loop.
    
    } //end of the shooter enemy setup.
 
}


-(void)addPolyLineEnemiesWithMutableArray:(NSMutableArray*)enemiesMutableArray
{
    
    int index=[enemiesArray count];

    for(NSDictionary* enemyInfo in enemiesMutableArray)
    {    
        int x = [[enemyInfo valueForKey:@"x"] intValue];
		int y = [[enemyInfo valueForKey:@"y"] intValue];  
        NSString* type = [enemyInfo valueForKey:@"name"]; 
        
        //setting the default enemyType.
            int typeToSend=ENEMY_FLYBALL_TYPE;        
        
        if([type isEqual:@"star"])
                typeToSend= SPIKE_STAR_TYPE;
           
        Enemy* newEnemy= [Enemy enemyWithWorld:world 
                                        andPosition:ccp(x,y) 
                                         andId:0 
                                       andType:typeToSend
                                andOrientation:DEFAULT_ORIENTATION];
     
        //Setting tag and entityType information.
            newEnemy.sprite.tag=index;
            newEnemy.entityType=MOVING_ENEMIES_TAG;
        
        //3.adding to self as a child.
        if(isDebugDrawing)
            [self addChild:newEnemy];
        else 
            [gameLayer addChild:newEnemy];        
          
        [enemiesArray insertObject:newEnemy atIndex:index];
        
        //updating my counter.
        index++;
    }
    
}

//Start all the shooters' Shooting Actions, with their respective Wait Times.
-(void)startShootersActions
{
    int startOfShootersIndex= [enemiesArray count]-numberOfShooters;
    
    int waitTimesIndex=0;
    
    for(int index=startOfShootersIndex; index< [enemiesArray count]; index++)
    {
        
        Enemy* shooterEnemy= (Enemy*)[enemiesArray objectAtIndex:index];
        
        [shooterEnemy startBulletAnimationsWithWait:shooterWaitTimesArray[waitTimesIndex]
         andShooterId:waitTimesIndex];
    
        waitTimesIndex++;
        
    }
        
}

//Checking if the ball has hit a shooter enemy.
-(void)checkIfShooterHitWithId:(int)enemyId
{
    if(numberOfShooters>0)
    {    
        //1. Check the enemyId's index.
        int startIndex= [enemiesArray count] - numberOfShooters;
    
        //2. If the Id is within the shooter id's bounds, 
            // then kill all the Bullets in the Bullet Manager for that enemy.    
        if( (enemyId >= startIndex)&& (enemyId < [enemiesArray count]) )
        {
            [myBulletManager killBulletsForShooter:(enemyId-startIndex)];          
        }    
            
    }
    
    //else
        //NSLog(@"GameLevel.mm, checkifShooterHitWithId: there are no Shooters in this Level.");  
}


//Handles enemy and player touches.
-(void)enemyTouchedWithId:(int)spriteId andNormals:(b2Vec2)collisionNormals
{
    
  if(!isEnemyCheckInProgress)  
  {

    isEnemyCheckInProgress= TRUE;  
      
    //NSLog(@"running enemyTouchedWithId for enemy %d",spriteId);
    Enemy* tempEnemy=(Enemy*)[enemiesArray objectAtIndex:spriteId];
    
    id handleEnemyTouch= [CCCallBlock actionWithBlock:
                      ^{                 
                          [tempEnemy handleEnemyTouchWithCollisionNormal:collisionNormals];  
                      }];    
      
    id setBoolean= [CCCallBlock actionWithBlock:
                      ^{ 
                          isEnemyCheckInProgress= FALSE;
                        }];       
      
    [self runAction:[CCSequence actions:handleEnemyTouch, setBoolean, nil]];
      
  }  

}

//Calls the fast kill animation for enemies.
-(void)killEnemyFastWithId:(int)spriteId
{
   
 if (!isEnemyCheckInProgress) 
    {
    //NSLog(@"running killEnemyFastWithId for enemy %d",spriteId);
    Enemy* tempEnemy=(Enemy*)[enemiesArray objectAtIndex:spriteId];
    [tempEnemy enemyKilledFast];
    isEnemyCheckInProgress= FALSE;   
    }    
        
}

#pragma mark gameLoop, Accelerometer and Draw Functions

//This OpenGL draw call is used when debugging the game.
-(void) draw
{
    if(isDebugDrawing)
    {  // Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
        // Needed states:  GL_VERTEX_ARRAY, 
        // Unneeded states: GL_TEXTURE_2D, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
        glDisable(GL_TEXTURE_2D);
        glDisableClientState(GL_COLOR_ARRAY);
        glDisableClientState(GL_TEXTURE_COORD_ARRAY);
        
        world->DrawDebugData();
        
        // restore default GL states
        glEnable(GL_TEXTURE_2D);
        glEnableClientState(GL_COLOR_ARRAY);
        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    }
    
}

//The main game loop.
-(void) gameLoop: (ccTime) dt
{

//1.Stepping the box2d World.    
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(dt, velocityIterations, positionIterations);
    
    
	
//2. After stepping the box2D world, 
    //Update the game logic by checking for changes in box2D elements.
    
    for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL) {
        
            //Synchronize the AtlasSprites position and rotation with the corresponding body
			//CCSprite *myActor = (CCSprite*)b->GetUserData();        
            gameEntity *myEntity= (gameEntity*)b->GetUserData();

            //Checking our moving entities.       
            switch (myEntity.entityType) {

        //Checking for b2Body status changes:
        
        //A. b2Bodies to destroy + bullet status changes.
                case BODY_TO_DESTROY:
                    world->DestroyBody(b);
                    //NSLog(@"Destroyed body of type %d", myEntity.entityType);
                    break;
                
                case BULLET_SET_ACTIVE:   //only Bullets do this.
                    b->SetActive(TRUE);
                    myEntity.entityType= ENEMY_BULLETS_TAG;
                    //myEntity.sprite.visible= YES;                    
                    break;
                    
                case BULLET_SET_INACTIVE:
                {
                    b->SetActive(FALSE);    
                    int shooterIndex=  (int)( ( myEntity.sprite.tag - ( myEntity.sprite.tag% bulletsPerEnemy) ) / bulletsPerEnemy );
                    [myEntity setEntityPosition:myBulletManager.basePositionArray[shooterIndex]];
                }     
                    break;
                                   
        //B. Apply the force of gravity to the Ball element only.           
                case PLAYER_TAG:
                    {
                        //Updating the player Sprite according to the physics body position.
                        myEntity.sprite.position = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
                        myEntity.sprite.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
                        
                        //Push the physics body with a gravity force.
                        b->ApplyForce( ballGravity, b->GetWorldCenter() );           
                    }
                    break;    
                
        //C. Move and Rotate the Platforms according to our parameters.          
                case ROTATING_PLATFORMS_TAG:
                    {
                        //Moving the Sprite according to b2Body. 
                        myEntity.sprite.position = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
                        
                        //rotating the platform.
                        b->SetAngularVelocity(platformRotationSpeedsArray[myEntity.sprite.tag]);                    
                        myEntity.sprite.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());   
                    }
                    break;
                
                
                case MOVING_PLATFORMS_TAG:
                {
                    
                    //NSLog(@"moving the platforms");        
                        int movingActorIndex= myEntity.sprite.tag;
                    
                    //Moving the Sprite according to b2Body.              
                        myEntity.sprite.position = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
                                            
                    //The platforms' b2Bodies will be updated with the help of the
                        //platform speed and position attributes we have created.
                        //First, we check whether the platforms have reached their end point
                            //or start position, at which point we will reverse platform direction.

                    //---X AXIS: checking wether we have to reverse platformSpeed or not.         
                    if(myEntity.sprite.position.x < platformStartPointsArray[movingActorIndex].x)
                        {
                            //reversing platformSpeed
                            //NSLog(@"reversing platform %d speed", movingActorIndex);
                               
                            platformSpeedsVector[movingActorIndex]= 
                            ccpNeg(platformSpeedsVector[movingActorIndex] );
                        }
                    
                    else if(myEntity.sprite.position.x > platformEndPointsArray[movingActorIndex].x)
                        {
                            
                            //reversing platformSpeed
                            //NSLog(@"reversing platform %d speed", movingActorIndex);
                                
                            platformSpeedsVector[movingActorIndex]= 
                            ccpNeg(platformSpeedsVector[movingActorIndex] );
                        }
                    
                    
                    //---Y AXIS: checking whether we have to reverse platformSpeed or not.    
                    else if(myEntity.sprite.position.y < platformStartPointsArray[movingActorIndex].y)
                        {
                            //reversing platformSpeed
                            //NSLog(@"reversing platform %d speed", movingActorIndex);
                            
                            platformSpeedsVector[movingActorIndex]= 
                            ccpNeg(platformSpeedsVector[movingActorIndex] );
                        }
                    
                    else if(myEntity.sprite.position.y > platformEndPointsArray[movingActorIndex].y)
                        {    
                            //reversing platformSpeed
                            //NSLog(@"reversing platform %d speed", movingActorIndex);
                         
                            platformSpeedsVector[movingActorIndex]= 
                            ccpNeg(platformSpeedsVector[movingActorIndex] );   
                        }   
                       
                    //Finally, set the Velocity on the body.
                    b->SetLinearVelocity(b2Vec2(platformSpeedsVector[movingActorIndex].x,
                                                platformSpeedsVector[movingActorIndex].y));                
                      
                }
                  break;
                                  
        //D. Update the bullets.    
                    
                case ENEMY_BULLETS_TAG:
                    {       
                        myEntity.sprite.position = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
                        //I'm not sure why I'm flipping the bullets' rotation here.
                        myEntity.sprite.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());    
                    }                    
                    break;
       
        //E. Default case.             
                default:
                    //Do Nothing.
                    break;
            }
              
        }	//end of the entityType switch stament.

	}       //---end of the elements' b2Body and sprite update.

//4. One last thing: Clamp the Ball's speed to a maximum value.
    b2Vec2 velocity = player.body->GetLinearVelocity();
    float32 speed = velocity.Length();
    
    if (speed > maxVelX) {
        player.body->SetLinearDamping(0.5);
    } else if (speed < maxVelX) {
        player.body->SetLinearDamping(0.0);
    }
    
}   //end of the gameLoop().


//Accelerometer event, fired every time the accelerometer registers a change in movement.
    //(Since the acceloremeter is very sensitive, this event will be fired frequently)
- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{	   
    accelX = (float) acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
    accelY = (float) acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
	
    //Capping our acceleration values.  
    if(accelX< -maxAccelX)
        accelX= -maxAccelX;
    else if(accelX> maxAccelX)
        accelX= maxAccelX;
    
    if(accelY< -maxAccelY)
        accelY= -maxAccelY;
    else if(accelY> maxAccelY)
        accelY= maxAccelY;
    
    //End of capping acceleration values.
        prevX = accelX;
        prevY = accelY;
    
	// To obtain the ball's new Gravity, multiply the accelerometer input by 10.
        //This will amplify the consequences of an accelerometer change.
	ballGravity= b2Vec2( accelX * kConstantX, accelY * kConstantY);
}

#pragma mark Pause and Restart Game methods

-(void)pauseGame
{    
    [self unschedule:@selector(gameLoop:)];   
    [self unschedule:@selector(scrollGameLayer)];
}

-(void)restartGame
{ 
    [self schedule:@selector(gameLoop:)];   
    [self schedule:@selector(scrollGameLayer)];
}


#pragma mark Touch Event Handling

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    
    //0. Getting our touch.
    CGPoint location= [touch locationInView: [touch view]];
    CGPoint touchPoint= [[CCDirector sharedDirector] convertToGL:location];
    
    //NSLog(@"Touch detected at Point: X %f, Y %f.", touchPoint.x, touchPoint.y);
    
    //We will first check what mode the game is in:
        //whether the game is Paused or if it's in the Gameplay mode.  
   if(isInPauseMenu) 
   {
       
       NSLog(@"Touch in the Pause Menu.");
       
       if (  CGRectContainsPoint([backToMenuText boundingBox], touchPoint) )
       {    
           [[CCDirector sharedDirector] replaceScene:[TitleScreen scene]];     
       }
       
       if (  CGRectContainsPoint([continueText boundingBox], touchPoint) )
       {
           [self backToGame];
           isInPauseMenu=FALSE;  
       }
       
       return NO;
   }   
    
   
   else
   {
       //The game is currently running, not paused.
            //Pressing the player ball, located in the center of the screen,
            //Pauses the game and activates the Pause menu.
       if (  CGRectContainsPoint(playerRectForPauseMenu, touchPoint) )
       {
           return YES;
           //This will get processed in the ccTouchEnded method.
       }
    
       else
           return NO;
    
   }
       
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
   //You touched the ball during gameplay, 
    //so you automatically go to Pause Menu.
    NSLog(@"going to Pause Menu.");
    
    [self goToPauseMenu];
    isInPauseMenu=TRUE;
}



//Deallocation method
- (void) dealloc
{

    NSLog(@"deallocing GameLevel.");
    
    //Deleting all our arrays, starting with the 
        //mutable arrays.
    [collectiblesArray release];
    [enemiesArray release];
    [barriersArray release];
       
    //Deleting Movement Data Arrays for Enemies and Platforms.
    //This is done whether there are moving enemies or platform in the level, or not.
        free(platformSpeedsVector);
        free(platformStartPointsArray);
        free(platformEndPointsArray);
    
        free(platformRotationSpeedsArray);
       
    //Emptying the shooterWaitTimesArray IF there are shooters.
    if(numberOfShooters>0)
        free(shooterWaitTimesArray);
    
    
    //Deleting our box2D world.
    delete world;
	world = NULL;
    
    delete contactListener;
    contactListener = NULL;
    	
	if(isDebugDrawing)
        delete m_debugDraw;

	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
