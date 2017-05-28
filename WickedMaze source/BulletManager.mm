//
//  BulletManager.m
//  Wicked Maze
//
//  Created by Albith Delgado on 5/28/12.
//  Copyright 2012 __Albith Delgado__. All rights reserved.
//

#import "BulletManager.h"
#import "GameConstants.h"

#define BULLET_SPIN_ANIMATION_TAG 3

@implementation BulletManager

@synthesize basePositionArray, bulletsBatch;

//Class constructors.
+(id)getBulletManagerWithSize:(int)numeberOfShooters andWorld:(b2World *)world
{
    return [[[self alloc] allocateBulletManagerWithSize:numeberOfShooters andWorld:world] autorelease];
}

-(id)allocateBulletManagerWithSize:(int)numeberOfShooters andWorld:(b2World *)world
{

    if ((self = [super init]))
	{
		[self initBulletManagerWithSize:numeberOfShooters andWorld:world];	
	}
	return self;
}

//Initialzing our BulletManager.
-(void)initBulletManagerWithSize:(int)numberOfShooters andWorld:(b2World *)world
{
    NSLog(@"Initializing Bullets.");
    
    //0. Prepare the Manager's attributes. 
        //How many bullets the Manager handles.
        //An array for each Bullet's Active status.
        //The base Position for each bullet group (grouped by shooter enemy).
        //The bulletSpeed for each group is computed.
    
        //Setting the total number of Bullets, before allocating space for the rest of our arrays.
        totalNumberOfBullets= numberOfShooters*bulletsPerEnemy;
        
        //status variable for all bullets.
        isBulletActiveArray=(BOOL*) malloc(totalNumberOfBullets*sizeof(BOOL));
        
        //These arrays hold data for each of the numberOfShooters.
        basePositionArray= (CGPoint*) malloc(numberOfShooters*sizeof(CGPoint));
        bulletSpeedsArray= (CGPoint*) malloc(numberOfShooters*sizeof(CGPoint));
    
        //This shows the current Bullet up for firing -for each shooter-.
        currentBulletArray= (int*) malloc(numberOfShooters*sizeof(int));   
    
    
//1.Prepping ALL our arrays with default values.
    NSLog(@"Populating the BulletManager Data arrays.");

    for(int index=0; index< totalNumberOfBullets; index++)
        {
            //All bullets start out as inactive.
            isBulletActiveArray[index]=FALSE;  

            //The Starting current Bullet for each group is declared.
            currentBulletArray[index]=index*bulletsPerEnemy;

        }
    
//2.Prepare the sprites Batch and Images;
//Attach batch to the class instance.
    CCSprite* images= [CCSprite spriteWithSpriteFrameName:@"shooterBullet0.png"];

    bulletsBatch = [CCSpriteBatchNode batchNodeWithTexture:
                   images.texture];
    
    [self addChild:bulletsBatch];
    
    
//3.Prepare the bulletSpinAnimation to be run by each bullet.
    NSMutableArray *tempFrames = [NSMutableArray array];
    
        for (int i =0 ; i < 2; i++) 
        {
            CCSpriteFrame *frame;
        
            frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                 [NSString stringWithFormat:@"shooterBullet%d.png", i]];
            
            [tempFrames addObject:frame];
        }     
    
        //The animation event.
        id tempSpinAnimation = [CCAnimation animationWithFrames:tempFrames delay:0.2f];   
    
        bulletSpinAnimation = [[CCRepeatForever actionWithAction:
                            [CCAnimate actionWithAnimation:tempSpinAnimation restoreOriginalFrame:NO]] retain];
    
        [bulletSpinAnimation setTag:BULLET_SPIN_ANIMATION_TAG];
    
    
//3.Initialize the array of bullets.
    bulletsArray= [[NSMutableArray alloc] init];
        //The variable assignment will occur in the next function.   

}

#pragma mark Adding Bullet Groups

//This method is called by the GameLevel class.
    //Assigns a bulletGroup to an enemy Shooter type.
