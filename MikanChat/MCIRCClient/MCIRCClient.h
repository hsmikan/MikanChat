//
//  MCIRCClient.h
//  MikanChat
//
//  Created by hsmikan on 8/9/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../MCClient.h"

@class MCIRCProtocol;

@interface MCIRCClient : MCClient <MCClientDelegate> {
    MCIRCProtocol  * _irc;
    NSMutableArray * _nameList;
    NSMutableArray * _consoleLog;
}
@property (assign) IBOutlet NSPanel             *startModal;
@property (assign) IBOutlet NSTextField         *serverTF;
@property (assign) IBOutlet NSSecureTextField   *serverPassTF;
@property (assign) IBOutlet NSTextField         *serverPort;
@property (assign) IBOutlet NSTextField         *channelTF;
@property (assign) IBOutlet NSSecureTextField   *channelPassTF;
@property (assign) IBOutlet NSTextField         *nicknameTF;
@property (assign) IBOutlet NSTextField         *loginNameTF;
@property (assign) IBOutlet NSTextField         *realnameTF;
- (IBAction)goStart:(id)sender;
- (IBAction)cancelStart:(id)sender;
@property (assign) IBOutlet NSTextField *topicTF;
@property (assign) IBOutlet NSTableView *messageTBL;
@property (assign) IBOutlet NSTableView *nameListTBL;
- (IBAction)sendMessage:(id)sender;
@end
