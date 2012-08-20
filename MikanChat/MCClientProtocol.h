//
//  MCClientProtocol.h
//  MikanChat
//
//  Created by hsmikan on 8/9/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kMCClientMessageKey;
extern NSString * const kMCClientUserNameKey;



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


@protocol MCClientViewControllerProtocol <NSObject>
@required
- (BOOL)startChat;
- (void)endChat;
- (BOOL)isJoin;
@end