-(void) addBulletGroupDataAt:(CGPoint)bulletGroupPosition
               withDirection:(int)bulletGroupDirection
                    andSpeed:(float)bulletGroupSpeed
                       andId:(int)bulletGroupId
                    andWorld:(b2World *)world
{
 
    int currentBulletIndex= bulletGroupId*bulletsPerEnemy;


    //0. Checking that our bulletGroupId (our index) is not out of bounds.
    if(currentBulletIndex > totalNumberOfBullets)
        NSLog(@"BulletManager.mm: addBulletGroupData(): bulletGroupId is too big.");
    
    else 
        {
            NSLog(@"adding bulletGroup  for shooter number %d", bulletGroupId);
        
            //Loop through all bullets assigned to this bulletGroup,
                //and set up their graphics, animation, and physics properties.
            for(int index=currentBulletIndex; index<(currentBulletIndex+bulletsPerEnemy); index++)
            {
        
            //1.
             
                //create new gameEntities of BULLET type
                gameEntity* bulletEntity= [gameEntity newEntity:ENEMY_BULLET_TYPE 
                                             atPosition:bulletGroupPosition 
                                              withWorld:world 
                                         andOrientation:DEFAULT_ORIENTATION];
        
        
                bulletEntity.entityType= BULLET_SET_INACTIVE;
                bulletEntity.sprite.tag= index;
                bulletEntity.sprite.visible=NO;
        
                
                //attach gameEntity.sprite to the bullets Batch.
                [bulletsBatch addChild:bulletEntity.sprite];
                
                //attach this gameEntity to the bulletsArray, in order to keep track of it.
                [bulletsArray insertObject:bulletEntity atIndex:index];
        
                //run the spinning animation on this sprite.
                [bulletEntity.sprite runAction:[[bulletSpinAnimation copy] autorelease]];
        
        
            }   //end of bullet instantiation loop. 
          
        
        //2. Set our data Arrays;   
        
            //Setting the Base Position:
            basePositionArray[bulletGroupId]=bulletGroupPosition;
            
            //Setting the Speed Vector:
            switch (bulletGroupDirection) {
                case FACING_LEFT_ORIENTATION:
                    bulletSpeedsArray[bulletGroupId]= ccp(-1*bulletGroupSpeed, 0);
                    break;
                
                case FACING_RIGHT_ORIENTATION:
                    bulletSpeedsArray[bulletGroupId]= ccp(bulletGroupSpeed, 0);
                    break;    
                
                case UPSIDE_DOWN_ORIENTATION:
                    bulletSpeedsArray[bulletGroupId]= ccp(0, bulletGroupSpeed);
                    break;    
                    
                default:
                    bulletSpeedsArray[bulletGroupId]= ccp(0, -1* bulletGroupSpeed);
                    break;
            }
            
        
        
    }
    
  
}   //----end of addBulletGroup() method.


#pragma mark Base Functions for Shooting Bullets

//This method shoots a bullet from the selected shooter.
-(void)shootNextForEnemy:(int)enemyId
{

            //If the current bullet is active on the game field, do nothing.
            if(isBulletActiveArray[currentBulletArray[enemyId]])
            {
                //NSLog(@"BulletManager.mm: currentBullet #%d for enemyId is already in use.", currentBulletArray[enemyId]);
            }  
            else   
            { 
                //Setting our bullet status to Active.                 
                isBulletActiveArray[currentBulletArray[enemyId]]= TRUE;
                
                //NSLog(@"Bullet %d is being shot.", currentBulletArray[enemyId]);
                
                //Fetch the current bullet.
                    gameEntity* myBullet= [bulletsArray objectAtIndex:currentBulletArray[enemyId]];
            
                //Setting an active body.
                    //This entityType tag is once again set to ENEMY_BULLETS_TAG in the box2d loop.
                    if(myBullet.entityType== BULLET_SET_INACTIVE)
                        myBullet.entityType= BULLET_SET_ACTIVE;
            
                //Play the Spinning Animation and Shoot the Bullet.
                    //and play a sound effect.
            
                [[GameSoundManager sharedManager] playSoundEffect:ENEMY_SHOT_SOUND];
                
                //Here's an example force applied to the bullet.
                //myBullet.body->ApplyLinearImpulse(b2Vec2(-1,0), 
                    //myBullet.body->GetWorldCenter());
                
                //Applying a force to the bullet.
                    myBullet.body->ApplyLinearImpulse(b2Vec2(bulletSpeedsArray[enemyId].x, 
                                                             bulletSpeedsArray[enemyId].y), 
                                                      myBullet.body->GetWorldCenter());
               
                //NSLog(@"Bullet %d is fired. Rotation is %f", index, myBullet.body->GetAngle());
            
                //Setting the current sprite to visible.
                    myBullet.sprite.visible=TRUE;  
                //Increase the current Active Bullet count for the current enemy shooter.
                    [self increaseCurrentBulletCountForEnemy:enemyId];
             
            }
        
}

