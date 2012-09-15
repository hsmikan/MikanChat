//
//  MCClientWindowController.h
//  MikanChat
//
//  Created by hsmikan on 8/9/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "../MCClient.h"

@protocol MCClientWindowControllerDelegate <NSObject>
- (void)receiveComment:(NSString*)comment clientID:(MCClientIDNumber)client;
@end

@interface MCClientWindowController : NSWindowController {
    id _clientController;
}
@property (assign) id <MCClientWindowControllerDelegate> delegate;
- (id)initWithDelegate:(id<MCClientWindowControllerDelegate>)delegate;
//
//  Toolbar
//
@property (assign) IBOutlet NSPopUpButton *readModePB;
@property (assign) IBOutlet NSButton *isReadCB;
@property (assign) IBOutlet NSButton *toggleBT;
@property (assign) IBOutlet NSButton *isScrollViewBT;
- (IBAction)toggleChat:(NSToolbarItem *)sender;

- (void)showWindow:(id)sender DEPRECATED_ATTRIBUTE;
- (void)showWindow:(id)sender clientIDNumber:(MCClientIDNumber)idnum;
@end
