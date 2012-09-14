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
#define MCClinets @"IRC",@"CaveTube",@"LiveTube",@"WMECast"
typedef enum {
    kMCClientIRCIDNumber       =   0,
    kMCClientCaveTubeIDNumber  =   1,
    kMCClientLiveTubeIDNumber  =   2,
    kMCClientStickamIDNumber   =   3,
    kMCClientWMECastIDNumber   =   4,
} MCClientIDNumber;


#define MCClientID
@protocol MCClientWindowControllerDelegate <NSObject>
- (void)receiveComment:(NSString*)comment;
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
