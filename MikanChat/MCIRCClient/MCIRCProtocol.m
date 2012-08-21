//
//  MCIRCProtocol.m
//  MikanChat
//
//  Created by hsmikan on 8/11/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import "MCIRCProtocol.h"
#import "MCIRCClientDelegate.h"


#import "../NSString/NSString+MCRegex.h"


#define CHECKSTATUS(VAR) INSENSITIVECOMPARE(status, VAR)
#define CHECKMSG(arr,index,msg) INSENSITIVECOMPARE([arr objectAtIndex:index],msg)

#define SPLIT(STR,KEY,INDEX) [[STR componentsSeparatedByString:KEY] objectAtIndex:INDEX]


#define IRCEVENT(EVENT,MESSAGE) \
if ( [self.delegate respondsToSelector:@selector(IRCEventOccured:withObject:)] ) \
[self.delegate IRCEventOccured:EVENT withObject:MESSAGE]


#define NAMES() [self send:STRINGFORMAT(@"NAMES %@",_channel)]


#define BIT(num) ((unsigned int)1 << (num))
#define IRCFLAG_BOT BIT(1)
#define IRCFLAG_RANDOM BIT(2)
#define IRCFLAG_NOTIFY BIT(3)
#define IRCFLAG_EXTERNAL BIT(4)




@implementation MCIRCProtocol

@synthesize delegate = _delegate;

@synthesize isJoin = _isJoin;
@synthesize portNumber = _portNumber;
@synthesize server = _server;
@synthesize serverPass = _serverPass;
@synthesize channel = _channel;
@synthesize channelPass = _channelPass;
@synthesize nickname = _nickname;
@synthesize username = _username;
@synthesize realname = _realname;


- (id)initWithDelegate:(id<IRCDelegate>)delegate {
    self = [super init];
    
    if (self) {
        self.delegate = delegate;
        _subnickname = [[NSMutableString alloc] init];
    }
    
    return self;
}


- (void)dealloc {
    
    [self stopRunning];
	
	RELEASE_NIL_ASSIGN(_server)   RELEASE_NIL_ASSIGN(_serverPass)
	RELEASE_NIL_ASSIGN(_channel)  RELEASE_NIL_ASSIGN(_channelPass)
	RELEASE_NIL_ASSIGN(_nickname) RELEASE_NIL_ASSIGN(_realname)
    RELEASE_NIL_ASSIGN(_username) RELEASE_NIL_ASSIGN(_subnickname)
	
    [super dealloc];
}






#pragma mark -
#pragma mark Send
/*==============================================================================
 *
 *  send methods
 *
 *==============================================================================*/


//
//  次のメッセージを生成してサーバへ送信します。
//      Operator _channel(インスタンス) message
//
- (BOOL)sendToChannelWithOperator:(NSString*)mode message:(NSString *)msg {
	return [self send:[NSString stringWithFormat:@"%@ %@ %@",mode,_channel,msg]];
}



-(BOOL)send:(NSString *)msg{
    NSData* data = [[NSString stringWithFormat:@"%@\r\n",msg] dataUsingEncoding:NSUTF8StringEncoding];
    if (_outputStream) {
        NSUInteger remainingToWrite = [data length];
        void* marker = (void*)[data bytes];
        while (0 < remainingToWrite) {
            NSInteger actuallyWritten = 0;
            actuallyWritten = [_outputStream write:marker maxLength:remainingToWrite];
            remainingToWrite -= actuallyWritten;
            marker += actuallyWritten;
        }
        return YES;
    }
    return NO;
}




#pragma mark -
#pragma mark Start & End
/*==============================================================================
 *
 *  start end
 *
 *==============================================================================*/
//
// check infos
//
- (BOOL) _MC_isEnoughInfo {
    return
        COMPARESTRING(@"", _server)
    ||  COMPARESTRING(@"", _nickname)
    ||  COMPARESTRING(@"", _username)
    ||  COMPARESTRING(@"", _realname)
    ||  COMPARESTRING(@"", _channel);
}

- (void)startRun{
    if ([self MC_PRIVATE_METHOD_PREPEND(isEnoughInfo)])
    {
        IRCEVENT(IRCLackInfo, NSLocalizedString(@"lackInformation", @""));
        return;
    }
    
    
    [_subnickname setString:_nickname];
    
	// Open Stream
    [NSStream getStreamsToHost:[NSHost hostWithName:_server]
                          port:_portNumber
                   inputStream:&_inputStream
                  outputStream:&_outputStream];
    [self openStreams:YES];
    
    if (_serverPass)
		[self send:STRINGFORMAT(@"PASS %@",_serverPass)];
    [self send:STRINGFORMAT(@"NICK %@",_subnickname)];
    [self send:STRINGFORMAT(@"USER %@ cocobot2 server %@",_username,_realname)];
    
    if ([_inputStream streamStatus] == NSStreamStatusNotOpen)
        IRCEVENT(IRCCantOpen, NSLocalizedString(@"failedConnection", @""));
}


