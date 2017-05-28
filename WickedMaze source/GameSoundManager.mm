#import "GameSoundManager.h"
#import "GameConstants.h"
#import "CDXPropertyModifierAction.h"

//This simple soundManager is based on Lucky Warp's (my previous game) soundManager.
	//It has only 2 channels: one for sound effects, another for a music track.
	//There should be better options around today.

@interface GameSoundManager (PrivateMethods)
-(void) asynchronousSetup;
-(void) preload;
@end

@implementation GameSoundManager

//TODO: modify this method to load the sounds for your game that you want preloaded at start up.
//If you don't preload your sounds there will be a delay before they are played the first time while the sound data
//is loaded to the playback buffer
-(void) preload {
	
	
//NOTE: Added My game's sound effects.	
	
//	//Ball Sounds.	
    [soundEngine_ preloadEffect:@"BallHurt.aif"];		
    [soundEngine_ preloadEffect:@"keyPickup.aif"];
    [soundEngine_ preloadEffect:@"HiddenItemCollect.aif"];
   
//    //Barrier Sounds.    
    [soundEngine_ preloadEffect:@"cowbell.aif"];
    [soundEngine_ preloadEffect:@"hardBarrierHit.aif"];

//    //Extra sounds.
    [soundEngine_ preloadEffect:@"bassString2.aif"];

    
//NOTE: Adding Jose's sounds.
    [soundEngine_ preloadEffect:@"WM_BALL_BOUNCE.aif"];
    [soundEngine_ preloadEffect:@"WM_ballbounce 1.aif"];
    [soundEngine_ preloadEffect:@"WM_BREAK_BARRIER.aif"];
    
    [soundEngine_ preloadEffect:@"WM_COIN_PICK_UP.aif"];
    [soundEngine_ preloadEffect:@"WM_disparos enemigos.aif"];
    [soundEngine_ preloadEffect:@"WM_ENEMY_FIRE.aif"];
    
    [soundEngine_ preloadEffect:@"WM_FAST_KILL.aif"];
    [soundEngine_ preloadEffect:@"WM_LEVEL CLEAR.aif"];
    [soundEngine_ preloadEffect:@"WM_MENU_SELECTION.aif"];
    
    [soundEngine_ preloadEffect:@"WM_selection sound.aif"];
    [soundEngine_ preloadEffect:@"WM_START GAME.aif"];

	NSLog(@"Finished Preloading Audio.");
}	

//Note: This 'fadeOutMusic' method is not used at the moment.
-(void) fadeOutMusic {
    [CDXPropertyModifierAction fadeBackgroundMusic:2.0f finalVolume:0.0f curveType:kIT_SCurve shouldStop:YES];
}	

@synthesize state = state_;
static GameSoundManager *sharedManager = nil;
static BOOL setupHasRun;

+ (GameSoundManager *) sharedManager
{
	@synchronized(self)     {
		if (!sharedManager)
			sharedManager = [[GameSoundManager alloc] init];
		return sharedManager;
	}
	return nil;
}

-(id) init {
	if((self=[super init])) {
		soundEngine_ = nil;
		state_ = kGSUninitialised;
		setupHasRun = NO;
	}
	return self;
}	

-(void) setUpAudioManager {

	state_ = kGSAudioManagerInitialising;
	//Set up the mixer rate for sound engine. This must be done before the audio manager is initialised.
	//For performance Apple recommends having all your samples at the same sample rate and setting the mixer rate to the same value.
	//22050 Hz (CD_SAMPLE_RATE_MID) gives a nice balance between quality, performance and memory usage but you may want to
	//use a higher value for certain applications such as music games.
	[CDSoundEngine setMixerSampleRate:CD_SAMPLE_RATE_MID];

	//Initialise audio manager asynchronously as it can take a few seconds
	//The FXPlusMusicIfNoOtherAudio mode will check if the user is playing music and disable background music playback if 
	//that is the case.
	[CDAudioManager initAsynchronously:kAMM_FxPlusMusicIfNoOtherAudio];	
}

-(void) asynchronousSetup {
	
	[self setUpAudioManager];
	
	//Wait for the audio manager to initialise
	while ([CDAudioManager sharedManagerState] != kAMStateInitialised) {
		[NSThread sleepForTimeInterval:0.1];
	}	
	
	state_ = kGSAudioManagerInitialised;
	//Note: although we are using SimpleAudioEngine this is built on top of the shared instance of CDAudioManager.
	//Therefore it is safe to access the shared instance of CDAudioManager if necessary.
	CDAudioManager *audioManager = [CDAudioManager sharedManager];
	if (audioManager.soundEngine == nil || audioManager.soundEngine.functioning == NO) {
		//Something has gone wrong - we have no audio
		state_ = kGSFailed;
	} else {
		
		//If you are using background music you probably want to do this. Basically it makes sure your background music
		//is paused and resumed properly when the application is resigned and resumed. Without it you will find that
		//music you had paused will restart even if you don't want it to or your music will start playing sooner than
		//you want.
		[audioManager setResignBehavior:kAMRBStopPlay autoHandle:YES];
		
		state_ = kGSLoadingSounds;

		soundEngine_ = [SimpleAudioEngine sharedEngine];
		
		[self preload];
	
		state_ = kGSOkay;
		
	}
}	

