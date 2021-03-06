//
//  MCAppDelegate.m
//  MikanChat
//
//  Created by hsmikan on 8/9/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import "MCAppDelegate.h"
#import "MCUserDefaultsKeys.h"

#import "NSString/NSString+MCRegex.h"

#import "ClientWindowController/MCClientWindowController.h"

#import "SoundDevice/MCSoundDevice.h"
#import "ReadManager/MCReadManager.h"

#import "TableView/MCReadModeTableView.h"
#import "PopUpButton/MCReadModePopUpButton.h"

#import "updates/MCUpdatesController.h"
#import "MCScrollViewWindowController/MCScrollViewWindowController.h"


#import "NSUserDefaults+myColorSuports/NSUserDefaults+myColorSupport.h"


@interface MCAppDelegate () <MCClientWindowControllerDelegate>

@end

@implementation MCAppDelegate
#pragma mark -
#pragma mark synthesize
/*==============================================================================
 *
 *  synthesize
 *  Outlets
 *
 *==============================================================================*/
@synthesize scrollFontColorWell = _scrollFontColorWell;
@synthesize scrollFontColorWellCT = _scrollFontColorWellCT;
@synthesize scrollFontColorWellLT = _scrollFontColorWellLT;
@synthesize scrollFontColorWellST = _scrollFontColorWellST;
@synthesize scrollFontColorWellWME = _scrollFontColorWellWME;
@synthesize scrollBackgroundColorWell = _scrollBackgroundColorWell;
@synthesize scrollTestClient = _scrollTestClient;
@synthesize ignoreTBL           =   _ignoreTBL;
@synthesize ignoreTypePB        =   _ignoreTypePB;
@synthesize ignoreContentTF     =   _ignoreContentTF;

@synthesize convertYomiTF       =   _convertYomiTF;
@synthesize convertYomiTBL      =   _convertYomiTBL;
@synthesize convertPatternTF    =   _convertPatternTF;

@synthesize readModeTBL         =   _readModeTBL;
@synthesize testTextTF          =   _testTextTF;
@synthesize testReadModePB      =   _testReadModePB;
@synthesize testUserNameTF      =   _testUserNameTF;



- (void)dealloc
{
    [super dealloc];
}


#pragma mark -
#pragma mark Initialize
/*==============================================================================
 *
 *  Initialization
 *
 *==============================================================================*/
//
// register user defaults
//
+ (void)initialize {
    NSDictionary * userDefaultsValues;
      NSString * userDefaultsPlistPath;
      userDefaultsPlistPath = [[NSBundle mainBundle] pathForResource:@"UserDefaults" ofType:@"plist"];
    userDefaultsValues = [NSDictionary dictionaryWithContentsOfFile:userDefaultsPlistPath];
    
    
    NSUserDefaults * df = [NSUserDefaults standardUserDefaults];
    [df registerDefaults:userDefaultsValues];
    
    NSUserDefaultsController * dfc = [NSUserDefaultsController sharedUserDefaultsController];
    [dfc setInitialValues:userDefaultsValues];
}

//
// アプリケーション起動完了
// 初期化とか
//
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSUserDefaults * df = [NSUserDefaults standardUserDefaults];
    //
    // 更新チェック
    //
    if ( [df boolForKey:kMCAutomaaticallyUpdatesKey]) {
        MCUpdatesController * updates = [[MCUpdatesController alloc] init];
        if ( updates.isUpToDate ) {
            [updates showWindow:self];
        }
        else {
            [updates release];
        }
    }
    
    //
    // Restore
    //
#define CalibratedBlack [NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:1]
#define CalibratedWhite [NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:1]
#define CHECK_NOT_NIL(X,Y,Z) (X).color = ([df colorForKey:(Y)] ? [df colorForKey:(Y)] : (Z))
//    if ( [df colorForKey:(Y)] ) (X).color = [df colorForKey:(Y)]
    CHECK_NOT_NIL(_scrollFontColorWell,kMCScrollViewFontColor,CalibratedBlack);
    CHECK_NOT_NIL(_scrollFontColorWellCT,kMCScrollViewFontColorCT,CalibratedBlack);
    CHECK_NOT_NIL(_scrollFontColorWellLT,kMCScrollViewFontColorLT,CalibratedBlack);
    CHECK_NOT_NIL(_scrollFontColorWellST,kMCScrollViewFontColorST,CalibratedBlack);
    CHECK_NOT_NIL(_scrollFontColorWellWME,kMCScrollViewFontColorWME,CalibratedBlack);
    
    CHECK_NOT_NIL(_scrollBackgroundColorWell,kMCScrollViewBGColor,CalibratedWhite);