-(void)stopRunning {
    if (_outputStream) {
        if (_isJoin) {
            [self send:STRINGFORMAT(@"PART %@",_channel)];
            [self send:@"QUIT"];
            _isJoin = NO;
        }
        [self closeStreams];
        _isOperator = NO;
    }
	IRCEVENT(IRCEnd,nil);
}







#pragma mark -
#pragma mark handling received data
/*==============================================================================
 *
 *  received data
 *
 *==============================================================================*/

-(void)handleRecvString:(NSString*)string recvArray:(NSArray*)rec
     withStatusOfNumber:(NSInteger)statusNumber {
    
    static BOOL isNameListEnd = NO;
    static BOOL isBanListEnd  = NO;
    DLOG(@"\tstatus Code is Number.");
    switch (statusNumber) {
        case 001: // nickname registerd
            [self send:STRINGFORMAT(@"JOIN %@ %@",_channel,_channelPass)];
            [self send:STRINGFORMAT(@"TOPIC %@\r\nMODE %@",_channel,_channel)];
            [self performSelector:@selector(send:)
                       withObject:STRINGFORMAT(@"WHO %@",_channel)
                       afterDelay:5.0f];
            break;
            
        case 315:
            // :chat08.ustream.tv 315 PPixy #ppixy :End of /WHO list.
            break;
            
        case 324:
            //  -- MODE reply-- :chat09.ustream.tv 324 PPixy__ #ppixytesttest +ntf [3t]:5
            IRCEVENT(IRCModeChanged,[rec objectAtIndex:4]);
            break;
            
        case 331: // <channel> :No topic is set
        case 332: // <channel> :<topic>
            IRCEVENT(IRCTopicChanged,[[string componentsSeparatedByString:@":"] lastObject]);
            break;
            
        case 352: // who reply
			// :chat04.ustream.tv 352 PPixy_ #ppixy ppbot rawIPURL chat04.ustream.tv PPixy_ H :0 ppbottt
			// :chat06.ustream.tv 352 PPixy #ppixy ppbot rawIPURL chat06.ustream.tv PPixy H~ :0 ppbottt
			// <channel> <user> <host> <server> <nickname> <H|G>[*][@|+] :<hopcount> <real name>
            if (!_isOperator
                &&
                INSENSITIVECOMPARE([rec objectAtIndex:7],_subnickname)
                &&
                [[rec objectAtIndex:8] isMatchedByRegex:@"[HG][~&@%%\\+]"])
            {
                DLOG(@"operator check");
                _isOperator = YES;
                
                //
                // TODO: IRC BAN
                //
				// NSMutableString *banMasks = [NSMutableString string];
				// for (NSDictionary *banDic in BANLIST){
				//     [banMasks appendFormat:@"/mode %@ +b %@ \r\n",[banDic objectForKey:@"rawMask"],[banDic objectForKey:@"rawMask"]];
				// }
				// if ([banMasks length]) {
				//     [banMasks deleteCharactersInRange:NSMakeRange([banMasks length]-2, 2)];
				//     [self send:banMasks];
				// }
            }
            break;
            
        case 353: // namelist  :chat09.ustream.tv 353 ppbot = #ppixy :ppbot @PPixy_
            if (isNameListEnd){
				IRCEVENT(IRCNameListStart,nil);
                isNameListEnd = NO;
            }
            
            NSString *aName = [[rec objectAtIndex:5] substringFromIndex:1];
            if ([aName isMatchedByRegex:STRINGFORMAT(@"[~&@%%\\+]?%@",_subnickname)]) {
				IRCEVENT(IRCNameListReceiveMine,aName);
			}
            else {
				IRCEVENT(IRCNameListReceive,aName);
			}
            
            for (int i=6; i < [rec count]-1; i++){
                if ( [[rec objectAtIndex:i] isMatchedByRegex:STRINGFORMAT(@"[~&@%%\\+]?%@",_subnickname)] ) {
					IRCEVENT(IRCNameListReceiveMine,[rec objectAtIndex:i]);
				}
                else {
					IRCEVENT(IRCNameListReceive,[rec objectAtIndex:i]);
				}
            }
            break;
            
        case 366: // name list end
            isNameListEnd = YES;
            DLOG(@"\t\tname list end");
            IRCEVENT(IRCNameListEnd,nil);
            break;
            
        case 367: // ban list
            if (isBanListEnd) {
				//[BANLIST removeAllObjects];
                isBanListEnd = NO;
            }
            
			// sample :chat08.ustream.tv 367 PPixy #ppixy test!*@* PPixy 1298149181
			//[BANLIST addObject:[NSArray arrayWithObjects:[fTrim objectAtIndex:3],[fTrim objectAtIndex:4],nil]];
            break;
            
        case 368: // ban list end
            isBanListEnd = YES;
            break;
            
            /**
             * 4xx
             */
        case 403: // no such channel
            IRCEVENT(IRCNoSuchChannel,NSLocalizedString(@"invalidChannel", @""));
            break;
            
        case 404: // 404 code cannot send message
			// :chat02.ustream.tv 404 PPixy__ #PPixy :You need voice (+v) (#ppixy)
            if ( INSENSITIVECOMPARE([rec objectAtIndex:2],_subnickname)
				&&  CHECKMSG(rec,3,_channel) ) {
                IRCEVENT(IRCConsoleMessage,[[string componentsSeparatedByString:@":"] lastObject]);
            }
            break;
            
        case 433: // nickname is already in use
            [_subnickname appendString:@"_"];
            [self send:STRINGFORMAT(@"NICK %@",_subnickname)];
            break;
            
        case 463: // your host isn't among the privileged. //denied connection
            IRCEVENT(IRCDeniedConnection,NSLocalizedString(@"deniedConnetion", @""));
            break;
            
        case 464: // password incorrect
            IRCEVENT(IRCPasswordIncorrect, NSLocalizedString(@"invalidPassword",@""));
            break;
            
        case 465: // you are banned from server
            IRCEVENT(IRCBannedServer,NSLocalizedString(@"banned", @""));
            break;
            
        case 471: // channel is full
            IRCEVENT(IRCChannelFull,NSLocalizedString(@"channelIsFull", @""));
            break;
            
        case 473: // invite only channel
            IRCEVENT(IRCInviteOnly, NSLocalizedString(@"requiredInvite", @""));
            break;
            
        case 474: // banned from channel
            IRCEVENT(IRCBannedChannel, NSLocalizedString(@"channelBanned", @""));
            break;
            
        case 329: // channel time -- MODE reply
        case 333: // This is returned for a TOPIC request or when you JOIN, if the channel has a topic.
            break;
			/******
             ** push console Table View
             *******\/
             case 401: // no such nickname/channel
             case 402: // no such server
             case 405: // too many channels
             case 406: // there was no such nickname
             case 407: // too many targets
             case 409: // no origin specified
             case 411: // no recipent
             case 412: // no text to send
             case 413: // no no toplevel domain specified
             case 414: // no wildcard in toplevel domain
             case 421: // unknown command
             case 422: // :MOTD File is missing
             case 423: // <server> :No administrative info available
             case 424: // :File error doing <file op> on <file>
             case 431: // :No nickname given
             case 432: // <nickname> :Erroneous nickname
             case 436: // <nickname> :Nickname collision KILL
             case 441: // <nickname> <channel> :They aren't on that channel
             case 442: // <channel> :You're not on that channel
             case 443: // <user> <channel> :is already on channel
             case 444: // <user> :User not logged in
             case 445: // :SUMMON has been disabled
             case 446: // :USERS has been disabled
             case 451: // send JOIN command in not registered
             case 461: // <command> :Not enough parameters
             case 462: // you may not reregister. :You may not reregister
             case 472: // <char> :is unknown mode char to me
             case 475: // bad channel key // mode +k
             case 481: // :Permission Denied- You're not an IRC operator
             case 482: // <channel> :You're not channel operator
             case 483: // :You cant kill a server!
             case 491: // :No O-lines for your host
             case 501: // :Unknown MODE flag
             case 502: // :Cant change mode for other users
             */
            
        default:
            if ( [[[string componentsSeparatedByString:@":"] lastObject] length] > 0) {
                IRCEVENT(IRCConsoleMessage,[[string componentsSeparatedByString:@":"] lastObject]);
            }
            break;
    }
}





