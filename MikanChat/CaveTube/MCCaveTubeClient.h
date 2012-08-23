//
//  MCCaveTubeClient.h
//  MikanChat
//
//  Created by hsmikan on 8/9/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../MCParentClient.h"

@class WebView;


@interface MCCaveTubeClient : MCParentClient {
    WebView * _webView;
}
@property (assign) IBOutlet NSButton *isReadCommentNumber;
@property (assign) IBOutlet NSTextField *liveURLTF;
@property (assign) IBOutlet NSTableView *messageTBL;
@property (assign) IBOutlet NSTextField *username;
- (IBAction)sendMessage:(id)sender;

@property (readonly) BOOL isJoin;
@property (assign,readwrite) id <MCClientProtocol> delegate;
- (id)initWithDelegate:(id<MCClientProtocol>)delegate;

@end
