//
//  MCClientWindowController.m
//  MikanChat
//
//  Created by hsmikan on 8/9/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import "MCClientWindowController.h"


#import "../MCUserDefaultsKeys.h"
#import "../NSString/NSString+MCConverter.h"

#import "../PopUpButton/MCReadModePopUpButton.h"


#import "../NSString/NSString+MCRegex.h"

//
// Singleton
//
#import "../ReadManager/MCReadManager.h"


//
// Client
//  ViewController
//
#import "../MCIRCClient/MCIRCClient.h"
#import "../CaveTube/MCCaveTubeClient.h"
#import "../LiveTubeClient/MCLiveTubeClient.h"
#import "../StickamClient/MCStickamClient.h"
#import "../WMECast/MCWMECastClient.h"

//  ClientName
//
#define kCHATWINDOWTITLEIRC @"IRC"
#define kCHATWINDOWTITLECaveTube @"cavetube"
#define kCHATWINDOWTITLELiveTube @"LiveTube"
#define kCHATWINDOWTITLEStickam  @"Stickam"
#define kCHATWINDOWTITLEWMECast  @"WMECast"


@interface MCClientWindowController () <MCClientWindowDelegate>
- (void)MC_PRIVATE_METHOD_PREPEND(readModePBUpdated);
@end

@implementation MCClientWindowController
@synthesize delegate = _delegate;
@synthesize toggleBT = _toggleBT;
@synthesize isScrollViewBT = _isScrollViewBT;
@synthesize readModePB = _readModePB;
@synthesize isReadCB = _isReadCB;
- (id)initWithDelegate:(id<MCClientWindowControllerDelegate>)delegate {
    self = [super initWithWindowNibName:@"MCClientWindowController"];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (id)init {
    self = [super initWithWindowNibName:@"MCClientWindowController"];
    if (self) {
        NSNotificationCenter * nfc = [NSNotificationCenter defaultCenter];
        [nfc addObserver:self selector:@selector(MC_PRIVATE_METHOD_PREPEND(readModePBUpdated))
                    name:kMCReadModePBNotficationKey object:nil];

    }
    return self;
}
/*
 - (id)initWithWindow:(NSWindow *)window
 {
 self = [super initWithWindow:window];
 if (self) {
 // Initialization code here.
 }
 
 return self;
 }
 */
- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [self MC_PRIVATE_METHOD_PREPEND(readModePBUpdated)];
}


- (void)dealloc {
    NSNotificationCenter * nfc = [NSNotificationCenter defaultCenter];
    [nfc removeObserver:self name:kMCReadModePBNotficationKey object:nil];

    [_clientController release];
    [super dealloc];
}



#pragma mark -
#pragma mark window delegate
/*==============================================================================
 *
 *  window delegate
 *
 *==============================================================================*/
- (BOOL)windowShouldClose:(id)sender { return YES; }
- (void)windowWillClose:(NSNotification *)notification { [self release]; }



#pragma mark -
#pragma mark show
/*==============================================================================
 *
 *  show
 *
 *==============================================================================*/

- (void)showWindow:(id)sender { return; }
- (void)showWindow:(id)sender clientIDNumber:(MCClientIDNumber)num {
    [super showWindow:sender];
    Class clientClass = nil;
    NSString * windowTitle = nil;
    
    switch (num) {
        case kMCClientIRCIDNumber:
            clientClass = [MCIRCClient class];
            windowTitle = kCHATWINDOWTITLEIRC;
            break;
        case kMCClientCaveTubeIDNumber:
            clientClass = [MCCaveTubeClient class];
            windowTitle = kCHATWINDOWTITLECaveTube;
            break;
        case kMCClientLiveTubeIDNumber:
            clientClass = [MCLiveTubeClient class];
            windowTitle = kCHATWINDOWTITLELiveTube;
            break;
        case kMCClientStickamIDNumber:
            clientClass = [MCStickamClient class];
            windowTitle = kCHATWINDOWTITLEStickam;
            break;
        case kMCClientWMECastIDNumber:
            clientClass = [MCWMECastClient class];
            windowTitle = kCHATWINDOWTITLEWMECast;
        default:
            break;
    }
    
    if (clientClass/* != nil*/) {
        _clientController = [[clientClass alloc] initWithDelegate:self];
        [[self window] setContentView:[_clientController view]];
        
        [[self window] setTitle:windowTitle];
    }
}




