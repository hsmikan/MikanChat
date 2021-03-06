//
//  MCReadManager.m
//  MikanChat
//
//  Created by hsmikan on 8/9/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//


#import "MCReadManager.h"
#import "../MCUserDefaultsKeys.h"
#import "../NSString/NSString+MCConverter.h"
#import "../NSString/NSString+MCRegex.h"
#import "../SoundDevice/MCSoundDevice.h"

#import "../Yukkuroid/YukkuroidRPCClinet.h"


//
// read queue
//
#define kMCReadQueueLimit 10
#define kMCReadInterval 0.8

//
// Reading System Path
//
#define kSayKotoeri2Path @"/usr/local/bin/SayKotoeri2"
#define kSayKanaPath		@"/usr/local/bin/SayKana"
#define kSayKotoeriPath  @"/usr/local/bin/SayKotoeri"


//
// Reading System Names for display
//
#define kMCSKName @"SayKotoeri"
#define kMCSK2Name @"SayKotoeri2"
#define kMCKyokoName @"Kyoko"
#define kMCYukkuroidName @"Yukkuroid"


//
// NSSound
//  Temporary sound file path
//
#define kTMPSNDPATH @"/tmp/mc_read_sound.aiff"


//
// reading information Dictionary's key
//
#define kReadIsYukkuroidKey @"isYukkuroid"
#define kMCYukkuroidReadStringsKey @"yukkuroidStrings"

#define kReadCommandKey @"readCommand"
#define kReadVolumeKey kMCReadModeVolumeKey
#define kReadDeviceIndexKey kMCReadModeDeviceIndexKey
#define kReadSpeedKey kMCReadModeSpeedKey
#define kReadPhontIndexKey kMCReadModePhontIndexKey
#define kReadSystemIndexKey kMCReadModeSystemIndexKey



#pragma mark -
#pragma mark Private Like Method
/*==============================================================================
 *
 *  private like methods
 *
 *==============================================================================*/
@interface MCReadManager () <NSSoundDelegate>
NSArray * MC_PRIVATE_METHOD_PREPEND(readSystemNameList)();
- (void)MC_PRIVATE_METHOD_PREPEND(playInNewThread);
- (void)MC_PRIVATE_METHOD_PREPEND(playTerminal);
@end




@implementation MCReadManager

#pragma mark -
#pragma mark Singleton
/*==============================================================================
 *
 *  Singleton Instance
 *
 *==============================================================================*/
static MCReadManager    *   _sharedInstance =   nil;
static NSArray          *   _readSystemList =   nil;
static NSMutableArray   *   _readQueue      =   nil;
static BOOL                 _isPlaying      =   NO;



/*==============================================================================
 *
 *  Singleton Pattern
 *
 *==============================================================================*/
//
// deallocate
//
+ (void)sharedDictionaryWillClose:(NSNotification *)notification {
    RELEASE(_sharedInstance);
    RELEASE(_readQueue);
    RELEASE(_readSystemList);
}


//
// initializing
//
+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        _sharedInstance = [super allocWithZone:zone];
        if (_sharedInstance) {
            //
            // Initialize here...
            //
            _readQueue = [[NSMutableArray alloc] init];
            _readSystemList = [[NSArray alloc] initWithArray:MC_PRIVATE_METHOD_PREPEND(readSystemNameList)()];
        }
        return _sharedInstance;
    }
    return nil;
}


+ (MCReadManager *)sharedReader {
    @synchronized(self) {
        if (_sharedInstance == nil) {
            [[self alloc] init];
            NSNotificationCenter * ntc = [NSNotificationCenter defaultCenter];
            [ntc addObserver:self selector:@selector(sharedDictionaryWillClose:)
                        name:NSApplicationWillTerminateNotification object:NSApp];
        }
    }
    
    return _sharedInstance;
}



- (id)copyWithZone:(NSZone *)zone   { return self; }
- (id)retain                        { return self; }
- (NSUInteger)retainCount           { return UINT_MAX; }
- (oneway void)release              { return; }
- (id)autorelease                   { return self; }





#pragma mark -
#pragma mark Get Reading System
/*==============================================================================
 *
 *  reading system
 *
 *==============================================================================*/
- (NSArray*)readSystemNameList {
    return _readSystemList;
}

- (NSArray *)readSystemNameListByReload {
    RELEASE_NIL_ASSIGN(_readSystemList)
    _readSystemList = [[NSArray alloc] initWithArray:MC_PRIVATE_METHOD_PREPEND(readSystemNameList)()];
    return [self readSystemNameList];
}


