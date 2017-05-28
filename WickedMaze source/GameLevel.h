//
//  GameLevel.h
//  Wicked Maze
//
//  Created by Albith Delgado on 12/16/11.
//  Copyright __Albith Delgado__ 2011. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"
#import "Ball.h"
#import "Goal.h"

#import "Key.h"
#import "Barrier.h"

#import "Collectible.h"
#import "Enemy.h"

#import "BulletManager.h"

//used for debugging Box2d, displays physics data.
#import "GLES-Render.h"

#import "TileMapHandler.h"
#import "MyContactListener.h"

@class TileMapHandler;


// The main gameplay layer, it coordinates the graphics and physics engines.
    //It loads and manages level assets, and checks for a winning condition.
// It also handles the Pause Menu logic.
@interface GameLevel : CCLayer
{
    //For Debugging
        GLESDebugDraw *m_debugDraw;

    //Elements for the Pause Menu.
        CCLayerColor* pauseLayer;
        CGRect playerRectForPauseMenu;
        CCLabelBMFont *pausedText, *backToMenuText, *continueText;
    
    
     //Game Objects
        //Single-instance objects.
        Goal* myGoal;
        Ball* player;  
        Key* myKey;
    
    
        //Elements with multiple instances are accessed via collection classes.
        NSMutableArray* collectiblesArray;
        NSMutableArray* enemiesArray;
        NSMutableArray* barriersArray;
        
        //Parameters for Bullet Management
            int numberOfShooters;
            float* shooterWaitTimesArray;
   
        //Enemy and Platform Movement Data.
            //a.Back and Forth Movement
            CGPoint* platformSpeedsVector;
            CGPoint* platformStartPointsArray;
            CGPoint* platformEndPointsArray;

            //b. Rotation Movement
            float* platformRotationSpeedsArray;
            
            //c. Enemy Back and Forth Movement.
                //Note: all our enemies are stationary in this game.
                //This movement could be implemented later.
                    //CGPoint *enemyStartPoints;
                    //CGPoint *enemyEndPoints;
        
        //Variables for Accelerometer padding.  
            float prevX, prevY, accelX, accelY;
            b2Vec2 ballGravity;
     
        //Variable used to map platforms and enemies's strings to a constant.
            NSDictionary* platformKinds;

    //Contact Listener instance.
        MyContactListener *contactListener;  

    //Enemy Group Count to open a Barrier.
        int numberOfEnemies_beforeBarrierOpened_Count;
      
    //Barrier data
        bool isBarrierCheckInProgress;

}

//The layer in which gameplay occurs.
@property (nonatomic, retain) CCNode *gameLayer;
//---------

//Important game object instances.
@property (nonatomic) b2World *world;
@property (nonatomic, retain) Ball* player;

//Game Logic variables.
@property (assign) int currentLevel;
@property (assign) BOOL isEnemyCheckInProgress, isInPauseMenu;

//Linking to level management objects.
@property (nonatomic, retain) TileMapHandler* myTileMapHandler;
@property (nonatomic, retain) BulletManager* myBulletManager;


//------Class methods.

// returns a CCScene that contains the GameLevel as the only child
+(GameLevel*) sharedGameLevel;

+(CCScene *) sceneWithLevel:(int)levelNumber;
-(id) initWithLevel:(int)levelNumber;

//5.13.2012 Pause Menu Functions.
    -(void)createPauseMenu;
    -(void)goToPauseMenu;
    -(void)backToGame;
    -(void)endOfDemoReached;

//Takes you to the next level.
    -(void)levelCleared;

//OLD init functions; not being used right now.
    -(void)loadPlist;
    -(void)setSpecialCollisionWithFile:(NSString*)collisionFileName;
//

    -(void)gameLoop:(ccTime)dt;

//Scrolling fuctions
    -(void)scrollLevel;
    -(void)scrollGameLayer;

    -(void)centerGameCameraToPlayer:(CGPoint)ballPosition;
    -(void)centerGameLAYERCameraToPlayer:(CGPoint)ballPosition;

    //Camera is reset when player is respawned.
    -(void)scrollCameraToBallSpawnPoint;

//------Game element initialization methods------

//Major Game Elements are created here.
    -(void)setUpGameObjectsWithObjectGroup:(CCTMXObjectGroup*)gameObjectsGroup;
    -(void)setUpGoalWithPoint:(CGPoint)goalPosition;
    -(void)setUpPlayerBallWithPoint:(CGPoint)ballPosition;
    -(void)createKeyWithPoint:(CGPoint)keyPosition;
    -(void)keyCollected;
    //To do later: add a Hidden Object in the level. 
        //-(void)createHiddenObjectAtPoint:(CGPoint)elementPoint;

//Barriers
    -(void)createBarriersWithMutableArray:(NSMutableArray*)barriersMutableArray;
    -(void)openBarrierOfType:(int)barrierType;  //Used when you don't know the Id of the Barrier.
    -(void)openBarrierWithId:(int)barrierId;    //Used with Breakable Barriers that you touch.
    //Triggering Barrier openings.
    -(void)decreaseCount_ofEnemies_toOpenBarrier;

//Collectibles.
    -(void)createCollectiblesArrayWithMutableArray:(NSMutableArray*)collectiblesMutableArray;
    -(void)ItemCollectedWithId:(int)spriteId;

//Moving Platforms.
    -(void)addStaticPlatformsWithArray:(NSMutableArray*)platformsMutableArray;
    -(void)addPolyLinePlatformsWithArray:(NSMutableArray*)platformsMutableArray;
    -(void)addRotatingPlatformsWithArray:(NSMutableArray*)platformsMutableArray;

        //mapping platform cases.
            -(void)mapPlatformDictionary;   
        //returning Orientation Type.
            -(int)getEntityOrientationID:(NSString*)orientationString;

//Enemies.
    -(void)addStaticEnemiesWithMutableArray:(NSMutableArray*)enemiesMutableArray
                           andShootersArray:(NSMutableArray*)shootersArray;
    -(void)startShootersActions;
    -(void)checkIfShooterHitWithId:(int)enemyId;
    -(void)addPolyLineEnemiesWithMutableArray:(NSMutableArray*)enemiesMutableArray;
    //Handling contact with Enemies.
        -(void)enemyTouchedWithId:(int)spriteId andNormals:(b2Vec2)collisionNormals;
        -(void)killEnemyWithId:(int)spriteId;

//Methods for pausing the schedulers
    -(void)pauseGame;
    -(void)restartGame;

@end
