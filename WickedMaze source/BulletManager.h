//
//  BulletManager.h
//  Wicked Maze
//
//  Created by Albith Delgado on 5/28/12.
//  Copyright 2012 __Albith Delgado__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "gameEntity.h"

//This class manages the game's onscreen bullets (and their physical representation also).
    //For this game version, bullets are fired by one kind of enemy,
    //are absorbed by walls, and are hazardous to the player.

@interface BulletManager : CCNode {
    
    int totalNumberOfBullets;
   
//Bullet Object Containers.
    //Holding the bulletSprites in a batch node, for performance gains.    
    CCSpriteBatchNode* bulletsBatch;
    //Holding the bullet gameEntity (including sprites and physics bodies).
    NSMutableArray* bulletsArray;
    
//Position and Speed.    
    //This is a spawnPoint for some of the bullets.
        //One shooter enemy has access to several bullets in the bullet batch.
    CGPoint* basePositionArray; 
    //Each bullet spawn point will have a speed and direction associated to it.
    CGPoint* bulletSpeedsArray;
    
//Bullet Status Arrays.    
    int* currentBulletArray;    
    BOOL* isBulletActiveArray;

    //every bullet runs this animation.
    id bulletSpinAnimation;
}

@property (assign) CGPoint* basePositionArray;
@property (assign) CCSpriteBatchNode* bulletsBatch;

//Constructors
+(id) getBulletManagerWithSize:(int)numberOfShooters andWorld:(b2World*)world;
-(id) allocateBulletManagerWithSize:(int)numberOfShooters andWorld:(b2World*)world;
-(void) initBulletManagerWithSize:(int)numberOfShooters andWorld:(b2World*)world;


-(void) addBulletGroupDataAt:(CGPoint)bulletGroupPosition
             withDirection:(int)bulletGroupDirection
                  andSpeed:(float)bulletGroupSpeed
                       andId:(int)bulletGroupId
                    andWorld:(b2World*)world;


// Methods used by enemies:
-(void)shootNextForEnemy:(int)enemyId;
-(void)increaseCurrentBulletCountForEnemy:(int)enemyId;

//Bullet reset methods:
-(void)killBulletsForShooter:(int)shooterId;
-(void)resetBulletWithId:(int)bulletId;
   





//---------

//for Demo purposes;
//-(void)callBullets;

//old methods, test purposes.
//-(void)shootNext;
//-(void)currentBulletCount_Increased;


//+(id)getBulletsArrayFromBasePoint:(CGPoint)basePoint andWorld:(b2World*)world;
//-(id)createBulletsArrayFromBasePoint:(CGPoint)basePoint andWorld:(b2World*)world;
//-(void)initBulletsArrayFromBasePoint:(CGPoint)basePoint andWorld:(b2World*)world;




@end