NSArray * MC_PRIVATE_METHOD_PREPEND(readSystemNameList)() {
    NSMutableArray * systems = [[NSMutableArray alloc] init];
    
    // SayKotoeri
    if ([[NSFileManager defaultManager] fileExistsAtPath:kSayKanaPath]
        &&
        [[NSFileManager defaultManager] fileExistsAtPath:kSayKotoeriPath])
    {
        [systems addObject:kMCSKName];
    }
    
    // SayKotoeri2
    if ([[NSFileManager defaultManager] fileExistsAtPath:kSayKotoeri2Path])
        [systems addObject:kMCSK2Name];
    
    
    // Kyoko - OS 10.7 or later -
    NSString * OSVer = [[NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"] objectForKey:@"ProductUserVisibleVersion"];
    NSArray * OSVerSplited = [OSVer componentsSeparatedByString:@"."];
    if ([[OSVerSplited objectAtIndex:0] integerValue]>=10
        &&
        [[OSVerSplited objectAtIndex:1] integerValue] >= 7)
    {
        for (NSString * item in [NSSpeechSynthesizer availableVoices]) {
            if ([item rangeOfString:@"kyoko"].location != NSNotFound){
                [systems addObject:kMCKyokoName];
                break;
            }
        }
    }
    
    
    // Yukkuroid
    if ( [YukkuroidRPCClinet getVersion]/* != nil*/ ) {
        [systems addObject:kMCYukkuroidName];
    }
    
    
    return [systems autorelease];
}


- (NSString*)systemNameAtIndex:(NSUInteger)index {
    if ( _readSystemList.count-1 < index ) return nil;
    return [_readSystemList objectAtIndex:index];
}


- (BOOL)isYukkuroidAtIndex:(NSUInteger)index {
    if ( COMPARESTRING([self systemNameAtIndex:index],kMCYukkuroidName) )
        return YES;
    else return NO;
}




#pragma mark -
#pragma mark Get Phont List
/*==============================================================================
 *
 *  phont
 *
 *==============================================================================*/

- (NSArray*)phontsBySystemIndex:(NSUInteger)index {
    if ( _readSystemList.count-1 < index ) return nil;
    
    NSString * systemName = [_readSystemList objectAtIndex:index];
    
    if ( COMPARESTRING(systemName, kMCKyokoName) || !systemName.length)
        return nil;
    
    if ( COMPARESTRING(systemName, kMCSK2Name) ) {
        NSString *phonts;
		{
            NSTask *task = [[NSTask alloc] init];
            NSPipe *pipe = [[NSPipe alloc] init];
            
            [task setLaunchPath:kSayKotoeri2Path];
            [task setArguments:[NSArray arrayWithObject:@"-c"]];
            
            [task setStandardOutput:pipe];
            
            [task launch];
            [task waitUntilExit];
            
            NSFileHandle *handle = [pipe fileHandleForReading];
            NSData       *data   = [handle readDataToEndOfFile];
            phonts = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
            
            [task release];
            [pipe release];
		}
        
        NSArray * phontsList = [phonts componentsSeparatedByString:@"\n"];
        return [phontsList subarrayWithRange:NSMakeRange(0, phontsList.count-2)];
    }
    else if ( COMPARESTRING(systemName, kMCSKName) ) {
        return [NSArray arrayWithObjects:@"女声", @"男声", nil];
    }
    else if ( COMPARESTRING(systemName, kMCYukkuroidName) ) {
        return [YukkuroidRPCClinet voices];
    }
    
    return nil;
}


- (NSString*)phontNameAtIndex:(NSUInteger)index systemIndex:(NSUInteger)systemIndex{
    return [[self phontsBySystemIndex:systemIndex] objectAtIndex:index];
}




#pragma mark -
#pragma mark Reader
/*==============================================================================
 *
 *  Read
 *
 *==============================================================================*/
- (NSString *)MC_PRIVATE_METHOD_PREPEND(createCommandString):(NSString *)message modeProperty:(NSDictionary *)property {
    NSMutableString * ret = [NSMutableString string];
    
    MCReadManager * reader = [MCReadManager sharedReader];
    NSUInteger speed = [[property objectForKey:kReadSpeedKey] integerValue];
    
    NSUInteger systemNameIndex= [[property objectForKey:kReadSystemIndexKey] integerValue];
    NSString * systemName = [reader systemNameAtIndex:systemNameIndex];
    
    NSUInteger phontIndex  = [[property objectForKey:kReadPhontIndexKey] integerValue];
    NSString * phontName = [reader phontNameAtIndex:phontIndex systemIndex:systemNameIndex];
    
    
#define IF_MCSystemCheck(NAME) if (COMPARESTRING(systemName,(NAME)))
    
    IF_MCSystemCheck(kMCSK2Name) {
		[ret appendString:kSayKotoeri2Path];
		if (speed)      [ret appendFormat:@" -s %ld ",speed];
		if (phontName)  [ret appendFormat:@" -p %@ ",phontName];
		[ret appendFormat:@" -w %@ \"%@\"",kTMPSNDPATH,message];
	}
    
    
    else IF_MCSystemCheck(kMCSKName) {
        NSString * phont;
		if ([phontName isEqualToString:@"男声"])
			phont = @"m1";
        else
            phont = nil;
		
        [ret appendFormat:@"%@ -o \"%@\" | %@ ",kSayKotoeriPath,message,kSayKanaPath];
        if (speed)
            // -s %@ -v %@ -o %@;exit",SPEED,PHONT,TMPSNDPATH]];
            [ret appendFormat:@" -s %ld",speed];
        //-v %@ -o %@;exit",SPEED,PHONT,TMPSNDPATH]];
        if (phont)
            [ret appendFormat:@" -v %@ ",phont];
        
        [ret appendFormat:@" -o %@",kTMPSNDPATH];
        
    }
    else IF_MCSystemCheck(kMCKyokoName) {
        [ret appendFormat:@"say -v kyoko -o %@ \"",kTMPSNDPATH];
        
		if (speed)
			[ret appendFormat:@"[[rate %ld]] ", (speed-45)*4];
        
		[ret appendFormat:@"%@\"",message];
    }
#undef IF_MCSystemCheck
    

    return ret;
}






- (BOOL)hasReadSystem {
    if (_readSystemList.count) return YES;
    else return NO;
}





- (void)read:(NSString *)message name:(NSString *)name modeProperty:(NSDictionary *)property {
    NSUserDefaults * df = [NSUserDefaults standardUserDefaults];
    
    
    NSInteger queueLimit = [df stringForKey:kMCReadModeQueueKey].integerValue;
    NSInteger qLimit     = queueLimit > 0 ? queueLimit : kMCReadQueueLimit;
    if ( _readQueue.count >= qLimit )
        return;
    
    
    
    
    /* merge strings to read */
    NSString * readString;
    if ([df boolForKey:kMCReadModeIsReadTitleKey])
        readString = [NSString stringWithFormat:@"%@%@%@",name,[df stringForKey:kMCReadModeTitleKey],message];
    else
        readString = message;
    
    
    /* Convert Yomi   &   trimming strings */
    NSMutableString * trimedReadString;
    if ([df boolForKey:kMCReadModeIsConvertKey])
        trimedReadString = [NSMutableString stringWithString:[[readString stringByConvertingYomi] stringByTrimmingUnvalidCharacters]];
    else
        trimedReadString = [NSMutableString stringWithString:[readString stringByTrimmingUnvalidCharacters]];
    
    //URL
    [trimedReadString setString:[trimedReadString stringByReplacingOccurrencesOfRegex:@"h?ttp://.+ ?" withString:@"ゆーあーるえる"]];
    
    //
    // limit string count
    //
    int limit = [[df objectForKey:kMCReadModeStringLimit] intValue];
    NSInteger len = trimedReadString.length;
    if (limit < len)
        [trimedReadString replaceCharactersInRange:NSMakeRange(limit, len - limit) withString:[df stringForKey:kMCReadModeStringLimitSuffix]];
    
    
    
    /* proxy */
    //
    // Yukkuroid
    //
    NSUInteger systemNameIndex= [[property objectForKey:kMCReadModeSystemIndexKey] integerValue];
    NSString * systemName = [[MCReadManager sharedReader] systemNameAtIndex:systemNameIndex];
    if ( COMPARESTRING(systemName, kMCYukkuroidName) ){
        [_readQueue addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithBool:YES],kReadIsYukkuroidKey,
                               trimedReadString,kMCYukkuroidReadStringsKey,
                               [property objectForKey:kReadVolumeKey],kReadVolumeKey,
                               [property objectForKey:kReadSpeedKey],kReadSpeedKey,
                               [property objectForKey:kReadPhontIndexKey],kReadPhontIndexKey,
                               nil]];
    }
    //
    // not Yukkuroid
    //
    else {
        
        NSString * readCmd;
        
        readCmd = [self MC_PRIVATE_METHOD_PREPEND(createCommandString):trimedReadString modeProperty:property];
        
        
        if ( readCmd.length == 0 )
            return;
        
        
        [_readQueue addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithBool:NO],kReadIsYukkuroidKey,
                               readCmd,kReadCommandKey,
                               [property objectForKey:kReadVolumeKey],kReadVolumeKey,
                               [property objectForKey:kReadDeviceIndexKey],kReadDeviceIndexKey,
                               nil]];
    }
    [self MC_PRIVATE_METHOD_PREPEND(playTerminal)];
}





