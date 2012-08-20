//
//  MCClientWindowController.h
//  MikanChat
//
//  Created by hsmikan on 8/9/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*
 MCClients   と   _MCClientIDNum
 の記述は同順にするように！！
 */
#define MCClinets @"IRC",@"CaveTube",@"LiveTube"
typedef enum {
    kMCClientIRCIDNumber       =   0,
    kMCClientCaveTubeIDNumber  =   1,
    kMCClientLiveTubeIDNumber  =   2,
    kMCClientStickamIDNumber   =   3,
} MCClientIDNumber;


@interface MCClientWindowController : NSWindowController {
    id _clientController;
}
//
//  Toolbar
//
@property (assign) IBOutlet NSPopUpButton *readModePB;
@property (assign) IBOutlet NSButton *isReadCB;
@property (assign) IBOutlet NSButton *toggleBT;
- (IBAction)toggleChat:(NSToolbarItem *)sender;

- (void)showWindow:(id)sender DEPRECATED_ATTRIBUTE;
- (void)showWindow:(id)sender clientIDNumber:(MCClientIDNumber)idnum;
@end
