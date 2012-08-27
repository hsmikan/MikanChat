//
//  MCIRCClient.m
//  MikanChat
//
//  Created by hsmikan on 8/9/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import "MCIRCClient.h"
#import "MCIRCClientDelegate.h"
#import "MCIRCProtocol.h"
#import "MCIRCClientDelegate.h"
#import "MCIRCClientConstants.h"

#define NIBNAME @"MCIRCView"
#define kServiceName @"IRC"

@interface MCIRCClient () <IRCDelegate>
@end

@implementation MCIRCClient

@synthesize startModal      = _startModal;
@synthesize serverTF        = _serverTF;
@synthesize serverPassTF    = _serverPassTF;
@synthesize serverPort      = _serverPort;
@synthesize channelTF       = _channelTF;
@synthesize channelPassTF  = _channellPassTF;
@synthesize nicknameTF      = _nicknameTF;
@synthesize loginNameTF     = _loginNameTF;
@synthesize realnameTF      = _realnameTF;
@synthesize topicTF         = _topicTF;
@synthesize messageTBL      = _messageTBL;
@synthesize nameListTBL     = _nameListTBL;


- (BOOL)isJoin { return [_irc isJoin]; }


#pragma mark -
#pragma mark Initialize Deallocate
/*==============================================================================
 *
 *  initialize
 *
 *==============================================================================*/
- (id)initWithDelegate:(id<MCClientWindowDelegate>)delegate {
    self = [super initWithDelegate:delegate nibName:NIBNAME];
	if (self) {
        _irc = [[MCIRCProtocol alloc] initWithDelegate:self];
        _nameList = [[NSMutableArray alloc] init];
        _consoleLog  = [[NSMutableArray alloc] init];
	}
	return self;
}


//
// deallocate
//
- (void)dealloc {
    RELEASE_NIL_ASSIGN(_irc)
    RELEASE_NIL_ASSIGN(_nameList)
    RELEASE_NIL_ASSIGN(_consoleLog)
    
	[super dealloc];
}




#pragma mark -
#pragma mark Client Start Required Methods
/*==============================================================================
 *
 *  Client ON OFF
 *
 *==============================================================================*/
- (BOOL)startChat {
    [NSApp beginSheet:_startModal modalForWindow:[[self view] window] modalDelegate:self
       didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
    return YES;
}


- (IBAction)goStart:(id)sender {
#define CHECK_EMPTY(X) ((X).length ? (X) : nil)
#define CHECK_EMPTY_NUM(X) ((X) ? (X) : 6667)
    if ( _irc.server = CHECK_EMPTY(_serverTF.stringValue) ) {
        _irc.serverPass = CHECK_EMPTY(_serverPassTF.stringValue);
        _irc.portNumber = CHECK_EMPTY_NUM(_serverPort.intValue);
        
        if (_irc.channel = CHECK_EMPTY(_channelTF.stringValue) ) {
            _irc.channelPass = CHECK_EMPTY(_channellPassTF.stringValue);
            
            if ( _irc.nickname = CHECK_EMPTY(_nicknameTF.stringValue) ) {
                _irc.username = CHECK_EMPTY(_loginNameTF.stringValue);
                _irc.realname = CHECK_EMPTY(_realnameTF.stringValue);
                
                [NSApp endSheet:_startModal returnCode:NSOKButton];
                return;
            }
        }
    }
    
    NSRunAlertPanel(@"MCIRCClient", NSLocalizedString(@"lackInformation", @""), @"O.K.", nil, nil);
#undef CHECK_EMPTY
#undef CHECK_EMPTY_NUM
}


- (IBAction)cancelStart:(id)sender { [NSApp endSheet:_startModal returnCode:NSCancelButton]; }


- (void)sheetDidEnd:(NSWindow*)sheet returnCode:(int)returnCode
        contextInfo:(void*)contextInfo {
    [_startModal orderOut:self];
    
    if (returnCode == NSOKButton) {
        [[[self view] window] setTitle:STRINGFORMAT(kServiceName" - %@ -",_channelTF.stringValue)];
        [_irc startRun];
    }
    else if (returnCode == NSCancelButton) {
        [self.delegate clientEvent:kMCClientLoginCancel message:@"login canceled"];
    }
}


- (void)endChat { [_irc stopRunning]; }






#pragma mark -
#pragma mark Action
/*==============================================================================
 *
 *  Action
 *
 *==============================================================================*/

- (IBAction)sendMessage:(id)sender {
    NSString * message = [sender stringValue];
    if (!message.length) return;
    
    if ( [message hasPrefix:kMCIRCSendRawPrefix] )
        [_irc send:message];
    else
        [_irc sendToChannelWithOperator:kIRCSendOperaterPRIVMSG message:message];
    
    [_messageList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                            message,kMCIRCMessageTBLMessageColumnID,
                            @"ME",kMCIRCMessageTBLMessageColumnID,
                            nil]];
    
    [sender setStringValue:@""];
}



