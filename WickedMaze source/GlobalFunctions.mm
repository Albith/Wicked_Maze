//
//  GlobalFunctions.mm
//  Wicked Maze
//
//  Created by Albith Delgado on 2/9/12.
//  Copyright (c) 2012 __Albith Delgado__. All rights reserved.
//

#import "GlobalFunctions.h"
#import "GameConstants.h"

@implementation GlobalFunctions

static GlobalFunctions *myGlobalFunctions = nil;

//-----The following are methods for implementing a singleton
    //from an NSObject parent class.

        //Creating the singleton instance of this class.

        + (GlobalFunctions*) myGlobalFunctions {
            if (myGlobalFunctions == nil) {
                myGlobalFunctions = [[super allocWithZone:NULL] init];
                
            }
            return myGlobalFunctions;
        }

        -(id) init
        {
            if( (self=[super init]) ) {
                
            }
            
            return self;
        }

        + (id)allocWithZone:(NSZone *)zone {
            @synchronized(self)
            {
                if (myGlobalFunctions == nil)
                {
                    myGlobalFunctions = [super allocWithZone:zone];
                    return myGlobalFunctions;
                }
            }
            return nil;
        }

        - (id)copyWithZone:(NSZone *)zone {
            return self;
        }

        - (id)retain {
            return self;
        }

        - (NSUInteger)retainCount {
            return NSUIntegerMax;  //denotes an object that cannot be released
        }


        - (id)autorelease {
            return self;
        }

//---End of singleton NSObject code.


//---Method used to create CCSequences of Actions as defined by a Polyline 
    //(a list of several points that are connected, not closed into a shape).
-(id)makePolyLineActionsWithPoints:(NSMutableArray*)pointsArray 
                       speed:(float)velocity 
              originPoint:(CGPoint)originPoint
{

    //Actions will be added here.
    NSMutableArray* actionsArray=[NSMutableArray array];
    
    //Used to calculate distance.
    CGPoint previousPoint= originPoint;
    
    for(int index=1; index<[pointsArray count]; index++)  //The first index returns 0,0: we use the next point.
    {
        
        //1. Get the current point.
        CGPoint currentPoint = [[pointsArray objectAtIndex:index] CGPointValue];

        //The actionsArray will contain a starting point,
            //and will be succeeded by offsets(dx and dy) from the starting point.
        CGPoint resultPoint= currentPoint;
        
        if(index!=1)
            resultPoint=ccpSub(currentPoint, previousPoint);
        
        //3.Create a movement action and add it to the array.
            //Our collection class will hold id's of cocos2D animations
                        id moveAction= [CCMoveBy actionWithDuration:velocity 
                                           position:resultPoint ];
        
            [actionsArray addObject:moveAction];
        
        //4.Update the previousPosition variable.
            previousPoint=currentPoint;
              
    }
    
    //This series of actions is used to create a sequence of movements.
    //We also create a reverse version of the sequence.
        //This way, we can describe an infinitely looping movement sequence.
    id actionsSequence= [CCSequence actionsWithArray:(NSArray*)actionsArray];
    id actionsSequence_rev= [actionsSequence reverse]; 
    
    id finalActionsSequence=[CCRepeatForever actionWithAction:
                             [CCSequence actions:actionsSequence, actionsSequence_rev, nil] ];
    
    //Note: previously tagging this sequence, we're no longer doing this.
        //[finalActionsSequence setTag:polyLine_MOVEMENT_TYPE];
    
    //We return the repeated animation sequence and have a cocos2D object run it.
    return finalActionsSequence;
}   


//This very simple function returns an infinite rotation animation.
-(id)makeRotationActionWithTime:(int)time
{
    return  [CCRepeatForever actionWithAction:
             [CCSequence actions:
              [CCRotateTo actionWithDuration:time angle:180],
              [CCRotateTo actionWithDuration:time angle:360],
              nil]];
}


//This method extracts number data from a string with comma-separated values.
    //These values are extracted from a tileMap XML document,
    //that stores a complex shape or polyline.
-(NSMutableArray *)getPointsFromString:(NSString*)pointsString
{
    NSMutableArray* polygonPointsArray= [NSMutableArray array];
    
    //1. Get components separated by a space. 
        //This will return a list of strings with points(X,Y) separated by a comma.
    NSArray* pointsWithCommas= [pointsString componentsSeparatedByString:@" "];
    int numberOfPoints= [pointsWithCommas count];
    
    //2. Get X and Y components of each point. 
    for(int index=0; index< numberOfPoints; index++)
    {   
        //2a. We get the points  by dividing the two numbers divided by a comma.
            NSArray* twoNumbersString= [[pointsWithCommas objectAtIndex:index] componentsSeparatedByString:@","];
          
        //NSLog(@"Point %d: %@", index, [twoPointsString description]);
        
        //2b. Checking for a negative sign in either of the numbers. 
            NSString* firstValueInString= [twoNumbersString objectAtIndex:0];
            NSString* secondValueInString= [twoNumbersString objectAtIndex:1];
        
        int firstValueMultiplier=1;
        int secondValueMultiplier=1;
        
        //extracting the two integer values from the string.

        if( [firstValueInString characterAtIndex:0] == '-')
        {
            firstValueMultiplier=-1;
            
            firstValueInString =[firstValueInString substringFromIndex:1];
        }
        
        
        if( [secondValueInString characterAtIndex:0] == '-')
        {
            secondValueMultiplier=-1;
            
            secondValueInString =[secondValueInString substringFromIndex:1];
        }
        
        //3. Put these X and Y values into a CGPoint.
            CGPoint currentPoint=ccp( firstValueMultiplier*[firstValueInString intValue],  
                                 secondValueMultiplier*[secondValueInString intValue]*(-1));
                //NOTE: Y values are INVERTED once, 
                //because the tilemaps scale is in reverse (up is negative, down is positive)
        

        //4. Put CGPoint into our return collection class.
        [polygonPointsArray addObject:[NSValue valueWithCGPoint:currentPoint]];    
        
        
    }
    
    return polygonPointsArray;
}

//-------returning single CGPoint from small Array.
    //Used to return the starting point from the pointsArray created above.
-(CGPoint)getPointFromArray:(NSMutableArray*)pointsArray
{
        return [[pointsArray objectAtIndex:1] CGPointValue];
   
}







@end
