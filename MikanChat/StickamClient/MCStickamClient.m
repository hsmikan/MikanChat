//
//  MCStickamClient.m
//  MikanChat
//
//  Created by hsmikan on 8/19/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import "MCStickamClient.h"
#import <WebKit/WebKit.h>
#import "../NSString/NSString+MCRegex.h"
#import "../NSCollorWell/NSColorWell+MCCategory.h"


#define NIBNAME @"MCStickamClient"
#define JSCallKey @"app"

#define EVALUATEJS(SCRIPT) [[_webView windowScriptObject] evaluateWebScript:SCRIPT]



typedef enum {
    kMCStickamConsoleEvent = 1000,
    kMCStickamMessageEvent = 0,
    kMCStickamSuccessAuthEvent = 1,
    kMCStickamFailAuthEvent = 2,
} MCStickamEventCode;

@interface MCStickamClient ()
- (NSDictionary*)MC_PRIVATE_METHOD_PREPEND(convertFontInfo):(WebScriptObject*)webObj;
- (void)MC_PRIVATE_METHOD_PREPEND(getComment):(WebScriptObject*)webObj;
@end



@implementation MCStickamClient


@synthesize isJoin = _isJoin;
@synthesize webView = _webView;
@synthesize loginModalPanel = _loginModalPanel;
@synthesize loginUserEmail = _loginUserEmail;
@synthesize loginUserPassword = _loginUserPassword;
@synthesize liveURLTF = _liveURLTF;
@synthesize nicknameTF = _nicknameTF;
@synthesize messageTBL      = _messageTBL;
@synthesize isBoldCommentBT = _isBoldCommentBT;
@synthesize isItalicCommentBT = _isItalicCommentBT;
@synthesize isUnderlineCommentBT = _isUnderlineCommentBT;
@synthesize commentColorWell = _commentColorWell;
@synthesize fontPBT = _fontPBT;
@synthesize fontSizePBT = _fontSizePBT;


- (void)dealloc {
    if (_isJoin)
        EVALUATEJS(@"exitChat()");
    if (_isAuth)
        EVALUATEJS(@"logout()");
    
    [super dealloc];
}



- (id)initWithDelegate:(id<MCClientWindowDelegate>)delegate {
    self = [super initWithDelegate:delegate nibName:NIBNAME];
    if (self){
        _isJoin = NO;
        _isAuth = NO;
    }
    return self;
}

- (void)awakeFromNib {
    [_webView setPolicyDelegate:self];
    [_webView setUIDelegate:self];
    [_webView setFrameLoadDelegate:self];
    
    WebScriptObject * wso = [_webView windowScriptObject];
    [wso setValue:self forKey:JSCallKey];
#ifdef DEBUG
    //FIXME: local sever response 403
    //[_webView setMainFrameURL:@"http://localhost/~hsmikan/debug/stickam/debug.html"];
    [_webView setMainFrameURL:@"http://www.waterbolt.info/apps/MikanChat/html/debug/stickam.html"];
#else
    [_webView setMainFrameURL:@"http://www.waterbolt.info/apps/MikanChat/html/release/stickam.html"];
#endif
    
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    // TODO: login
    /*
    [NSApp beginSheet:_loginModalPanel modalForWindow:[[self view] window] modalDelegate:self
       didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
     */
}




#pragma mark -
#pragma mark Chat start & end
/*==============================================================================
 *
 *  Chat START END
 *
 *==============================================================================*/
- (IBAction)login:(id)sender {
    if (!_loginUserEmail.stringValue.length || !_loginUserPassword.stringValue.length) {
        NSRunAlertPanel(@"StickamClient", NSLocalizedString(@"lackInformation", @""), @"O.K.", nil, nil);
        return;
    }
    
    if (![_loginUserEmail.stringValue isMatchedByRegex:@"^.+@.+\\..+$"]) {
        NSRunAlertPanel(@"Stickam Client", NSLocalizedString(@"notEmail", @""), @"O.K.", nil, nil);
        return;
    }
    
    EVALUATEJS(STRINGFORMAT(@"login('%@','%@')",_loginUserEmail.stringValue,_loginUserPassword.stringValue));
}


- (IBAction)noLogin:(id)sender { [NSApp endSheet:_loginModalPanel returnCode:NSCancelButton]; }


- (void)sheetDidEnd:(NSWindow*)sheet returnCode:(int)returnCode contextInfo:(void*)contextInfo {
    [_loginModalPanel orderOut:self];
    
    switch (returnCode) {
        case NSOKButton:
        case NSCancelButton:
        default:
            break;
    }
}

