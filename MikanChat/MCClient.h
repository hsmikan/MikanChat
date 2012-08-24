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


@protocol MCClientWindowDelegate <NSObject>
- (BOOL)clientGetMessage:(NSString*)message userName:(NSString*)userName;
- (void)clientEvent:(MCClientEventCode)code message:(NSString*)message;
@end


@protocol MCClientDelegate <NSObject,NSTableViewDataSource,NSTableViewDelegate>
@required
- (id)initWithDelegate:(id<MCClientDelegate>)delegate;
- (BOOL)startChat;
- (void)endChat;
- (BOOL)isJoin;
@end

@interface MCClient : NSViewController {
    NSMutableArray * _messageList;
}
@property (assign) id <MCClientWindowDelegate>        delegate;
- (id)initWithDelegate:(id<MCClientWindowDelegate>)delegate nibName:(NSString*)nibName;
@end