-(void) setup {
	
	//Make sure this only runs once
	if (setupHasRun) {
		return;
	} else {
		setupHasRun = YES;
	}	
	
	//This code below is just using the NSOperation framework to run the asynchrounousSetup method in another thread.
	//Note: we do not use asynchronous loading to speed up loading, it is done so other things can occur while the loading
	//is happening. For example display a loading screen to the user.
	NSOperationQueue *queue = [[NSOperationQueue new] autorelease];
	NSInvocationOperation *asynchSetupOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(asynchronousSetup) object:nil];
	[queue addOperation:asynchSetupOperation];
    [asynchSetupOperation autorelease];
	
}

-(SimpleAudioEngine *) soundEngine {

	if (self.state != kGSOkay && self.state != kGSFailed) {
		//The sound engine is still initialising, wait for it to finish up to a max of 10 seconds 
		int waitCount = 0;
		while (self.state != kGSOkay && self.state != kGSFailed && waitCount < 100) {
			[NSThread sleepForTimeInterval:0.1];
			waitCount++;
		}	
	} 
	
	if (self.state == kGSOkay) {
		//We should only use sounds when the state is okay
		return soundEngine_;
	} else {
		//State wasn't okay, so we return nil
		return nil;
	}	

}	


//4.10.2012 playing a Sound Effect.
-(void)playSoundEffect:(int)soundNumber
{
    
    switch(soundNumber) {
        
        //Ball Sounds      
        case HURT_SOUND:
            [self.soundEngine  playEffect:@"BallHurt.aif"];
            break;
            
        case FLOOR_SOUND:
            [self.soundEngine   playEffect:@"WM_BALL_BOUNCE.aif"];
            break;
        
        case BALL_BREAK_SOUND:
            [self.soundEngine   playEffect:@"crystalBreaking.aif"];
            break;    
         
                 
        //Enemy Sounds       
        case SLOW_KILL_SOUND:
            [self.soundEngine   playEffect:@"WM_ENEMY_FIRE.aif"];
            break;
            
        case FAST_KILL_SOUND:
            [self.soundEngine  playEffect:@"WM_FAST_KILL.aif"];
            break;
            
        case ENEMY_SHOT_SOUND:
            [self.soundEngine  playEffect:@"WM_disparos enemigos.aif"];
            break;
            
        
        //Game Object Sounds         
        case COIN_SOUND:
            [self.soundEngine   playEffect:@"WM_COIN_PICK_UP.aif"];
            break;    
            
        case GOAL_SOUND:
            [self.soundEngine   playEffect:@"WM_LEVEL CLEAR.aif"];
            break;     
            
        case KEY_SOUND:
            [self.soundEngine  playEffect:@"keyPickup.aif"];
            break;    
        
        case HIDDEN_ITEM_SOUND:
            [self.soundEngine  playEffect:@"HiddenItemCollect.aif"];
            break;    
        
            
        //Barrier Sounds          
        case HARD_BARRIER_SOUND:
            [self.soundEngine  playEffect:@"hardBarrierHit.aif"];
            break;        
            
        case BREAKABLE_BARRIER_SOUND:
            [self.soundEngine  playEffect:@"cowbell.aif"];  //I could also use the metalDrop sound.
            break;    
         
        case BARRIER_BREAKING_SOUND:
            [self.soundEngine  playEffect:@"WM_BREAK_BARRIER.aif"];
            break;       
         
        
        //Extra Sounds    
        case BOUNCY_PLATFORM_SOUND:
            [self.soundEngine  playEffect:@"bassString2.aif"];
            break; 
            
      
        //Menu Sounds
        case BLIP_SOUND:
            [self.soundEngine  playEffect:@"WM_selection sound.aif"];
            break;    
        
        case START_GAME_SOUND:
            [self.soundEngine  playEffect:@"WM_START GAME.aif"];
            break; 
            
            
        default:
            NSLog(@"GameSoundManager.mm: playSoundEffect(constant) has no argument!");
            break;
    }
    
    
    
}


-(void)playSong:(int)songNumber
{   
    switch(songNumber) {
            
        //There were originally 3 songs planned, only one is being played at the moment.            
        case JUNGLE_SONG:
            [self.soundEngine  playBackgroundMusic:@"WM_JUNGLE_LEVEL.mp3" loop:TRUE];
            break;
            
        case TEST_SONG:
            [self.soundEngine  playBackgroundMusic:@"WM_music with bouncing fx.mp3" loop:TRUE];
            break;
                  
        default:
            NSLog(@"GlobalFunctions.mm: playSong(constant) has no argument!");
            break;
    }
    
}


//End of playing Sounds and Songs.

@end