- (BOOL)startChat {
    NSString * url = _liveURLTF.stringValue;
    if (url.length==0 || ![url isMatchedByRegex:@"^http://www.stickam.jp/profile/[a-z0-9_]+$"]) {
        NSRunAlertPanel(@"Stickam", @"Invalid URL.", @"O.K.", nil, nil);
        return NO;
    }
    
    NSString * nickname = _nicknameTF.stringValue;
    NSString * joinScript = nil;
    if (nickname.length)
        joinScript = STRINGFORMAT(@"joinChat('%@','%@');",url,nickname);
    else {
        if (!_isAuth){
            NSRunAlertPanel(@"Stickam", @"Invalid Nicknaem.", @"O.K.", nil, nil);
            return NO;
        }
        joinScript = STRINGFORMAT(@"joinChat('%@');",url);
    }
    EVALUATEJS(joinScript);
    
    return _isJoin = YES;
}



- (void)endChat{
    EVALUATEJS(@"exitChat()");
    _isJoin = NO;
}



- (IBAction)setNickname:(id)sender {
    NSString * name = [sender stringValue];
    if (name.length) {
        EVALUATEJS( STRINGFORMAT( @"setNickname('%@')",name) );
    }
}

- (IBAction)sendMessage:(id)sender {
    NSString * message = [sender stringValue];
    
    if (message.length) {
        /*
         パラメータ
         text	発言内容	文字列
         font	フォント
         size	サイズ
         color	色
         bold	太字かどうか	true,false
         italic	斜体かどうか	true,false
         underline	下線をつけるか	true,false
         */
        // var post = function(text, font, size, color, bold, italic, underline){roomSay(text, font, size, color, bold, italic, underline)};
        EVALUATEJS(STRINGFORMAT(@"post('%@','%@',%@,'%@',%@,%@,%@)",
                                /* message */       message,
                                /* font */          [[_fontPBT selectedItem] title],
                                /* font size */     [[_fontSizePBT selectedItem] title],
                                /* font color */    [_commentColorWell hexColor],
                                /* is bold */       ([_isBoldCommentBT state] ? @"true" : @"false"),
                                /* is itaic */      ([_isItalicCommentBT state] ? @"true" : @"false"),
                                /* is underline */  ([_isUnderlineCommentBT state] ? @"true" : @"false")
                                ));
    }
    
    [sender setStringValue:@""];
}





#pragma mark -
#pragma mark javascript - cocoa  bridge
/*==============================================================================
 *
 *  js - cocoa
 *
 *==============================================================================*/

- (void)MC_PRIVATE_METHOD_PREPEND(catchStickamEvent):(MCStickamEventCode)eventCode contextInfo:(id)context {
    switch(eventCode) {
        case kMCStickamMessageEvent:
            [self MC_PRIVATE_METHOD_PREPEND(getComment):context];
            break;
        
        case kMCStickamSuccessAuthEvent:
            _isAuth = YES;
            [NSApp endSheet:_loginModalPanel returnCode:NSOKButton];
            break;
            
        case kMCStickamFailAuthEvent:
            _isAuth = NO;
            NSRunAlertPanel(@"Stickcam Client", @"Filed Sign in.", @"O.K.", nil, nil);
            DLOG(@"%@",context);
            break;
            
        default:
            break;
    }
}


//
// bridge controlle
//
+ (BOOL)isSelectorExcludedFromWebScript:(SEL)selector{
	if( selector == @selector(MC_PRIVATE_METHOD_PREPEND(catchStickamEvent):contextInfo:)){
		return NO;
	}
	
	return YES;
}



