//
//  TitleScreen.h
//  Wicked Maze
//
//  Created by Albith Delgado on on 1/6/12.
//  Copyright 2012 __Albith Delgado__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

//Title Screen class, which includes the Stage Select mode.

@interface TitleScreen : CCLayer 
{   
    //Title Screen Transition Data.
        CCSprite* backgroundSprite, *blackBackgroundSprite;
        bool areActionsPlayingNow;

    //Stage Select Data
        int currentLevel;
        bool isInStageSelect;
    
        //Menu node and stage select screen elements.
        CCNode* menuNode;
            //Title screen elements.
            CCLabelBMFont* startText, *continueText;
            //Stage select elements.
            CCLabelBMFont *stageNumbers, *backToMainText;
}


// returns a Scene that contains the HelloWorld as the only child
+(id) scene;


//Setup methods.
-(void)prepareIntroActions;
-(void)initTitleScreen;
-(void)initLevelNumbers;

//Navigation methods.
-(void)startGame;
-(void)continueGameWithLevel:(int)levelNumber;
-(void)returnToMainFromStageSelect;
-(void)showLevelNumbers;

//Checking the user selection.
-(void)checkForStageSelectedWithPoint:(CGPoint)touchPoint;


@end
