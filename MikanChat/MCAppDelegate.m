//
//  MCAppDelegate.m
//  MikanChat
//
//  Created by hsmikan on 8/9/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import "MCAppDelegate.h"

#import "updates/MCUpdatesController.h"

@implementation MCAppDelegate
#pragma mark -
#pragma mark synthesize
/*==============================================================================
 *
 *  synthesize
 *  Outlets
 *
 *==============================================================================*/
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
        if ( updates.isUpToDate )
            [updates showWindow:self];
        else
            [updates release];
    }
    
}



#pragma mark -
#pragma mark Finalize
/*==============================================================================
 *
 *  Finalization
 *
 *==============================================================================*/
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender { return NO; }

//
// 終了確認
//
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    //TODO: クライアントの起動状況の確認
    return NSTerminateNow;
}


//
// 終了処理
//
- (void)applicationWillTerminate:(NSNotification *)notification {
}







- (IBAction)openMainWindow:(id)sender {
    [_window makeKeyAndOrderFront:self];
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
    MCClientWindowController * client = [[MCClientWindowController alloc] init];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:kMCReadModeSystemDeviceUpdateNotification object:nil];
}

- (IBAction)openUpdates:(id)sender {
    MCUpdatesController * updates = [[MCUpdatesController alloc] init];
    [updates showWindow:self];
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
@end