//
// bridged method name in JS
//
+ (NSString *)webScriptNameForSelector:(SEL)aSelector {
    if (aSelector == @selector(MC_PRIVATE_METHOD_PREPEND(catchStickamEvent):contextInfo:))
        return @"stevent";
    
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
initiatedByFrame:(WebFrame *)frame{
	DLOG(@"javascript calls alert");
	NSRunAlertPanel(@"Stickam", message, @"OK", nil, nil);
}



- (BOOL)webView:(WebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame {
	DLOG(@"javascript calls confirm");
	NSInteger choice = NSRunAlertPanel(@"Stickam", message, @"OK", @"Cancel", nil);
	return choice == NSAlertDefaultReturn;
}








#pragma mark -
#pragma mark PRIVATE
/*==============================================================================
 *
 *  PRIVATE
 *
 *==============================================================================*/


- (NSDictionary*)MC_PRIVATE_METHOD_PREPEND(convertFontInfo):(WebScriptObject*)webObj {
    /*    パラメータ
     名前	意味	値
     nickname 名前 文字列
     text	発言内容	文字列
     font	フォント
     size	サイズ
     color	色
     bold	太字かどうか	true,false
     italic	斜体かどうか	true,false
     underline	下線をつけるか	true,false
     */
    NSMutableDictionary * attributes = [NSMutableDictionary dictionary];
    
	// Font-color
    {
        NSColor * color = [NSColorWell hex2NSColor:[webObj valueForKey:@"color"]];
        [attributes setObject:color forKey:NSForegroundColorAttributeName];
    }
    
    
	// Font-Family
    /*
     // none _sans, MS Sans Serif
     // Bold NOne
     //		Tahoma
     // Italic none
     //		Comic Sans MS, Thoma
     */
    NSString        * font = nil;
    NSMutableString * fontFamily = nil;
    {
        font = [webObj valueForKey:@"font"];
        if ([font isEqualToString:@"_sans"] || [font isEqualToString:@"MS Sans Serif"]) {
            // _sans and "MS Sans Serif" is invalid in Mac
            //  use "Arial" instead of those
            fontFamily = [NSMutableString stringWithString:@"Helvetica"];
        }
        else {
            fontFamily = [NSMutableString stringWithString:font];
        }
    }
	
    
    // font size
    CGFloat fontSize = [[webObj valueForKey:@"size"] floatValue];
    {
        [attributes setObject:[NSFont fontWithName:fontFamily size:fontSize]
                       forKey:NSFontAttributeName];
    }
    
	// font options, Bold and/or Italic
	if ([[webObj valueForKey:@"bold"] boolValue]){//[bold intValue]){
		if ([font isEqualToString:@"Tahoma"]){
			[fontFamily setString:@"Helvetica"];
		}
		[fontFamily appendString:@" Bold"];
	}
	if ([[webObj valueForKey:@"italic"] boolValue]){//[italic intValue] ) {
		if ([font isEqualToString:@"Comic Sans MS"] || [font isEqualToString:@"Tahoma"]){
			[fontFamily setString:@"Helvetica"];
		}
		[fontFamily appendString:@" Italic"];
	}
    
	//
	// add Font-Family and Font-size
	//	to attibutes Dictionay
	//
	[attributes removeObjectForKey:NSFontAttributeName];
	[attributes setObject:[NSFont fontWithName:fontFamily
										  size:fontSize]
				   forKey:NSFontAttributeName];
	//
	// underline
	//
	if ([[webObj valueForKey:@"underline"] boolValue])//[underline intValue])
		[attributes setObject:[NSNumber numberWithBool:YES] forKey:NSUnderlineStyleAttributeName];
	
    return attributes;
}


- (void)MC_PRIVATE_METHOD_PREPEND(getComment):(WebScriptObject*)webObj {
    NSString * message = [webObj valueForKey:@"text"];
    NSString * nickname = [webObj valueForKey:@"nickname"];
    
    if (![self.delegate clientGetMessage:message userName:nickname clienID:kMCClientStickamIDNumber])
        return;
    
    
    NSDictionary * attributes = [self MC_PRIVATE_METHOD_PREPEND(convertFontInfo):webObj];
    NSAttributedString *attrNickname = [[[NSAttributedString alloc] initWithString:nickname attributes:attributes] autorelease];
	NSAttributedString *attrMessage  = [[[NSAttributedString alloc] initWithString:message attributes:attributes] autorelease];
	
	[_messageList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                             [attrNickname copy],kMCClientUserNameKey,
                             [attrMessage copy],kMCClientMessageKey,
                             nil]];
    MCTBLReloadData(_messageTBL, _messageList.count);
}






#pragma mark -
#pragma mark TableView Delegate Datasource
/*==============================================================================
 *
 *  tableveiew delegate datasource
 *
 *==============================================================================*/


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _messageList.count;
}


- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return [[_messageList objectAtIndex:row] objectForKey:[tableColumn identifier]];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    NSSize size;
    NSAttributedString * attrMessage = [[_messageList objectAtIndex:row] objectForKey:kMCClientMessageKey];
    NSDictionary * attribute;
//    NSTableColumn * column = [tableView tableColumnWithIdentifier:kMCClientMessageKey];
//    NSAttributedString * attributeStr = [[column dataCellForRow:row] attributedStringValue];
    attribute = [attrMessage attributesAtIndex:0 effectiveRange:nil];
    size = [[attrMessage string] sizeWithAttributes:attribute];
    
    return size.height;
}

@end
