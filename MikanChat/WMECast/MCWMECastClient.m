//
//  MCWMECastClient.m
//  MikanChat
//
//  Created by hsmikan on 8/26/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import "MCWMECastClient.h"
#import <WebKit/WebKit.h>

#import "../NSString/NSString+MCRegex.h"

#define JSCallKey @"app"
#define EVALUATEJS(SCRIPT) [[_webView windowScriptObject] evaluateWebScript:SCRIPT]


typedef enum {
    kMCWMEMESSAGEEVENT = 0,
    kMCWMEFIRSTLOADEVENT = 1,
} MCWMEEVENT;

@interface MCWMECastClient ()

@end

@implementation MCWMECastClient
@synthesize liveURLTF = _liveURLTF;
@synthesize messageTBL = _messageTBL;
@synthesize usernameTF = _usernameTF;

- (void)dealloc {
    RELEASE(_webView);
    [super dealloc];
}

- (id)initWithDelegate:(id<MCClientWindowDelegate>)delegate {
    self = [super initWithDelegate:delegate nibName:@"MCWMECastClient"];
    if (self) {
        _webView = [[WebView alloc] init];
    }
    return self;
}

- (void)awakeFromNib {
    _webView.UIDelegate = self;
    _webView.policyDelegate = self;
    _webView.frameLoadDelegate = self;
    id wso = [_webView windowScriptObject];
    [wso setValue:self forKey:JSCallKey];
    
    NSBundle * bundle = [NSBundle mainBundle];
    NSString * urlstring = [[bundle URLForResource:@"wmecast" withExtension:@"html"] absoluteString];
    _webView.mainFrameURL = urlstring;
}


- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    
}








- (BOOL)startChat {
    NSString * liveid = [[_liveURLTF.stringValue componentsSeparatedByString:@"/"] lastObject];
    if ([liveid isMatchedByRegex:@"[0-9a-z]+"]) {
        EVALUATEJS( STRINGFORMAT(@"enterChannel('%@')",liveid) );
        return YES;
    }
    else {
        NSRunAlertPanel(@"WMECast Client", @"Invalid URL/LIVE ID", @"O.K.", nil, nil);
        return NO;
    }
}

- (void)endChat {
    EVALUATEJS(@"exitChannel()");
}




- (IBAction)sendMessage:(id)sender {
    NSString * message = [sender stringValue];
    
    if (!message.length) return;
    
    NSString * name = [_usernameTF stringValue];
    EVALUATEJS( STRINGFORMAT(@"postMessage('%@','%@')",name,message) );
}










- (void)MC_PRIVATE_METHOD_PREPEND(firstLoad):(WebScriptObject*)obj {
    NSMutableArray * posted = [NSMutableArray array];
    int n = [[obj valueForKey:@"length"] intValue];
    int i;
    for (i=0; i<n; i++) {
        NSString * name = [[obj webScriptValueAtIndex:i] valueForKey:@"username"];
        NSString * message = [[obj webScriptValueAtIndex:i] valueForKey:@"message"];
        [posted addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                 message,kMCClientMessageKey,
                                 name,kMCClientUserNameKey,
                                 nil]];
    }
    
    [_messageList addObjectsFromArray:posted];
    MCTBLReloadData(_messageTBL, _messageList.count);
}

- (void)MC_PRIVATE_METHOD_PREPEND(catchComment):(WebScriptObject*)obj {
    int n = [[obj valueForKey:@"length"] intValue];
    int i;
    for (i=0; i<n; i++) {
        NSString * name = [[obj webScriptValueAtIndex:i] valueForKey:@"username"];
        NSString * message = [[obj webScriptValueAtIndex:i] valueForKey:@"message"];
        [_messageList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                 message,kMCClientMessageKey,
                                 name,kMCClientUserNameKey,
                                 nil]];
        [self.delegate clientGetMessage:message userName:name];
    }
    MCTBLReloadData(_messageTBL, _messageList.count);
}



- (void)MC_PRIVATE_METHOD_PREPEND(wmeCastEvent):(MCWMEEVENT)eventCode message:(id)message {
    switch(eventCode) {
        case kMCWMEFIRSTLOADEVENT:
            [self MC_PRIVATE_METHOD_PREPEND(firstLoad):message];
            break;
        case kMCWMEMESSAGEEVENT:
            [self MC_PRIVATE_METHOD_PREPEND(catchComment):message];
            break;
        default:
            break;
    }
}






//
// bridge controlle
//
+ (BOOL)isSelectorExcludedFromWebScript:(SEL)selector{
	if( selector == @selector(MC_PRIVATE_METHOD_PREPEND(wmeCastEvent):message:) ){
		return NO;
	}
	
	return YES;
}



//
// bridged method name in JS
//
+ (NSString *)webScriptNameForSelector:(SEL)aSelector {
    if (aSelector == @selector(MC_PRIVATE_METHOD_PREPEND(wmeCastEvent):message:))
        return @"wmeevent";
    
	return nil;
}


+ (BOOL)isKeyExcludedFromWebScript:(const char *)name {	return NO; }




#pragma mark -
#pragma mark UIDelegate
/*==============================================================================
 *
 * dialog
 *
 *==============================================================================*/
-(void)webView:(WebView *)sender
runJavaScriptAlertPanelWithMessage:(NSString *)message
initiatedByFrame:(WebFrame *)frame
{
	DLOG(@"javascript calls alert");
	NSRunAlertPanel(@"WMECast", message, @"OK", nil, nil);
}



- (BOOL)webView:(WebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame {
	DLOG(@"javascript calls confirm");
	NSInteger choice = NSRunAlertPanel(@"WMECast", message, @"OK", @"Cancel", nil);
	return choice == NSAlertDefaultReturn;
}






- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    NSSize size;
    NSString * message = [[_messageList objectAtIndex:row] objectForKey:kMCClientMessageKey];
    NSDictionary * attribute;
    NSTableColumn * column = [tableView tableColumnWithIdentifier:kMCClientMessageKey];
    NSAttributedString * attributeStr = [[column dataCellForRow:row] attributedStringValue];
    attribute = [attributeStr attributesAtIndex:0 effectiveRange:nil];
    size = [message sizeWithAttributes:attribute];
    
    return size.height;
}



- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView { return _messageList.count; }


- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return [[_messageList objectAtIndex:row] objectForKey:[tableColumn identifier]];
}
@end