#undef CalibratedWhite
#undef CalibratedBlack
#undef CHECK_NOT_NIL
    
    
    //
    // allocate ScrollViewer
    //
    _scrollController = [[MCScrollViewWindowController alloc] init];
    [_scrollController changeBackgroundColor:_scrollBackgroundColorWell.color];
    [_scrollController setIsShowBorder:[df boolForKey:kMCScrollViewIsShowBorder]];
    // TEST
#ifdef DEBUG

    [_scrollController showWindow:self];
    [self receiveComment:@"test" clientID:kMCClientIRCIDNumber];

#endif
}



#pragma mark -
#pragma mark Finalize
/*==============================================================================
 *
 *  Deallocate
 *
 *==============================================================================*/
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender { return NO; }

//
// 終了確認
//
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    //TODO: クライアントの起動状況の確認
    
    //
    // Save
    //
    NSUserDefaults * df = [NSUserDefaults standardUserDefaults];
    [df setColor:_scrollBackgroundColorWell.color forKey:kMCScrollViewBGColor];
    [df setColor:_scrollFontColorWell.color forKey:kMCScrollViewFontColor];
    [df setColor:_scrollFontColorWellCT.color forKey:kMCScrollViewFontColorCT];
    [df setColor:_scrollFontColorWellLT.color forKey:kMCScrollViewFontColorLT];
    [df setColor:_scrollFontColorWellST.color forKey:kMCScrollViewFontColorST];
    [df setColor:_scrollFontColorWellWME.color forKey:kMCScrollViewFontColorWME];
    
    return NSTerminateNow;
}


//
// 終了処理
//
- (void)applicationWillTerminate:(NSNotification *)notification {
    //
    // deallocate
    //
    [_scrollController release];
}







- (IBAction)openMainWindow:(id)sender {
    [_window makeKeyAndOrderFront:self];
}

- (IBAction)openHelpPage:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.waterbolt.info/apps/MikanChat/help/"]];
}



#pragma mark -
#pragma mark Toolbar Action
/*==============================================================================
 *
 *  Toolbar
 *
 *==============================================================================*/
//
// open Client Window
//
- (void)MC_PRIVATE_METHOD_PREPEND(openClientWindow):(MCClientIDNumber)idnum {
    MCClientWindowController * client = [[MCClientWindowController alloc] initWithDelegate:self];
    [client showWindow:self clientIDNumber:idnum];
}
- (IBAction)openIRCWindow       :(id)sender { [self MC_PRIVATE_METHOD_PREPEND(openClientWindow):kMCClientIRCIDNumber]; }
- (IBAction)openCaveTubeWindow  :(id)sender { [self MC_PRIVATE_METHOD_PREPEND(openClientWindow):kMCClientCaveTubeIDNumber]; }
- (IBAction)openLiveTube        :(id)sender { [self MC_PRIVATE_METHOD_PREPEND(openClientWindow):kMCClientLiveTubeIDNumber]; }
- (IBAction)openStcikamWIndow   :(id)sender { [self MC_PRIVATE_METHOD_PREPEND(openClientWindow):kMCClientStickamIDNumber];}
- (IBAction)openWMECastWindow   :(id)sender { [self MC_PRIVATE_METHOD_PREPEND(openClientWindow):kMCClientWMECastIDNumber];}


//
// reload devices
//
- (IBAction)reloadSoundDevices:(id)sender {
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:kMCReadModeSystemDeviceUpdateNotification object:nil];
}

- (IBAction)openUpdates:(id)sender {
    MCUpdatesController * updates = [[MCUpdatesController alloc] init];
    [updates showWindow:self];
}



#pragma mark -
#pragma mark Scroll View
/*==============================================================================
 *
 *  Scroll View
 *
 *==============================================================================*/
//  ・コメントをスクロールさせる
//  ・hogehoge
//
- (void)receiveComment:(NSString *)comment clientID:(MCClientIDNumber)client {
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    
    if (![[_scrollController window] isVisible]) [_scrollController showWindow:self];
    
    NSColor *fontcolor = nil;
    switch (client) {
        case kMCClientIRCIDNumber:
            fontcolor = [_scrollFontColorWell color];
            break;
        case kMCClientCaveTubeIDNumber:
            fontcolor = [_scrollFontColorWellCT color];
            break;
        case kMCClientLiveTubeIDNumber:
            fontcolor = [_scrollFontColorWellLT color];
            break;
        case kMCClientStickamIDNumber:
            fontcolor = [_scrollFontColorWellST color];
            break;
        case kMCClientWMECastIDNumber:
            fontcolor = [_scrollFontColorWellWME color];
            break;
        default:
            break;
    }
    if (fontcolor != nil)
        [_scrollController scrollString:comment attributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                            [NSNumber numberWithFloat:[df floatForKey:kMCScrollViewFontSize]],HSMScrollViewerFontSize,
                                                            [NSNumber numberWithFloat:[df floatForKey:kMCScrollViewFontDuration]],HSMScrollViewerDuration,
                                                            fontcolor,HSMScrollViewerFontColor,
                                                            nil]];
}






