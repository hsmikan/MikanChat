//
//  YukkuroidRPCClinet.m
//
//  Created by Yuichi Ito on 11/08/14.
//  Copyright 2011 Cisco Systems. All rights reserved.
//
//
//  hsmikan modified on 12/08/21.
//
//

#import "YukkuroidRPCClinet.h"


@implementation YukkuroidRPCClinet

+(NSDistantObject *)getYukProxy{
    NSDistantObject * proxy = [NSConnection rootProxyForConnectionWithRegisteredName:@"com.yukkuroid.rpc" host:@""];
    [proxy setProtocolForProxy:@protocol(YukkuroidProtocol)];
    return proxy;
}

/////////////////////////
/////     on panel
/////////////////////////


/// upper left

+(void)setKanjiText:(NSString *)utf8{
	NSDistantObject *proxy = [YukkuroidRPCClinet getYukProxy];
	[proxy setKanjiText:utf8];
}

+(NSString *)getKanjiText{
	NSDistantObject *proxy = [YukkuroidRPCClinet getYukProxy];
	return [proxy getKanjiText];
}

+(void)pushKoeTextGenerateButton{
	NSDistantObject *proxy = [YukkuroidRPCClinet getYukProxy];
	[proxy pushKoeTextGenerateButton];
}


/// upper right

+(void)setKoeText:(NSString *)utf8{
	NSDistantObject *proxy = [YukkuroidRPCClinet getYukProxy];
	[proxy setKoeText:utf8];
}

+(NSString *)getKoeText{
	NSDistantObject *proxy = [YukkuroidRPCClinet getYukProxy];
	return [proxy getKoeText];
}

+(void)pushKoeTextClearButton{
	NSDistantObject *proxy = [YukkuroidRPCClinet getYukProxy];
	[proxy pushKoeTextClearButton];
}


/// bottom left

+(void)setVoiceType:(int)index setting:(int)setting{
	NSDistantObject *proxy = [YukkuroidRPCClinet getYukProxy];
	[proxy setVoiceType:index setting:setting];
}

+(int)getVoiceType:(int)setting{
	NSDistantObject *proxy = [YukkuroidRPCClinet getYukProxy];
	return [proxy getVoiceType:setting];
}

+(void)setVoiceEffect:(int)index setting:(int)setting{
	NSDistantObject *proxy = [YukkuroidRPCClinet getYukProxy];
	[proxy setVoiceEffect:index setting:setting];
}

+(int)getVoiceEffect:(int)setting{
	NSDistantObject *proxy = [YukkuroidRPCClinet getYukProxy];
	return [proxy getVoiceEffect:setting];
}

+(void)setIntonation:(BOOL)isOn setting:(int)setting{
	NSDistantObject *proxy = [YukkuroidRPCClinet getYukProxy];
	[proxy setVoiceIntonation:isOn setting:setting];
}

+(BOOL)getIntonation:(int)setting{
	NSDistantObject *proxy = [YukkuroidRPCClinet getYukProxy];
	return [proxy getIntonation:setting];
}


/// bottom center

+(void)pushPlayButton:(int)setting{
	NSDistantObject *proxy = [YukkuroidRPCClinet getYukProxy];
	[proxy pushPlayButton:setting];
}

+(void)pushStopButton:(int)setting{
	NSDistantObject *proxy = [YukkuroidRPCClinet getYukProxy];
	[proxy pushStopButton:setting];
}

+(void)pushSaveButton:(int)setting{
	NSDistantObject *proxy = [YukkuroidRPCClinet getYukProxy];
	[proxy pushSaveButton:setting];
}


/// bottom right
+ (void)setVoiceSpeed:(int)speed setting:(int)setting{
	NSDistantObject *proxy = [YukkuroidRPCClinet getYukProxy];
	[proxy setVoiceSpeed:speed setting:setting];
}

+ (int)getVoiceSpeed:(int)setting{
	NSDistantObject *proxy = [YukkuroidRPCClinet getYukProxy];
	return [proxy getVoiceSpeed:setting];
}

+ (void)setVoiceVolume:(int)volume setting:(int)setting{
	NSDistantObject *proxy = [YukkuroidRPCClinet getYukProxy];
	[proxy setVoiceVolume:volume setting:setting];
}

+ (int)getVoiceVolume:(int)setting{
	NSDistantObject *proxy = [YukkuroidRPCClinet getYukProxy];
	return [proxy getVoiceVolume:setting];
}


///////////////////
/////   original functions
///////////////////

+ (NSNumber *)getVersion{
	NSDistantObject *proxy = [YukkuroidRPCClinet getYukProxy];
	return [proxy getVersion];
}

+ (BOOL)isStillPlaying:(int)setting{
	NSDistantObject *proxy = [YukkuroidRPCClinet getYukProxy];
	return [proxy isStillPlaying:setting];
}

+ (void)playSync:(int)setting{
	NSDistantObject *proxy = [YukkuroidRPCClinet getYukProxy];
	[proxy playSync:setting];
}

@end
