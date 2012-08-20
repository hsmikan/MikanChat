//
//  MCIRCClientDelegate.h
//  MikanChat
//
//  Created by hsmikan on 8/9/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    IRCConsoleMessage, // NSString
	
	IRCNameListStart,  // nil
    IRCNameListEnd, // nil
	IRCNameListReceiveMine, // NSString
	IRCNameListReceive, // NSString
	
	IRCGetIP,
	// IRCEVENT(IRCGetIP,[NSDictionary dictionaryWithObjectsAndKeys:name,@"name",IP,@"IP",nil]);
	
    IRCTopicChanged, // NSStirng
	
    IRCMessageUpdate,
	// IRCEVENT(IRCMessageUpdate,[NSArray arrayWithObjects:nameForIP,msg,nil]);
	
    //    IRCExternalLearn,
    //	// IRCEVENT(IRCExternalLearn,[NSArray arrayWithObjects:[rec objectAtIndex:4],[rec objectAtIndex:6],nil]);
	
    IRCModeChanged, // NSString
	
    //	IRCBot,// NSString
    //	IRCCheckIgnore, //nsstring
	IRCJoin,// nsstring
	
    IRCEnd, // nil
	
    IRCStoped = 400,
    IRCConnectionFailed,
    IRCError,
    IRCKicked,
    IRCPasswordIncorrect,
    IRCBannedChannel,
    IRCInviteOnly,
    IRCChannelFull,
    IRCBannedServer,
    IRCDeniedConnection,
    IRCNoSuchChannel,
    IRCCantOpen,
    IRCLackInfo,
} IRCEvent ;

@protocol IRCDelegate <NSObject>
@optional
- (id)IRCEventOccured:(IRCEvent)event withObject:(id)message;
@end
