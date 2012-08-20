//
//  MCIRCProtocol.h
//  MikanChat
//
//  Created by hsmikan on 8/11/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IRCDelegate;

@interface MCIRCProtocol : NSObject <NSStreamDelegate> {
    NSInputStream * _inputStream;
    NSOutputStream * _outputStream;
    NSMutableData * _dataBuffer;
    
    NSString *_server, *_serverPass;
	NSInteger _portNumber;
	NSString *_channel, *_channelPass;
	
	NSString * _nickname;
    NSMutableString * _subnickname;
	NSString *_realname, *_username;
    
	BOOL _isJoin,_isOperator;
}

@property (assign,readwrite) id <IRCDelegate> delegate;
@property (readonly) BOOL isJoin;
@property (copy) NSString *server;
@property (copy) NSString *serverPass;
@property (assign) NSInteger portNumber;
@property (copy) NSString *channel;
@property (copy) NSString *channelPass;
@property (copy) NSString *nickname;
@property (copy) NSString *realname;
@property (copy) NSString *username;

- (id)initWithDelegate:(id<IRCDelegate>)delegate;

#define kIRCSendOperaterPRIVMSG @"PRIVMSG"
- (BOOL)sendToChannelWithOperator:(NSString*)mode message:(NSString *)msg;
- (BOOL)send:(NSString *)msg;

- (void)stopRunning;
- (void)startRun;
@end