- (void)MC_PRIVATE_METHOD_PREPEND(playTerminal) {
    if ( !(_readQueue.count) || _isPlaying )
        return;
    
    _isPlaying = YES;
    [NSThread detachNewThreadSelector:@selector(MC_PRIVATE_METHOD_PREPEND(playInNewThread))
                             toTarget:self withObject:nil];
}




- (void)MC_PRIVATE_METHOD_PREPEND(notYukkuroidRead):(NSDictionary *)task {
    NSString * command = [task objectForKey:kReadCommandKey];
    system([command cStringUsingEncoding:NSUTF8StringEncoding]);
    
    NSData * data = [NSData dataWithContentsOfFile:kTMPSNDPATH];
    NSSound * sound = [[NSSound alloc] initWithData:data];
    
    if (sound) {
        float volume;
        {
            volume = [[task objectForKey:kReadVolumeKey] floatValue];
            if (volume)
                [sound setVolume:volume];
        }
        
        NSString * deviceUID;
        {
            MCSoundDevice * device = [MCSoundDevice sharedAudioDevice];
            deviceUID = [device deviceUIDByIndex:[[task objectForKey:kReadDeviceIndexKey] integerValue]];
            if (deviceUID)
                [sound setPlaybackDeviceIdentifier:deviceUID];
        }
        
        [sound setDelegate:self];
        [sound play];
    }
    else {
        [sound autorelease];
        [self sound:nil didFinishPlaying:NO];
    }
}