#pragma mark -
#pragma mark ReadMode
/*==============================================================================
 *
 *  ReadMode
 *
 *==============================================================================*/
//
// read mode add/remove
//
- (IBAction)addNewReadMode:(id)sender {
    if (![[MCReadManager sharedReader] hasReadSystem]) {
        
        NSRunAlertPanel(@"MikanChat", NSLocalizedString(@"noValidReadSytem", @""), @"O.K.", nil, nil);
        return;
    }
    
    
    NSUserDefaults * df = [NSUserDefaults standardUserDefaults];
    int suffix = 0;
    for (NSDictionary * readmodeproperty in [df objectForKey:kMCReadModeListKey]) {
        if ([[readmodeproperty objectForKey:kMCReadModeNameKey] rangeOfRegex:@"NEW[0-9]+"].location != NSNotFound) {
            int subsuffix = [[[readmodeproperty objectForKey:kMCReadModeNameKey] substringFromIndex:3] intValue];
            if (suffix < subsuffix) suffix = subsuffix;
        }
    }
    
    NSString * name;
    if (++suffix)
        name = [NSString stringWithFormat:@"NEW%d",suffix];
    else
        name = @"NEW";
    
    
    NSMutableDictionary * format = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    name,kMCReadModeNameKey,
                                    [NSNumber numberWithUnsignedInt:0],kMCReadModeSystemIndexKey,
                                    [NSNumber numberWithUnsignedInt:0],kMCReadModePhontIndexKey,
                                    [NSNumber numberWithFloat:100.0f],kMCReadModeVolumeKey,
                                    [NSNumber numberWithFloat:100.0f],kMCReadModeSpeedKey,
                                    [NSNumber numberWithUnsignedInt:0],kMCReadModeDeviceIndexKey,
                                    nil];
    
    
    NSMutableArray * update = [NSMutableArray arrayWithArray:[df objectForKey:kMCReadModeListKey]];
    [update addObject:format];
    [df setObject:update forKey:kMCReadModeListKey];
    MCTBLReloadData(_readModeTBL, update.count);
    
    //
    // post notification
    //  update read mode PopUpButton contents
    //
    [[NSNotificationCenter defaultCenter] postNotificationName:kMCReadModePBNotficationKey object:nil];
}


- (IBAction)removeReadMode:(id)sender {
    NSIndexSet * selectedRows = [_readModeTBL selectedRowIndexes];
    
    if (selectedRows.count == 0) return;
    
    NSUserDefaults * df = [NSUserDefaults standardUserDefaults];
    NSMutableArray * subarr = [NSMutableArray arrayWithArray:[df arrayForKey:kMCReadModeListKey]];
    [subarr removeObjectsAtIndexes:selectedRows];
    [df setObject:subarr forKey:kMCReadModeListKey];
    [_readModeTBL reloadData];
    
    
    //
    // post notification
    //  update read mode PopUpButton contents
    //
    [[NSNotificationCenter defaultCenter] postNotificationName:kMCReadModePBNotficationKey object:nil];
}


- (IBAction)testReading:(id)sender {
    if (![[MCReadManager sharedReader] hasReadSystem]) {
        NSRunAlertPanel(@"MikanChat", NSLocalizedString(@"noValidReadSytem", @""), @"O.K.", nil, nil);
        return;
    }
    
    if ( !_testTextTF.stringValue.length ) {
        NSRunAlertPanel(@"MikanChat", NSLocalizedString(@"noReadText", @""), @"O.K.", nil, nil);
        return;
    }
    
    NSUserDefaults * df = [NSUserDefaults standardUserDefaults];
    NSDictionary * testReadMode = [[df arrayForKey:kMCReadModeListKey] objectAtIndex:[_testReadModePB indexOfSelectedItem]];
    
    [[MCReadManager sharedReader] read:[_testTextTF stringValue]
                                  name:[_testUserNameTF stringValue]
                          modeProperty:testReadMode];
}




