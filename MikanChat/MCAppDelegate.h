//
//  MCAppDelegate.h
//  MikanChat
//
//  Created by hsmikan on 8/9/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MCReadModePopUpButton;
@class MCScrollViewWindowController;

@interface MCAppDelegate : NSObject <NSApplicationDelegate> {
    MCScrollViewWindowController * _scrollController;
}

@property (assign) IBOutlet NSWindow *window;
//
// General
//
- (IBAction)openMainWindow:(id)sender;
- (IBAction)openHelpPage:(id)sender;


//
// Toolbar
//
- (IBAction)openIRCWindow:(id)sender;
- (IBAction)openCaveTubeWindow:(id)sender;
- (IBAction)openLiveTube:(id)sender;
- (IBAction)openStcikamWIndow:(id)sender;
- (IBAction)openWMECastWindow:(id)sender;
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

@property (assign) IBOutlet NSColorWell *scrollFontColorWell;
@property (assign) IBOutlet NSColorWell *scrollFontColorWellCT;
@property (assign) IBOutlet NSColorWell *scrollFontColorWellLT;
@property (assign) IBOutlet NSColorWell *scrollFontColorWellST;
@property (assign) IBOutlet NSColorWell *scrollFontColorWellWME;
@property (assign) IBOutlet NSColorWell *scrollBackgroundColorWell;
@property (assign) IBOutlet NSMatrix *scrollTestClient;
- (IBAction)openScrollViewer:(id)sender;
- (IBAction)changeScrollViewBGCL:(id)sender;
- (IBAction)lockScrollViewer:(id)sender;
- (IBAction)unlockScrollViewer:(id)sender;
- (IBAction)scrollViewerShowBorder:(id)sender;
- (IBAction)testScroll:(id)sender;
@end