#pragma mark -
#pragma mark ClientDelegate
/*==============================================================================
 *
 *  ClientDelegate
 *
 *==============================================================================*/
- (BOOL)clientGetMessage:(NSString *)message userName:(NSString *)userName clienID:(MCClientIDNumber)client{
    BOOL isIgnore = NO;
    
    NSUserDefaults * df = [NSUserDefaults standardUserDefaults];
    NSArray * ignoreList = [df arrayForKey:kMCIgnoreListKey];
    
    for (NSDictionary * ignoreInfo in ignoreList) {
        NSString * checkContent = nil;
        
        NSInteger typeIndex = [[ignoreInfo objectForKey:kMCIgnoreListTypeIndexKey] integerValue];
        // TODO: Make ignore-type-index Constant
        switch (typeIndex) {
            case 0: /* username */ checkContent = userName; break;
            case 1: /* message */  checkContent = message;  break;
            default: break;
        }
        
        if (checkContent/* != nil*/) {
            NSRange ignoreRange = [checkContent rangeOfString:[ignoreInfo objectForKey:kMCIgnoreListContentKey]];
            if (ignoreRange.location != NSNotFound) {
                isIgnore = YES;
                break;
            }
        }
    }
    
    if (isIgnore) return NO;
    
    
    
    if (_isScrollViewBT.state) {
        [self.delegate receiveComment:message clientID:client];
    }
    
    
    if ([_isReadCB isEnabled] && [_isReadCB state]) {
        
        NSDictionary * readMode;
        NSString * modeName = [[_readModePB selectedItem] title];
        
        for (NSDictionary * item in [df arrayForKey:kMCReadModeListKey]) {
            if ( COMPARESTRING(modeName, [item objectForKey:kMCReadModeNameKey]) ) {
                readMode = item;
                break;
            }
        }
        
        
        MCReadManager * reader = [MCReadManager sharedReader];
        [reader read:message name:userName modeProperty:readMode];
    }
    
    
    
    if ([df boolForKey:kMCIsEnabledExternalLearn]) {
        if ([message isMatchedByRegex:@"^教育[ 　].+[=＝].+$"]) {
            NSArray * dicInfo = [[message substringFromIndex:3] componentsSeparatedByString:@"="];
            NSUserDefaults * df = [NSUserDefaults standardUserDefaults];
            NSMutableArray * dic = [NSMutableArray arrayWithArray:[df objectForKey:kMCConvertYomiListKey]];
            [dic addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                            [dicInfo objectAtIndex:0],kMCConvertYomiListPatternKey,
                            [dicInfo objectAtIndex:1],kMCConvertYomiListYomiKey,
                            nil]];
            [df setObject:dic forKey:kMCConvertYomiListKey];
        }
    }
    
    return YES;
}


- (void)clientEvent:(MCClientEventCode)code message:(NSString *)message {
    switch (code) {
        case kMCClientClosed:
        case kMCClientLoginCancel:
            [_toggleBT setTitle:@"Join"];
            break;
        case kMCClientError:
        case kMCClientConnectionError:
            [_toggleBT setTitle:@"Join"];
            NSBeginAlertSheet(@"MCClientError", @"O.K.", nil, nil, [self window], nil, nil, nil, nil, @"%@",message);
            break;
        default:
            break;
    }
}


#pragma mark -
#pragma mark Action
/*==============================================================================
 *
 *  Action
 *
 *==============================================================================*/

- (IBAction)toggleChat:(NSToolbarItem *)sender {
    if ([_clientController isJoin]) {
        [_toggleBT setTitle:@"Join"];
        [_clientController endChat];
    }
    else {
        if ([_clientController startChat])
            [_toggleBT setTitle:@"Leave"];
        
    }
}







- (void)MC_PRIVATE_METHOD_PREPEND(readModePBUpdated) {
    if ( [_readModePB itemTitles].count )
        [_isReadCB setEnabled:YES];
    else {
        [_isReadCB setEnabled:NO];
        [_isReadCB setState:0];
    }
}

@end