- (void)handleRecvString:(NSString *)string recvArray:(NSArray *)rec withStatusOfString:(NSString*)statusString {
    DLOG(@"\tstatus Code is String. code : %@",statusString);
    
	if      (INSENSITIVECOMPARE(statusString,@"NOTICE") ) {
		// Ustream Password is incorrective.
		if ([string rangeOfString:@"Incorrect password" options:NSCaseInsensitiveSearch].location != NSNotFound) {
			IRCEVENT(IRCPasswordIncorrect,NSLocalizedString(@"invalidPassword", @""));
		}
		else if ([string rangeOfString:@"This is a registered nick," options:NSCaseInsensitiveSearch].location != NSNotFound) {
			[_subnickname appendString:@"_"];
			[self send:STRINGFORMAT(@"NICK %@",_subnickname)];
			//NOTIFY(@"IRCNickRequiredPass");
		}
	}
	
    else if (INSENSITIVECOMPARE(statusString,@"PRIVMSG")) {
		if ( INSENSITIVECOMPARE([rec objectAtIndex:2],_channel) ){
			//
			// ip
			//
			NSString * nameForIP = [SPLIT([rec objectAtIndex:0],@"!",0) substringFromIndex:1];
			IRCEVENT(IRCGetIP,([NSDictionary dictionaryWithObjectsAndKeys:nameForIP,@"name",SPLIT([rec objectAtIndex:0],@"@",1),@"IP",nil]));
			
			//
			// create message part of received strings(nsarray * rec)
			//
			NSMutableString *msg = [NSMutableString string];
			for (int i=3; i<[rec count]; i++) {
				[msg appendFormat:@"%@ ",[rec objectAtIndex:i]];
			}
			//[NSMutableString stringWithString:SPLIT(retStrFromIRC,@":",2)];
			[msg deleteCharactersInRange:NSMakeRange(0, 1)];
            if ([msg hasSuffix:@"\n"]) {
                [msg deleteCharactersInRange:NSMakeRange(msg.length-1, 1)];
            }
            if ([msg hasSuffix:@"\r"]) {
                [msg deleteCharactersInRange:NSMakeRange(msg.length-1, 1)];
            }
            [msg replaceOccurrencesOfRegex:@"(\\r)?(\\n)?$" withString:@""];
            // TODO: delete check
            
            
			// print msg log
			DLOG(@"\t\tIRCFLAG_MSGLOG is YES.");
			IRCEVENT(IRCMessageUpdate,([NSArray arrayWithObjects:nameForIP,msg,nil]));
			
		}// if ( INSENSITIVECOMPARE([rec objectAtIndex:2],CHANNELNAME) )
	}
	
    else if (INSENSITIVECOMPARE(statusString,@"JOIN")   ) {
		NAMES();
		DLOG(@"\tRECEIVE JOIN");
		NSString* name = [SPLIT([rec objectAtIndex:0],@"!",0) substringFromIndex:1];
		if (INSENSITIVECOMPARE(name,_subnickname)) {
			_isJoin = YES;
		}
		else {
			IRCEVENT(IRCJoin,name);
		}
	}
	
    else if (INSENSITIVECOMPARE(statusString,@"PART")   ) {
		NAMES();
	}
	
    else if (INSENSITIVECOMPARE(statusString,@"QUIT")   ) {
		NAMES();
	}
	
    else if (INSENSITIVECOMPARE(statusString,@"MODE")   ) {
		//            o	- チャンネルオペレータの特権(channeloperator privileges)を授与/剥奪します。
		//            p	- プライベートチャンネル(Private channel)属性を設定/解除します。
		//            s	- シークレットチャンネル(Secret channel)属性を設定/解除します。
		//            i	- インバイトオンリー(Invite-only)属性を設定/解除します。
		//            t	- トピックの変更権(Topic settable)をチャンネルオペレータのみに設定/解除します。
		//            n	- チャンネル外のクライアントのメッセージ(No message)の受信を許可/不許可します。
		//            m	- モデレートチャンネル(Moderated channel:司会つきチャンネル)属性を設定/解除します。
		//            l	- チャンネルに参加するクライアントの数を制限(user limit)する。
		//            b	- クライアントの侵入を拒むBANマスク(Ban mask)を設定/解除します。
		//            v	- モデレートチャンネル属性のついているチャンネルでの発言権を授与/剥奪します。
		//            k	- チャンネルキー(channelkey)(=password)を設定/解除します。
		if (![[rec objectAtIndex:3] isMatchedByRegex:@".+[bvo]"]) {
			[self send:STRINGFORMAT(@"MODE %@",_channel)];
		}
		else if (    [rec count] >= 4
				 &&  [[rec objectAtIndex:3] isMatchedByRegex:@".o"]
				 &&  [[rec objectAtIndex:4] caseInsensitiveCompare:_subnickname])
			NAMES();
	}
	
    else if (INSENSITIVECOMPARE(statusString,@"TOPIC")  ) {
		IRCEVENT(IRCTopicChanged,[[string componentsSeparatedByString:@":"] lastObject]);
	}
	
    else if (INSENSITIVECOMPARE(statusString,@"KICK")   ) {
		NAMES();
		if ( INSENSITIVECOMPARE([rec objectAtIndex:2],_channel)
			&&  CHECKMSG(rec,3,_subnickname) ) {
			IRCEVENT(IRCKicked, NSLocalizedString(@"kicked", @""));
		}
	}
	
    else {
		NSString* strForNotifyOther = [[string componentsSeparatedByString:@":"] lastObject];
		if ( [strForNotifyOther length] > 0 ) {
			IRCEVENT(IRCConsoleMessage,strForNotifyOther);
		}
	}
}





