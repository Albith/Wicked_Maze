//
//  MyContactListener.h
//  Wicked Maze
//
//  Created by Ray Wenderlich on 2/18/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

//Note: The following is an Objective C++ class that uses the Box2D library
    //to detect collisions in the physics world.

#import "Box2D.h"
#import <vector>
#import <algorithm>

struct MyContact {
    b2Fixture *fixtureA;
    b2Fixture *fixtureB;

    //Equality operator.
    bool operator==(const MyContact& other) const
    {
        return (fixtureA == other.fixtureA) && (fixtureB == other.fixtureB);
    }
};

//What follows is the C++ class implementation.
class MyContactListener : public b2ContactListener {
    
public:
    std::vector<MyContact> _contacts;

    //Constructor and Destructor.
    MyContactListener();
    ~MyContactListener();
    
    //Collision Event handling functions.
	virtual void BeginContact(b2Contact* contact);
	virtual void EndContact(b2Contact* contact);
	virtual void PreSolve(b2Contact* contact, const b2Manifold* oldManifold);    
	virtual void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse);
    
    //some additional flags.
    bool isContactSoundPlaying;
    bool isMovingSpikeTouched;
    
};
