//
//  MCStickamClient.h
//  MikanChat
//
//  Created by hsmikan on 8/19/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "../MCParentClient.h"


@class WebView;

@interface MCStickamClient : MCParentClient {
    WebView * _webView;
    NSMutableArray * _messageList;
    BOOL _isAuth;
}
@property (assign) IBOutlet WebView *webView;
@property (assign) IBOutlet NSPanel *loginModalPanel;
@property (assign) IBOutlet NSTextField *loginUserEmail;
@property (assign) IBOutlet NSSecureTextField *loginUserPassword;
- (IBAction)noLogin:(id)sender;
- (IBAction)login:(id)sender;
@property (assign) IBOutlet NSTextField *liveURLTF;
@property (assign) IBOutlet NSTextField *nicknameTF;

@property (assign) IBOutlet NSTableView *messageTBL;

@property (assign) IBOutlet NSButton *isBoldCommentBT;
@property (assign) IBOutlet NSButton *isItalicCommentBT;
@property (assign) IBOutlet NSButton *isUnderlineCommentBT;
@property (assign) IBOutlet NSColorWell *commentColorWell;
@property (assign) IBOutlet NSPopUpButton *fontPBT;
@property (assign) IBOutlet NSPopUpButton *fontSizePBT;
- (IBAction)sendMessage:(id)sender;

@property (readonly) BOOL isJoin;
@end