#pragma mark handleRecv Main of this class
-(void)handleRecv:(NSString *)retStrFromIRC{
	
	NSArray* fTrim = [NSArray arrayWithArray:[retStrFromIRC componentsSeparatedByString:@" "]];
	
	/***** fTrim index 0 *****/
	if (CHECKMSG(fTrim,0,@"ERROR")) {
		IRCEVENT(IRCError, NSLocalizedString(@"serverError", @""));
	}
	
    else if(CHECKMSG(fTrim,0,@"PING") || [retStrFromIRC rangeOfString:@"PING"].location != NSNotFound){
		[self send:STRINGFORMAT(@"PONG %@",_subnickname)];
	}
	/***** fTrim index 1 *****/
	
    else if ([fTrim count] > 2) {
		//        NSString* status = [fTrim objectAtIndex:1];
		//        NSString* secoundStatus = [fTrim objectAtIndex:2];
		NSInteger statusNum = [[fTrim objectAtIndex:1] integerValue];
		//        Return Value -- integerValue
		//		The NSInteger value of the receiver’s text,
		//		assuming a decimal representation and skipping whitespace at the beginning of the string.
		//		Returns 0 if the receiver doesn’t begin with a valid decimal text representation of a number.
		
		if ( statusNum ) {
			/*==============================================
			 *	when status is Number
			 *==============================================*/
			[self handleRecvString:retStrFromIRC
						 recvArray:fTrim
				withStatusOfNumber:statusNum];
		}
		else {
			/*==============================================
			 *	when status is String
			 *==============================================*/
			[self handleRecvString:retStrFromIRC
						 recvArray:fTrim
				withStatusOfString:[fTrim objectAtIndex:1]];
		}
	}// check index 1
}// handleRecv:








