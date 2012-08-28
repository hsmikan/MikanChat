//
//  MCWMECastClient.h
//  MikanChat
//
//  Created by hsmikan on 8/26/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import "MCClient.h"

@class WebView;

@interface MCWMECastClient : MCClient<MCClientDelegate> {
    WebView * _webView;
}
@property (readonly) BOOL isJoin;
@property (assign) IBOutlet NSTextField *liveURLTF;
@property (assign) IBOutlet NSTableView *messageTBL;
@property (assign) IBOutlet NSTextField *usernameTF;
- (IBAction)sendMessage:(id)sender;
@end