#pragma mark -
#pragma mark IRCDelegate
/*==============================================================================
 *
 *  IRCDelegate
 *
 *==============================================================================*/

- (id)IRCEventOccured:(IRCEvent)event withObject:(id)object {
	if (event >= IRCStoped) {
		[_irc stopRunning];
        [self.delegate clientEvent:kMCClientConnectionError
                           message:STRINGFORMAT(@"IRC stopped.\n%@",object)];
        
        return nil;
	}
    
    id ret = nil;
    switch (event) {
        case IRCConsoleMessage:
            /*
             [_consoleLog addObject:object];
             [_consoleTBL reloadData];
             [_consoleTBL scrollRowToVisible:[_consoleLog count] - 1];
             */
            break;
            
        case IRCNameListStart:
            //
            // Name List
            //
            [_nameList removeAllObjects];
            break;
            
        case IRCNameListEnd:
            [_nameListTBL reloadData];
            break;
            
        case IRCNameListReceiveMine:
            [_nameList insertObject:object atIndex:0];
            break;
            
        case IRCNameListReceive:
            [_nameList addObject:object];
            break;
            
        case IRCGetIP:
            //[CCBIRCIPDictionary setObject:[object objectForKey:@"IP"] forKey:[object objectForKey:@"name"]];
            break;
            
        case IRCModeChanged:
            [[[_nameListTBL tableColumnWithIdentifier:kMCIRCNameListColumnID] headerCell] setStringValue:object];
            break;
            
        case IRCTopicChanged:
            //[_topicTF setStringValue:object];
            break;
            
        case IRCMessageUpdate:;
            NSString * username = [object objectAtIndex:0];
            NSString * message  = [object objectAtIndex:1];
            if ([self.delegate clientGetMessage:message userName:username]) {
                [_messageList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                        username,kMCClientUserNameKey,
                                        message,kMCClientMessageKey,
                                        nil]];
                MCTBLReloadData(_messageTBL, _messageList.count);
            }
            break;
            
        case IRCJoin:
            break;
            
        case IRCEnd:
            [self.delegate clientEvent:kMCClientClosed message:@"IRC closed."];
            break;
            
        default:
            break;
    }
	return ret;
    
}






#pragma mark -
#pragma mark tableview delegate datasource
/*==============================================================================
 *
 *  tableview
 *
 *==============================================================================*/


- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    if (COMPARESTRING([tableView identifier], kMCIRCMessageListTBLID)) {
    NSSize size;
      NSString * message = [[_messageList objectAtIndex:row] objectForKey:kMCClientMessageKey];
      NSDictionary * attribute;
        NSTableColumn * column = [tableView tableColumnWithIdentifier:kMCIRCMessageTBLMessageColumnID];
        NSAttributedString * attributeStr = [[column dataCellForRow:row] attributedStringValue];
      attribute = [attributeStr attributesAtIndex:0 effectiveRange:nil];
    size = [message sizeWithAttributes:attribute];
    
    return size.height;
    }
    else
        return 15.0;
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if      (COMPARESTRING([tableView identifier],kMCIRCNameListTBLID)) return [_nameList   count];
    else if (COMPARESTRING([tableView identifier],kMCIRCMessageListTBLID)) return [_messageList count];
    else
        return 0;
}


- (id)tableView:(NSTableView *)tableView
objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if (COMPARESTRING([tableColumn identifier],kMCIRCNameListColumnID))
        return [_nameList objectAtIndex:row];
    else
        return [[_messageList objectAtIndex:row] objectForKey:[tableColumn identifier]];
    return nil;
}
@end
