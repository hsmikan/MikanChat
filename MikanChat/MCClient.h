//
//  MCParentClient.h
//  MikanChat
//
//  Created by hsmikan on 8/19/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#define kMCClientMessageKey   @"message"
#define kMCClientUserNameKey  @"username"



typedef enum {
    kMCClientClosed,
    kMCClientLoginCancel = 300,
    kMCClientError = 400,
    kMCClientConnectionError,
    kMCClientLackInfoError,
} MCClientEventCode;


@protocol MCClientProtocol <NSObject>
- (BOOL)clientGetMessage:(NSString*)message userName:(NSString*)userName;
- (void)clientEvent:(MCClientEventCode)code message:(NSString*)message;
@end



@interface MCParentClient : NSViewController <NSTableViewDataSource,NSTableViewDelegate> {
    NSMutableArray * _messageList;
}
@property (assign) id <MCClientProtocol>        delegate;
- (id)initWithDelegate:(id<MCClientProtocol>)delegate nibName:(NSString*)nibName;
- (id)initWithDelegate:(id<MCClientProtocol>)delegate;
- (BOOL)startChat;
- (void)endChat;
- (BOOL)isJoin;
@end