-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)streamEvent{
	NSInputStream *istream;
	switch (streamEvent) {
		case NSStreamEventHasBytesAvailable:;
			uint8_t oneByte;
			NSInteger actuallyRead = 0;
			istream = (NSInputStream*)aStream;
			if (!_dataBuffer) {
				_dataBuffer = [[NSMutableData alloc] initWithCapacity:2048];
			}
			actuallyRead = [istream read:&oneByte maxLength:1];
			if (actuallyRead == 1) {
				[_dataBuffer appendBytes:&oneByte length:1];
			}
			if (oneByte == '\n') {
				NSString* str = [[NSString alloc] initWithData:_dataBuffer encoding:NSUTF8StringEncoding];
				[self handleRecv:str];
				[str release];
				[_dataBuffer release];
				_dataBuffer = nil;
			}
			break;
		case NSStreamEventEndEncountered:
		case NSStreamEventErrorOccurred:
			IRCEVENT(IRCConnectionFailed,NSLocalizedString(@"somethingError", @""));
			break;
		case NSStreamEventOpenCompleted:
			break;
		case NSStreamEventHasSpaceAvailable:
		case NSStreamEventNone:
		default:
			break;
	}
}

-(void)openStreams:(BOOL)useSSL{
	[_inputStream retain];
	[_outputStream retain];
	[_inputStream setDelegate:self];
	[_outputStream setDelegate:self];
	[_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	if ([_inputStream streamStatus] == NSStreamStatusNotOpen)
		[_inputStream open];
	if ([_outputStream streamStatus] == NSStreamStatusNotOpen)
		[_outputStream open];
}
-(void)closeStreams{
	if ([_inputStream streamStatus] == NSStreamStatusOpen)
		[_inputStream close];
	if ([_outputStream streamStatus] == NSStreamStatusOpen)
		[_outputStream close];
	[_inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_inputStream setDelegate:nil];
	[_outputStream setDelegate:nil];
	[_inputStream release];
	[_outputStream release];
	_inputStream = nil;
	_outputStream = nil;
}

@end
