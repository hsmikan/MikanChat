//
//  MCSoundDevice.m
//  MikanChat
//
//  Created by hsmikan on 8/9/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import "MCSoundDevice.h"
#import <CoreAudio/CoreAudio.h>

#define DEVICEKEY_NAME  @"deviceName"
#define DEVICEKEY_UID   @"deviceUID"


@implementation MCSoundDevice

/*
 *  prototype
 */
NSDictionary * SHAD_loadDevices(void);




#pragma mark -
#pragma mark Singleton Instances
/*========================================================================================
 *
 *  instances
 *
 *========================================================================================*/
//
// shared instance
//
static MCSoundDevice *_sharedInstance = nil;

//
//
//
static NSArray * _deviceNameList = nil;
static NSArray * _deviceUIDList  = nil;
static NSDictionary * _deviceDic = nil;




#pragma mark -
#pragma mark Sigleton Pattern
/*========================================================================================
 *
 *  Single
 *
 *========================================================================================*/
- (id)          copyWithZone:(NSZone*)zone  {return self;}
- (id)          retain                      {return self;}
- (NSUInteger)  retainCount                 {return UINT_MAX;}
- (oneway void) release                     {return;}
- (id)          autorelease                 {return self;}

+ (id)allocWithZone:(NSZone*)zone   {
    @synchronized(self) {
        _sharedInstance = [super allocWithZone:zone];
        if (_sharedInstance) {
            //
            // Initialize here...
            //
            
            _deviceDic = [[NSDictionary alloc] initWithDictionary:SHAD_loadDevices()];
            
        }
        return _sharedInstance;
    }
    return nil;
}


//
// deallocate
//
+ (void)sharedAudioDeviceWillClose:(NSNotification*)notification {
    RELEASE(_sharedInstance);
    RELEASE(_sharedInstance);
    RELEASE(_deviceNameList);
    RELEASE(_deviceUIDList);
    RELEASE(_deviceDic);
}




//
// Accesser
//
+ (MCSoundDevice*)sharedAudioDevice {
    @synchronized(self){
        if (_sharedInstance == nil) {
            [[self alloc] init];
            NSNotificationCenter * ntc = [NSNotificationCenter defaultCenter];
            [ntc addObserver:[MCSoundDevice class]
                    selector:@selector(sharedAudioDeviceWillClose:)
                        name:NSApplicationWillTerminateNotification
                      object:NSApp];
        }
    }
    
    return _sharedInstance;
}








#pragma mark -
#pragma mark Interface methods
- (NSString*)deviceUIDByIndex:(NSUInteger)index {
    return [[_deviceDic allValues] objectAtIndex:index];
}


- (NSArray* )deviceNameList {
    return [_deviceDic allKeys];
}


- (NSArray*)deviceNameListByReload {
    RELEASE_NIL_ASSIGN(_deviceDic)
    _deviceDic = [[NSDictionary alloc] initWithDictionary:SHAD_loadDevices()];
    return [self deviceNameList];
}





NSDictionary * SHAD_loadDevices(void) {
    
    NSMutableDictionary * retDevice = [NSMutableDictionary dictionary];
    
    OSStatus err;
    AudioDeviceID *deviceIDPtr = NULL;
    UInt32 size;
    AudioObjectPropertyAddress propAddr;
    
    
    /*
     * get All Device
     */
    propAddr.mScope    = kAudioObjectPropertyScopeGlobal;
    propAddr.mElement  = kAudioObjectPropertyElementMaster;
    propAddr.mSelector = kAudioHardwarePropertyDevices;{
        
        err = AudioObjectGetPropertyDataSize(kAudioObjectSystemObject, &propAddr, 0, NULL, &size);
        if(err != noErr) goto catchErr;
        
        deviceIDPtr = malloc(size);
        
        err = AudioObjectGetPropertyData(kAudioObjectSystemObject, &propAddr, 0, NULL, &size, deviceIDPtr);
        if(err != noErr) goto catchErr;
    }
    
    //
    // number of Devices
    //
    UInt32 count = size / sizeof(AudioDeviceID);
    int i;
    
    for(i=0; i<count; i++){
        
        // Determine device has output stream
        propAddr.mSelector = kAudioDevicePropertyStreams;{
            propAddr.mScope    = kAudioDevicePropertyScopeOutput;
            err = AudioObjectGetPropertyDataSize(deviceIDPtr[i], &propAddr, 0, NULL, &size);
            if (err != noErr) {
                goto catchErr;
            }
            
            UInt32 streamCount = size/sizeof(AudioStreamID);
            if (streamCount == 0) {
                continue;
            }
        }
        
        
        // reset Scope
        propAddr.mScope    = kAudioObjectPropertyScopeGlobal;
        
        
        // Get device UID
        CFStringRef deviceUID;
        propAddr.mSelector = kAudioDevicePropertyDeviceUID;{
            err = AudioObjectGetPropertyDataSize(deviceIDPtr[i], &propAddr, 0, NULL, &size);
            if(err != noErr) goto catchErr;
            
            err = AudioObjectGetPropertyData(deviceIDPtr[i], &propAddr, 0, NULL, &size, &deviceUID);
            if(err != noErr) {
                CFRelease( deviceUID );
                goto catchErr;
            }
        }
        
        // Get device name
        CFStringRef deviceName;
        propAddr.mSelector = kAudioObjectPropertyName;{
            err = AudioObjectGetPropertyDataSize( deviceIDPtr[i], &propAddr, 0, NULL, &size );
            if(err != noErr) goto catchErr;
            
            err = AudioObjectGetPropertyData( deviceIDPtr[i], &propAddr, 0, NULL, &size, &deviceName );
            if(err != noErr) {
                CFRelease( deviceName );
                CFRelease( deviceUID );
                goto catchErr;
            }
        }
        
        //
        // ADD DEVICE INFO in DEVICEMAP
        //
        NSString *item = [NSString stringWithString:(NSString*)deviceName];
        NSString *uid  = [NSString stringWithString:(NSString *)deviceUID];
        [retDevice setObject:uid forKey:item];
        CFRelease( deviceName );
        CFRelease( deviceUID );
        
    }
    
catchErr:
    if (deviceIDPtr)
        free( deviceIDPtr );
    return retDevice;
}

@end