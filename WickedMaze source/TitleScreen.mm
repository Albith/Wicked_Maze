//
//  TitleScreen.m
//  Wicked Maze
//
//  Created by Albith Delgado on 1/6/12.
//  Copyright 2012 __Albith Delgado__. All rights reserved.
//

#import "TitleScreen.h"
#import "GameLevel.h"
#import "GameSoundManager.h"
#import "GameConstants.h"


@implementation TitleScreen

//Constructor.
+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	TitleScreen *layer = [TitleScreen node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (void) onEnterTransitionDidFinish
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:1 swallowsTouches:YES];
}


// Initializing the TitleScreen instance.
-(id) init
{
	// Always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] )) {
		
        //----setting the class's status variables.        
            areActionsPlayingNow=TRUE;
            isInStageSelect= FALSE;
            currentLevel=1;

		//--First, enabling touches
		    self.isTouchEnabled = YES;
		 
        //0. Stopping the background music if it is being played. 
        if([[GameSoundManager sharedManager].soundEngine isBackgroundMusicPlaying])
            [[GameSoundManager sharedManager].soundEngine stopBackgroundMusic];
         
		//1. Load the game's artwork.
            CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
            [frameCache addSpriteFramesWithFile:@"ballSprites.pv.plist"];		
		
        
        //0. Prepare the titleScreen's menuNode.
            menuNode=[CCNode node];
            menuNode.anchorPoint= ccp(0,0);
            menuNode.position= ccp(0,0);
            [self addChild:menuNode z:2];
        
            [self initTitleScreen];
            [self initLevelNumbers];
            [self prepareIntroActions];
    
	}
	return self;
}

#pragma mark Preparing Menus

//Preparing the Title Screen's elements.
-(void)initTitleScreen
{
    //1.Loading Background Graphic. 
        backgroundSprite= [CCSprite spriteWithFile:@"NewTitleScreenPic_FromIcon.png"];
        backgroundSprite.anchorPoint= ccp(0,0);
        [self addChild:backgroundSprite];
        
    
    //2.Loading a Black Background to fade out of.
        blackBackgroundSprite = [CCSprite node];
        [blackBackgroundSprite setTextureRect:CGRectMake(0, 0, 320,480)];
        [blackBackgroundSprite setColor:ccBLACK];
        [blackBackgroundSprite setAnchorPoint:ccp(0,0)];
            
        [self addChild:blackBackgroundSprite];
    
    //3.Loading The 'Start' Text.
        startText= [CCLabelBMFont labelWithString:@"start" fntFile:@"GlyphsForDemo.fnt"];
        startText.scale= 1.1;
        startText.position=ccp(170,310);
        startText.opacity= 0;
        //enlarging the StartText Area:
        [startText setContentSize:
        CGSizeMake( startText.contentSize.width*1.3f, startText.contentSize.height*1.3f )];
        
        [menuNode addChild:startText];
    
    
    //3.Loading The 'Continue' Text.
        continueText= [CCLabelBMFont labelWithString:@"continue" fntFile:@"GlyphsForDemo.fnt"];
        continueText.scale= 1.1;
        continueText.position=ccp(190,240);
        continueText.opacity= 0;
    
        [menuNode addChild:continueText];
    
        //enlarging the StartText Area:
        [continueText setContentSize:
         CGSizeMake( continueText.contentSize.width*1.3f, continueText.contentSize.height*1.3f )]; 
}

-(void)prepareIntroActions
{

//Define the following actions:
    //Run the FadeOutBLTiles action for the blackBackground.
    //Lower the opacity for the background.
    
    id runFadeInAction= [CCCallBlock actionWithBlock:
                         ^{
                             [blackBackgroundSprite runAction:[CCFadeOutBLTiles actionWithSize:ccg(16,12) duration:2.5f] ];                   
                         }];
    
    id setBackgdOpacityAction= [CCCallBlock actionWithBlock:
                        ^{
                            backgroundSprite.opacity=255;          
                            blackBackgroundSprite.visible=FALSE;              
                        }];
    
    //Unlock the UI for touches.
    id unlockUIAction= [CCCallBlock actionWithBlock:
                        ^{
                            areActionsPlayingNow=FALSE;
                            
                        }];
    
    //Fade in the titleScreen text.
    id fadeInTextsAction= [CCCallBlock actionWithBlock:
                           ^{
                            NSLog(@"Fading in Titles...");
                            [startText runAction:[CCFadeIn actionWithDuration:0.3f]];  
                            [continueText runAction:[CCFadeIn actionWithDuration:0.3f]];   
                           }];
    
    
    //Run the sequence that contains the actions we've declared.
    [startText runAction:[CCSequence actions: 
                          
                          runFadeInAction,
                          
                          [CCDelayTime actionWithDuration:2.5f],
                          
                          setBackgdOpacityAction,
                          
                          [CCDelayTime actionWithDuration:0.1f],
                             
                          fadeInTextsAction,
                          unlockUIAction,
                          
                          nil]];

}



