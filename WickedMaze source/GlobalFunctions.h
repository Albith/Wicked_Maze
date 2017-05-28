//
//  GlobalFunctions.h
//  Wicked Maze
//
//  Created by Albith Delgado on 2/9/12.
//  Copyright (c) 2012 __Albith Delgado__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

//This class contains several helper functions
        //for parsing data and/or creating Box2D bodies.

//It does not need to inherit from cocos2D classes, therefore it inherits from 
        //iOS's NSObject class.

@interface GlobalFunctions: NSObject {
        
}

+ (GlobalFunctions*) myGlobalFunctions;

//Methods used to create cocos2D animations.
-(id)makePolyLineActionsWithPoints:(NSMutableArray*)pointsArray 
                                  speed:(float)velocity 
                            originPoint:(CGPoint)originPoint;
-(id)makeRotationActionWithTime:(int)time;

//Used to parse a Polygon object AND a Polyline object.
-(NSMutableArray *)getPointsFromString:(NSString*)pointsString;
-(CGPoint)getPointFromArray:(NSMutableArray*)pointsArray;



@end

