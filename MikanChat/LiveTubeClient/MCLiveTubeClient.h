//
//  MCLiveTubeClient.h
//  MikanChat
//
//  Created by hsmikan on 8/9/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../MCClient.h"

@class WebView;

@interface MCLiveTubeClient : MCClient {
    WebView * _webView;
}
@property (readonly) BOOL isJoin;

@property (assign) IBOutlet NSTextField *liveURL;
@property (assign) IBOutlet NSTableView *messageTBL;
@property (assign) IBOutlet NSTextField *usernameTF;
@property (assign) IBOutlet NSTextField *messageTF;
- (IBAction)sendMessage:(id)sender;
@end