#pragma mark -
#pragma mark Convert Yomi
/*==============================================================================
 *
 *  Yomi
 *
 *==============================================================================*/

- (IBAction)addNewConvertion:(id)sender {
    NSUserDefaults * df = [NSUserDefaults standardUserDefaults];
    NSMutableArray * update = [NSMutableArray arrayWithArray:[df arrayForKey:kMCConvertYomiListKey]];
    
    NSString *pattern, *yomi;
      pattern = _convertPatternTF.stringValue;
      yomi = _convertYomiTF.stringValue;
    
    if (pattern.length==0 || yomi.length==0)
        return;
    
    
    if ( [[update valueForKeyPath:kMCConvertYomiListPatternKey] containsObject:pattern] ) {
        NSRunAlertPanel(@"MCConvertYomiDictionary", NSLocalizedString(@"patternExist", @""), @"O.K", nil, nil);
        return;
    }
    
    
    [update addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                       pattern,kMCConvertYomiListPatternKey,
                       yomi,kMCConvertYomiListYomiKey,
                       nil]];
    
    [df setObject:update forKey:kMCConvertYomiListKey];
    
    MCTBLReloadData(_convertYomiTBL, update.count);
}


- (IBAction)deleteConvertion:(id)sender {
    NSIndexSet * indexes = [_convertYomiTBL selectedRowIndexes];
    
    if ( indexes.count == 0 )
        return;
    
    NSUserDefaults * df = [NSUserDefaults standardUserDefaults];
      NSMutableArray * update = [NSMutableArray arrayWithArray:[df arrayForKey:kMCConvertYomiListKey]];
      [update removeObjectsAtIndexes:indexes];
    [df setObject:update forKey:kMCConvertYomiListKey];
    
    [_convertYomiTBL reloadData];
}




#pragma mark -
#pragma mark Ignore List
/*==============================================================================
 *
 *  Ignore
 *
 *==============================================================================*/
- (IBAction)addNewIgnore:(id)sender {
    NSString * content = _ignoreContentTF.stringValue;
    
    if ( content.length==0 ) return;
    
    
    NSNumber * selectedIndexNumber = [NSNumber numberWithInteger:[_ignoreTypePB indexOfSelectedItem]];
    
    
    NSUserDefaults * df = [NSUserDefaults standardUserDefaults];
    NSMutableArray * update = [NSMutableArray arrayWithArray:[df arrayForKey:kMCIgnoreListKey]];
    
    NSDictionary * newItem = [NSDictionary dictionaryWithObjectsAndKeys:
                              selectedIndexNumber,kMCIgnoreListTypeIndexKey,
                              content,kMCIgnoreListContentKey,
                              nil];
    

    if ([update containsObject:newItem]) {
        NSRunAlertPanel(@"MCIgnoreDictionary", NSLocalizedString(@"AlreadyExist", @""), @"O.K", nil, nil);
        return;
    }
    
    
    [update addObject:newItem];
    
    [df setObject:update forKey:kMCIgnoreListKey];
    
    MCTBLReloadData(_ignoreTBL, update.count);
}


- (IBAction)deleteIgnore:(id)sender {
    NSIndexSet * indexes = [_ignoreTBL selectedRowIndexes];
    
    if ( indexes.count == 0 ) return;
    
    NSUserDefaults * df = [NSUserDefaults standardUserDefaults];
      NSMutableArray * update = [NSMutableArray arrayWithArray:[df arrayForKey:kMCIgnoreListKey]];
      [update removeObjectsAtIndexes:indexes];
    [df setObject:update forKey:kMCIgnoreListKey];
    
    [_ignoreTBL reloadData];
}




#pragma mark -
#pragma mark Scroll
/*==============================================================================
 *
 *  Scroll
 *
 *==============================================================================*/

- (IBAction)openScrollViewer:(id)sender {
    [_scrollController showWindow:self];
}

- (IBAction)changeScrollViewBGCL:(id)sender {
    [_scrollController changeBackgroundColor:_scrollBackgroundColorWell.color];
}

- (IBAction)lockScrollViewer:(id)sender {
    [_scrollController lockWindow];
}

- (IBAction)unlockScrollViewer:(id)sender {
    [_scrollController unlockWindow];
    [_scrollController showWindow:self];
}

- (IBAction)scrollViewerShowBorder:(id)sender {
    [_scrollController setIsShowBorder:(BOOL)[sender state]];
}

- (IBAction)testScroll:(id)sender {
    [self receiveComment:[sender stringValue] clientID:(int)_scrollTestClient.selectedTag];
}
@end