-(void)initLevelNumbers
{
    
    NSLog(@"Preparing Level Numbers.");
        
//2a.put Stage Select title.    
    backToMainText= [CCLabelBMFont labelWithString:@"back" fntFile:@"GlyphsForDemo.fnt"];
    backToMainText.position=ccp(160, -30);   //Originally Y was 450, but substracting the screen Height= -30.
    backToMainText.opacity=0;

    [menuNode addChild:backToMainText];
    

//2b.create CCLabelBMFont with all the Stage Numbers.
    NSMutableString* tempString= [NSMutableString string];
     
    //Note: level select numbers will be created only up to the current level of play.
    for(int stageNumber=1; stageNumber<=NUMBER_OF_LEVELS; stageNumber++) 
    {  
        [tempString appendString:[NSString stringWithFormat:@"%d", stageNumber]];   
    }
    
    stageNumbers= [CCLabelBMFont labelWithString:tempString fntFile:@"GlyphsForDemo.fnt"];
    
    stageNumbers.anchorPoint=ccp(0,0);
    stageNumbers.position=ccp(0,0);
    stageNumbers.opacity=0;
    
    [menuNode addChild:stageNumbers];
    //The (stage select?) title has a 30 pixel border on the sides 
        //and a 58 pixel border from the top.
    
//3.formatting the Numbers to be displayed in a CCLabelBMFont.
    //numbers have an __ pixel border on the sides
    //a __ pixel horizontal gap,
    //and a ___ pixel vertical gap, between each other.
    
    CGPoint startPoint=ccp(30, -130); 
    
    int spriteCount = 0; 
    CGPoint currentPoint;
    
    while (spriteCount<[[stageNumbers children] count])
    {
        //Displaying the level numbers for levels 1-5.
        if(spriteCount < 9)
        {
            currentPoint=ccp( startPoint.x + (numberMaxWidth + stageNumberSpacingX)*(spriteCount%stagesPerRow ) , 
                             startPoint.y - (numberHeight + stageNumberSpacingY)*(int)((spriteCount-spriteCount % stagesPerRow)/stagesPerRow)           
                             );
                      
            CCSprite * tempSprite= (CCSprite*)[stageNumbers getChildByTag:spriteCount];
            
            tempSprite.anchorPoint=ccp(0,0);
            tempSprite.position= currentPoint;
            
            //1.enlarging the bounding box for the level numbers.  
            [tempSprite setContentSize:
             CGSizeMake( tempSprite.contentSize.width*1.5f, tempSprite.contentSize.height*1.5f )];
            
            //NSLog(@"Bounding box for level %d is ay X %f, Y %f ", spriteCount, tempSprite.contentSize.);
             
            spriteCount++;    
        }
        
        else
        {
            //This is a workaround for positioning certain level numbers (10 and over).     
            //However, since the prototype only has 5 levels, 
                //this code is not executed.       
            if((spriteCount==15) || (spriteCount==16))
                currentPoint.y=startPoint.y - (numberHeight + stageNumberSpacingY)*3;              
            else
                currentPoint.y= startPoint.y - (numberHeight + stageNumberSpacingY)*(int)((spriteCount-spriteCount % (stagesPerRow*2))/(stagesPerRow*2) +1);
            
            //1.Modified this , in the X coordinate spriteCount is NOT substracted by 1.
                currentPoint=ccp( startPoint.x + (numberMaxWidth + stageNumberSpacingX)*(((spriteCount+1)%(stagesPerRow*2))/2) , 
                                currentPoint.y
                                );
                
                CCSprite * tempSpriteA= (CCSprite*)[stageNumbers getChildByTag:spriteCount];
                CCSprite * tempSpriteB= (CCSprite*)[stageNumbers getChildByTag:(spriteCount+1)];
            
            //2.These number sprites should stick together. 
                tempSpriteA.anchorPoint=ccp(0,0);
                tempSpriteB.anchorPoint=ccp(0,0);
            
            //3.tuning opacity            
                tempSpriteA.position= ccp(currentPoint.x-numberMaxWidth + levelOffsetFor_10plus, 
                                        currentPoint.y );
                
                tempSpriteB.position= ccp(levelOffsetFor_10plus + currentPoint.x, 
                                        currentPoint.y);
                
                NSLog(@"Enlarged bounding box for level %d", spriteCount);
                
                spriteCount+=2;
                            
            //4.enlarging the bounding box for the sprites.
            [tempSpriteA setContentSize:
                CGSizeMake( tempSpriteA.contentSize.width*1.5f, tempSpriteA.contentSize.height*1.5f )];

            [tempSpriteB setContentSize:
                CGSizeMake( tempSpriteB.contentSize.width*1.5f, tempSpriteB.contentSize.height*1.5f )];
            
        }
          
    }

    //Old code for positioning the menuNode offScreen, 
    //ready to be scrolled into display. 
        //menuNode.position= ccp(0, -480);
        //menuNode.visible= false;
}

