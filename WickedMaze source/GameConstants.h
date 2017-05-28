//
//  GameConstants.h
//  Wicked Maze
//
//  Created by Albith Delgado on 11/3/11.
//  Copyright 2011 __Albith Delgado__. All rights reserved.
//

//Here we define all the constants used during game setup and gameplay.

#ifndef BallMazeFinal_GameConstants_h
#define BallMazeFinal_GameConstants_h

#import "GameSoundManager.h"

//----Constants used for the menu and stage select. 
    //Note: default iPhone resolution at the time is 320x480.

    const int stageNumberSpacingX = 50;
    const int stageNumberSpacingY = 50;

    const int numberMaxWidth=28;
    const int numberHeight= 35;

    const int stagesPerRow=4;

    const int levelOffsetFor_10plus= 10;

//----Flag for debugging purposes
    #define isDebugDrawing FALSE

    #define PTM_RATIO 32        //Pixels to Meter ratio, used by Box2D
    const int START_LEVEL=1;
    const int NUMBER_OF_LEVELS=5;   //This is a short, prototype version of the game.

//Bullets per Enemy-----
    #define bulletsPerEnemy 3
    #define waitBetweenShots 1 // in seconds

//Ball constants-----

    //Health
    #define maxBallHP 3
    #define coinValue 1

    //Physics constants.
    #define kFilterFactor 0.6f

    #define kConstantX 21
    #define kConstantY 21

    #define maxAccelY 0.6f
    #define maxAccelX 0.7f

    #define maxVelX 9.0f
    #define maxVelY 9.0f

    //Ball behavior constants.
    #define ballAttackedForce 8
    #define minMaxVelocity 4.0      //Used for calculating the force of the ball's pushback.
    #define minEnemyKillVelocity 6      

        //Bullet Collision-Specific Pushback Variables
            #define BULLET_minMaxForceAppliedToBall 4.0f            

        //Pushback related variables.
            #define minMaxForceAppliedToBall 5.0f    //Capping The force that is added to the Ball.
            #define minMaxFastKillVelocity 14.0f
              
                //This value should be between the MinEnemyKill Velocity and the FastKillVelocity
            #define minBarrierBreakVelocity 12.0f 
   
    //---Scrolling variables
        #define kMinScrollVelocity 0.2f   //if the Ball is moving slowly, don't scroll the camera.


//----------------COLLISION HANDLER TAGS:-------------
    //Tags for the Collision Handler.
           //General element descriptors.
            #define STATIC_HAZARDS_TAG 50
            #define STATIC_PLATFORMS_TAG 51
        
            #define ENEMY_BULLETS_TAG 52
            #define ENEMY_SHOOTERS_TAG 57

            #define ENEMIES_TAG 53
            #define MOVING_ENEMIES_TAG 54  //also moved with actions.
                
            #define BREAKABLE_BARRIERS_TAG 55
            #define HARD_BARRIERS_TAG 56   //tags 70 to 100 could be used for hard barriers.

            #define MOVING_PLATFORMS_TAG 60    //spikeStars, movingPlatforms, spikePlatforms
            #define ROTATING_PLATFORMS_TAG 61
        
    //Used in TileMapHandler.mm to differentiate between spikes and normal surfaces.
            #define SPIKES_TAG 70 


//------SPRITE and Entity TYPES:---------------
    //GAME OBJECTS:
        
        #define PLAYER_TAG 1        //a Dynamic Body

        #define GOAL_TAG 2         //all of these are Static and Sensors.
        #define KEY_TAG 3      
        #define COINS_TAG 4  

        #define HIDDEN_OBJECT_TAG 5


    //SPECIAL: 
        #define ENEMY_BULLET_TYPE 7  //This one is a dynamic Body and a Sensor.

    //STATIC OBJECTS:
        //(Static) Enemies, (Static) Platforms and Barriers.


            //ENEMIES:
                #define ENEMY_FLYBALL_TYPE 10
                #define ENEMY_FLYBALL_MOVING_TYPE 40   //Number shifted , next to Moving Platforms.
                #define ENEMY_SHOOTER_TYPE 12

            
            //BARRIERS:
                #define KEY_BARRIER_TYPE 20           //all of these are Static Bodies.
                #define BREAKABLE_BARRIER_TYPE 21

                #define HARD_BARRIER_SMALL_TYPE 22
                #define CAGE_BARRIER_TYPE 23

                #define WOOD_BARRIER_TYPE 24

                #define DUMMY_TILE_BARRIER_TYPE 25
                #define BROKEN_TILE_BARRIER_TYPE 26
    
        
            //EXTRA: Enemies and Barrier triggers.
                //#define TRIGGER_ENEMY_HAS_A_KEY 97
                #define TRIGGER_ENEMY_GROUP_OPENS_BARRIER 28
                #define NO_TRIGGER 29        
    

    //PLATFORMS:
            #define CIRCLE_SMALL_TYPE 11        //These two are probably static platforms.
            #define CIRCLE_MED_TYPE 13         //before used to be 35, 36.
            #define CIRCLE_HUGE_TYPE 15

        //Hazardous Platforms:
            #define SPIKE_STAR_TYPE 30          //The rest of the platforms 
            #define SPIKE_PLATFORM_TYPE 31          //will be defined as Kinematic Bodies for now,
        //---end of Hazardous Platforms---      //even if they don't move.
        
            #define PLATFORM_SMALL_TYPE 32
            #define PLATFORM_MEDIUM_TYPE 33
            #define PLATFORM_LONG_TYPE 34
            

            #define CROSS_TYPE 37

            #define TRIANGLE_REGULAR_TYPE 38
            #define TRIANGLE_HUGE_TYPE 39
       
//---------END OF SPRITE TYPES:--------------------


//--------5.9.2012 ORIENTATION TYPES:

            #define DEFAULT_ORIENTATION 0     //default
            #define UPSIDE_DOWN_ORIENTATION 1   //upside-down
            #define FACING_LEFT_ORIENTATION 2   //(spikes) rotated to the left , -90 degrees.
            #define FACING_RIGHT_ORIENTATION 3  //rotated to the right, +90 degrees.

//--------SOUND EFFECT TYPES:------------------
        #define HURT_SOUND 111
        #define FLOOR_SOUND 112
        
        #define SLOW_KILL_SOUND 113
        #define FAST_KILL_SOUND 114
        #define BALL_BREAK_SOUND 115
        
        #define COIN_SOUND 116
        #define GOAL_SOUND 118
        #define KEY_SOUND  119
        
        #define HARD_BARRIER_SOUND  120
        #define BREAKABLE_BARRIER_SOUND 121
        #define BARRIER_BREAKING_SOUND 122

        #define HIDDEN_ITEM_SOUND 123

        #define BLIP_SOUND 124
        #define START_GAME_SOUND 125

        //Extras
        #define BOUNCY_PLATFORM_SOUND 126
        #define ENEMY_SHOT_SOUND 127

//--------SONGS LIST:--------------------------

        #define JUNGLE_SONG  211
        #define TEST_SONG  212
//        #define SONG_3  213

//------------Box2d Update Loop Constants:-----------------
        //Use these constants to manage+safely delete b2Bodies in the physics simulation.
        #define STAGE_COLLISION -1  //This tag will not be added to the b2Bodies.

        #define BODY_TO_DESTROY -2    
        #define BULLET_SET_INACTIVE -3       //These two are more for the bullets (hope they work)
        #define BULLET_SET_ACTIVE -4

//------End of constants.

#endif
