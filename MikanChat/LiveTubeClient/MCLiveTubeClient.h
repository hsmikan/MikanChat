//
//  MCLiveTubeClient.h
//  MikanChat
//
//  Created by hsmikan on 8/9/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../MCParentClient.h"

@class WebView;

@interface MCLiveTubeClient : MCParentClient {
    WebView * _webView;
}
@property (readonly) BOOL isJoin;

- (id)initWithDelegate:(id<MCClientProtocol>)delegate;
@property (assign) IBOutlet NSTextField *liveURL;
@property (assign) IBOutlet NSTableView *messageTBL;
@property (assign) IBOutlet NSTextField *usernameTF;
@property (assign) IBOutlet NSTextField *messageTF;
- (IBAction)sendMessage:(id)sender;
@end