#pragma mark Menu Logic

-(void)showLevelNumbers
{
    NSLog(@"Showing the level numbers.");
        
    //1. Make LevelNumbers and Back button visible.
        backgroundSprite.opacity=50;
        backToMainText.opacity=255;
        stageNumbers.opacity=255;
        
    //2. Shift the Stage Select Menu into view (originally offscreen, below).
        [menuNode runAction:[CCMoveBy actionWithDuration:0.6f position:ccp(0, 480)]];
}

-(void)returnToMainFromStageSelect
{
    
    //This function performs the opposite of 'Show Level Numbers'.

    //The sequence consists of: shifting the screen up, 
        //followed by hiding the level number sprites,
        //updating the menu logic, and showing the titleScreen text.
    id shiftScreenUpAction= [CCMoveBy actionWithDuration:0.6f position:ccp(0, -480)];

    id revertToTitleAction= [CCCallBlock actionWithBlock:
                                  ^{
                                      backgroundSprite.opacity= 255;                                      
                                      backToMainText.opacity=0;
                                      stageNumbers.opacity=0;                                      
                                      isInStageSelect= false;                                 
                                  }];
    
    [menuNode runAction:[CCSequence actions:shiftScreenUpAction, 
                                            revertToTitleAction, 
                                            nil]];
    
}


//Launches the game at the first level.
    //Note:currentLevel always remains at 1. Since this is a demo, there is no
    //saved data.  To start at a later level, go to the stage select.
-(void)startGame
{
    id blinkLevelString= [CCBlink actionWithDuration:1.7f blinks:10];
    
    id launchGame= [CCCallBlock actionWithBlock:
                    ^{
                        [[CCDirector sharedDirector] replaceScene:[GameLevel sceneWithLevel:(currentLevel)]];
                    }];
        
    [startText runAction:[CCSequence actions: blinkLevelString, launchGame, nil]];
}

//Launches the game at a certain level, selected from the stage select.
-(void)continueGameWithLevel:(int)levelNumber
{  
    
    id launchGame= [CCCallBlock actionWithBlock:
                    ^{
                        [[CCDirector sharedDirector] replaceScene:[GameLevel sceneWithLevel:levelNumber]];
                    }];

    [self runAction:[CCSequence actions: [CCDelayTime actionWithDuration:0.4f], launchGame, nil]];

    //an Alternate way of running this sequence, 
        //with a blinking string to signify that a level has been selected.
            //id blinkLevelString= [CCBlink actionWithDuration:1.7f blinks:10];
            //[startText runAction:[CCSequence actions: blinkLevelString, launchGame, nil]];

}


