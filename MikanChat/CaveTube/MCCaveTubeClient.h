//
//  MCCaveTubeClient.h
//  MikanChat
//
//  Created by hsmikan on 8/9/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../MCClient.h"

@class WebView;


@interface MCCaveTubeClient : MCClient <MCClientDelegate> {
    WebView * _webView;
}
@property (assign) IBOutlet NSButton *isReadCommentNumber;
@property (assign) IBOutlet NSTextField *liveURLTF;
@property (assign) IBOutlet NSTableView *messageTBL;
@property (assign) IBOutlet NSTextField *username;
- (IBAction)sendMessage:(id)sender;

@property (readonly) BOOL isJoin;

@end
