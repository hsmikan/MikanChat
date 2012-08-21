//
//  MCAppDelegate.h
//  MikanChat
//
//  Created by hsmikan on 8/9/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MCUserDefaultsKeys.h"

#import "NSString/NSString+MCRegex.h"

#import "ClientWindowController/MCClientWindowController.h"

#import "SoundDevice/MCSoundDevice.h"
#import "ReadManager/MCReadManager.h"

#import "TableView/MCReadModeTableView.h"
#import "PopUpButton/MCReadModePopUpButton.h"

@interface MCAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
//
// General
//
- (IBAction)openMainWindow:(id)sender;

//
// Toolbar
//
- (IBAction)openIRCWindow:(id)sender;
- (IBAction)openCaveTubeWindow:(id)sender;
- (IBAction)openLiveTube:(id)sender;
- (IBAction)openStcikamWIndow:(id)sender;
- (IBAction)reloadSoundDevices:(id)sender;
- (IBAction)openUpdates:(id)sender;

//
// read mode
//
@property (assign) IBOutlet NSTableView *readModeTBL;
@property (assign) IBOutlet MCReadModePopUpButton *testReadModePB;
@property (assign) IBOutlet NSTextField *testUserNameTF;
@property (assign) IBOutlet NSTextField *testTextTF;
- (IBAction)addNewReadMode:(id)sender;
- (IBAction)removeReadMode:(id)sender;
- (IBAction)testReading:(id)sender;


//
// convertyomi
//
@property (assign) IBOutlet NSTableView *convertYomiTBL;
@property (assign) IBOutlet NSTextField *convertPatternTF;
@property (assign) IBOutlet NSTextField *convertYomiTF;
- (IBAction)addNewConvertion:(id)sender;
- (IBAction)deleteConvertion:(id)sender;


//
// ignore
//
@property (assign) IBOutlet NSTableView *ignoreTBL;
@property (assign) IBOutlet NSPopUpButton *ignoreTypePB;
@property (assign) IBOutlet NSTextField *ignoreContentTF;
- (IBAction)addNewIgnore:(id)sender;
- (IBAction)deleteIgnore:(id)sender;

@end