- (void)MC_PRIVATE_METHOD_PREPEND(yukkuroidRead):task {
    if ([YukkuroidRPCClinet getVersion]) {
        if ( [YukkuroidRPCClinet getKoeText].length ) {
            [YukkuroidRPCClinet pushKoeTextClearButton];
        }
        [YukkuroidRPCClinet setKanjiText:[task objectForKey:kMCYukkuroidReadStringsKey]];
        [YukkuroidRPCClinet setVoiceSpeed:[[task objectForKey:kReadSpeedKey] intValue] setting:0];
        [YukkuroidRPCClinet setVoiceVolume:[[task objectForKey:kReadVolumeKey] intValue] setting:0];
        [YukkuroidRPCClinet setVoiceType:[[task objectForKey:kReadPhontIndexKey] intValue] setting:0];
        
        [YukkuroidRPCClinet pushPlayButton:0];
        while([YukkuroidRPCClinet isStillPlaying:0]) ;
        
        [self sound:nil didFinishPlaying:YES];
    }
    else {
        // TODO: warn Yukkuroid is not Running
        [self sound:nil didFinishPlaying:NO];
    }
}






- (void)MC_PRIVATE_METHOD_PREPEND(playInNewThread) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    NSDictionary * task = [_readQueue objectAtIndex:0];
    
    if ( [[task objectForKey:kReadIsYukkuroidKey] boolValue] )
        [self MC_PRIVATE_METHOD_PREPEND(yukkuroidRead):task];
    else
        [self MC_PRIVATE_METHOD_PREPEND(notYukkuroidRead):task];
    
    [pool release];
    [NSThread exit];
}







#pragma mark -
#pragma mark NSSound delegate

-(void)sound:(NSSound *)snd didFinishPlaying:(BOOL)aBool {
    if ( [[NSFileManager defaultManager] fileExistsAtPath:kTMPSNDPATH] ) {
		[[NSFileManager defaultManager] removeItemAtPath:kTMPSNDPATH error:NULL];
	}
	if (!aBool)
		DLOG(@"sound failed to play");
    else
        DLOG(@"sound success");
    
    
	[snd autorelease];
    
    BOOL isYk = [[[_readQueue objectAtIndex:0] objectForKey:kReadIsYukkuroidKey] boolValue];
	[_readQueue removeObjectAtIndex:0];
	_isPlaying = NO;
    
    
    if (isYk) {
        //
        // ???: Yukkuroid remove Runloop?
        //
        sleep(aBool ? kMCReadInterval : 0);
        [self MC_PRIVATE_METHOD_PREPEND(playTerminal)];
    }
    else
        [self performSelector:@selector(MC_PRIVATE_METHOD_PREPEND(playTerminal))
                   withObject:nil
                   afterDelay:(aBool ? kMCReadInterval : 0)];
}

@end