#pragma mark Touch Event Handling

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    
    //0. Getting our touch.
        CGPoint location= [touch locationInView: [touch view]];
        CGPoint touchPoint= [[CCDirector sharedDirector] convertToGL:location];
    
    //First we determine which menu we are interacting with.
        //After this, we handle our touches according to the element touched.

  //Only processing touches if there aren't any animated sequences playing.
  if(!areActionsPlayingNow)
  {    

    if(!isInStageSelect)
        {
            //The player is in the main Title Screen.
            if ( CGRectContainsPoint([startText boundingBox], touchPoint) )
            {
                //The Start button was pressed. We go directly to the first level.
                    [[GameSoundManager sharedManager] playSoundEffect:START_GAME_SOUND];
                    [self startGame];
            
                    return YES;
            }
    
        else if ( CGRectContainsPoint([continueText boundingBox], touchPoint) )
            {
          
                //The Continue button was pressed. We go to the stage select.
          
                    [[GameSoundManager sharedManager] playSoundEffect:BLIP_SOUND];
                    [self showLevelNumbers];
                    isInStageSelect=TRUE;
          
                    return YES;
            } 
      
        }    
            
      else   
        {
          //The player is already in the Stage Select area, detect touches inside:

          //First, we need to shift our touch point by a full screen's worth
              //(the iPhone's screen height at this time is 480px. 
          //Substract that amount from the current point.
            touchPoint= ccpAdd(touchPoint, ccp(0, -480));
            
            
            //Check if the user pressed the back button?
            if ( CGRectContainsPoint([backToMainText boundingBox], touchPoint) )
            { 
                //The start button was pressed. We go back to the main menu.
                [[GameSoundManager sharedManager] playSoundEffect:BLIP_SOUND];
                [self returnToMainFromStageSelect];
                
                return YES;  
            }
            
            
            //Check if the player pressed any of the stage numbers.
            else
            {                
                NSLog(@"Checking for stages...");
                [self checkForStageSelectedWithPoint:touchPoint];
            }
             
        }   //End of the touch handling inside the stage select mode.
      
  } //End of all the touch handling code. 

          return NO;
}

//Checking user input in the stage select mode.
-(void)checkForStageSelectedWithPoint:(CGPoint)touchPoint
{
    
    int numberCount = 0; 
    int levelToGoTo= 1;
    
    int howManyStagesToCheck;
    
    //if(allLevelsUnlocked)   //check for All stages if we're in Debug mode.
        howManyStagesToCheck= [[stageNumbers children] count];
    //else
      //  howManyStagesToCheck= howManyNumberSpritesToShow;
    
    while (numberCount< howManyStagesToCheck )
    {
        
        
        if(numberCount < 9)
        {
            
            CGRect numberRect= [stageNumbers getChildByTag:numberCount].boundingBox;
            
            if(CGRectContainsPoint(numberRect, touchPoint) )
            {
                NSLog(@"Touched numberSprite %d and going to level %d", numberCount, levelToGoTo);
                
                                
                [self continueGameWithLevel:levelToGoTo];
                
                [[GameSoundManager sharedManager] playSoundEffect:START_GAME_SOUND];

                
                break;
                
            }
            
            else
            {
                numberCount++;
                levelToGoTo++;
            }
            
        }
        
        else 
        {
            
            CGRect numberRectA= [stageNumbers getChildByTag:numberCount].boundingBox;
            CGRect numberRectB= [stageNumbers getChildByTag:(numberCount+1)].boundingBox;
            
            
            if ( (CGRectContainsPoint(numberRectA, touchPoint) ) || (CGRectContainsPoint(numberRectB, touchPoint) )    )
            {
                
                NSLog(@"Touched numberSprite(s) #%d", numberCount);
                
                
                [self continueGameWithLevel:levelToGoTo];
                
                [[GameSoundManager sharedManager] playSoundEffect:START_GAME_SOUND];

                
                
                break;
                
            }
            
            
            else
            {
                numberCount+=2;
                levelToGoTo++;
            }    
        }
        
        
        
    }
    
    
}

// On "dealloc" we release all our retained objects
- (void) dealloc
{
    [[CCDirector sharedDirector] purgeCachedData];    
	// don't forget to call "super dealloc"
	[super dealloc];
}

@end