//Increases the bullet counter for a shooter enemy.
-(void)increaseCurrentBulletCountForEnemy:(int)enemyId
{
    //Check if all bullets have been used once.  If this is the case,
        //set the counter to the first bullet in the group and try using that.
    if(enemyId==0)
    {
        
        if(currentBulletArray[enemyId] >= (bulletsPerEnemy -1))
            currentBulletArray[enemyId]=0;
        
        else currentBulletArray[enemyId]++;
    }
    
    else 
    {
        if( currentBulletArray[enemyId] >= (bulletsPerEnemy*(enemyId+1) -1)  )
            currentBulletArray[enemyId]=enemyId*bulletsPerEnemy ;
        
        else currentBulletArray[enemyId]++;
    }
    
}


//Resetting a bullet once it has hit either the player or a level wall.
-(void)resetBulletWithId:(int)bulletId
{

    //NSLog(@"Bullet %d is reset.", bulletId);
    
    //Fetch the Bullet.
    gameEntity* myBullet= [bulletsArray objectAtIndex:bulletId];
    
    //Make the sprite invisible.
    myBullet.sprite.visible=NO;
    
    //Reset the b2Body's velocity.
    myBullet.body->SetLinearVelocity(b2Vec2(0,0));
    myBullet.body->SetAngularVelocity(0);
    
    //Stop the animation;
    [myBullet.sprite stopActionByTag:BULLET_SPIN_ANIMATION_TAG];
       
    //Make the box2D body inactive.
    myBullet.entityType=BULLET_SET_INACTIVE;
    
    //Lastly, set the bullet as ready to be fired.
    isBulletActiveArray[bulletId]= FALSE;

    //The current Bullet is updated.
    if(bulletId==0)
        currentBulletArray[0]= bulletId;
    else     
        currentBulletArray[ (int)( ( bulletId - ( bulletId% bulletsPerEnemy) ) / bulletsPerEnemy ) ]= bulletId;

}

#pragma mark Kill Bullets

//When an enemy shooter is killed, 
    //all its allocated bullets are updated as follows:
        //their sprites are hidden.
        //their animations are stopped.
        //the bullet's box2D bodies are deleted.
-(void)killBulletsForShooter:(int)shooterId
{
    
    //Loop through the shooter's bulletGroup.
    int lastBullet= (shooterId+1)*bulletsPerEnemy;
    
    for(int index=shooterId*bulletsPerEnemy; index < lastBullet; index++)
    {
        
        //Get the corresponding bullet.
        gameEntity* myBullet= [bulletsArray objectAtIndex:index];
        
            //Make bullet's sprite invisible.
            myBullet.sprite.visible=NO;
    
            //Reset the b2Body's velocity.
            myBullet.body->SetLinearVelocity(b2Vec2(0,0));
            myBullet.body->SetAngularVelocity(0);
        
            //Stop the animation;
            [myBullet.sprite stopActionByTag:BULLET_SPIN_ANIMATION_TAG];
        
            //Make body inactive.
            myBullet.entityType=BODY_TO_DESTROY;
        
            //Lastly, change this bullet's status to inactive.
            isBulletActiveArray[index]= FALSE;
        
    }
    
    //Now the dead shooter's bulletGroup shouldn't be called again.
    
}

//Deallocating this class.
-(void) dealloc
{
    //Freeing the status arrays we declared on initialization.
    free(isBulletActiveArray);
    
    free(basePositionArray);
    free(bulletSpeedsArray);
    free(currentBulletArray);
    
    [bulletsArray release];
	[bulletSpinAnimation release];
    
	[super dealloc];
}

@end
