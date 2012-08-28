//
//  YukkuroidRPCClinet.h
//
//  Created by Yuichi Ito on 11/08/14.
//  Copyright 2011 Cisco Systems. All rights reserved.
//
//
//  2012/08/21
//   modified By hsmikan
//

#import <Cocoa/Cocoa.h>

@protocol YukkuroidProtocol
/////////////////////////
/////   functions on Yukkuroid Panel
/////////////////////////

/// top left
-(void)setKanjiText:(NSString *)string_UTF8;
-(NSString *)getKanjiText;
-(void)pushKoeTextGenerateButton;

/// top right
-(void)setKoeText:(NSString *)string_UTF8;
-(NSString *)getKoeText;
-(void)pushKoeTextClearButton;


/// bottom left
-(void)setVoiceType:(int)index setting:(int)setting ;
-(int)getVoiceType:(int)setting;
-(void)setVoiceEffect:(int)index setting:(int)setting;
-(int)getVoiceEffect:(int)setting;
/* ???: Proxy 先では setIntonation ではなく setVoiceIntonation??? */
-(void)setVoiceIntonation:(BOOL)isOn setting:(int)setting;
-(BOOL)getIntonation:(int)setting;

/// bottom center
-(void)pushPlayButton:(int)setting;
-(void)pushStopButton:(int)setting;
-(void)pushSaveButton:(int)setting;

/// bottom right
- (void)setVoiceSpeed:(int)speed setting:(int)setting;
- (int)getVoiceSpeed:(int)setting;
- (void)setVoiceVolume:(int)volume setting:(int)setting;
- (int)getVoiceVolume:(int)setting;


///////////////////////
//////    original functions
///////////////////////

- (NSNumber *)getVersion;
- (BOOL)isStillPlaying:(int)setting;
- (void)playSync:(int)setting;
@end


@interface NSDistantObject (Yukkuroid) <YukkuroidProtocol>

@end
@interface YukkuroidRPCClinet : NSObject
/////////////////////////
/////   functions on Yukkuroid Panel
/////////////////////////

/// top left
+(void)setKanjiText:(NSString *)string_UTF8;
+(NSString *)getKanjiText;
+(void)pushKoeTextGenerateButton;

/// top right
+(void)setKoeText:(NSString *)string_UTF8;
+(NSString *)getKoeText;
+(void)pushKoeTextClearButton;


/// bottom left
+(void)setVoiceType:(int)index setting:(int)setting ;
+(int)getVoiceType:(int)setting;
+(void)setVoiceEffect:(int)index setting:(int)setting;
+(int)getVoiceEffect:(int)setting;
+(void)setIntonation:(BOOL)isOn setting:(int)setting;
+(BOOL)getIntonation:(int)setting;

/// bottom center
+(void)pushPlayButton:(int)setting;
+(void)pushStopButton:(int)setting;
+(void)pushSaveButton:(int)setting;

/// bottom right
+ (void)setVoiceSpeed:(int)speed setting:(int)setting;
+ (int)getVoiceSpeed:(int)setting;
+ (void)setVoiceVolume:(int)volume setting:(int)setting;
+ (int)getVoiceVolume:(int)setting;


///////////////////////
//////    original functions
///////////////////////

+ (NSNumber *)getVersion;
+ (BOOL)isStillPlaying:(int)setting;
+ (void)playSync:(int)setting;



/*==============================================================================
 *
 * hsmikan Additon
 *
 *==============================================================================*/
+ (NSArray *)voices;
@end
