//
//  MCLiveTubeClient.m
//  MikanChat
//
//  Created by hsmikan on 8/9/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import "MCLiveTubeClient.h"
#import <WebKit/WebKit.h>

#define NIBNAME @"LiveTube"
#define JSCallKey @"app"
#define EVALUATEJS(SCRIPT) [[_webView windowScriptObject] evaluateWebScript:SCRIPT]


typedef enum {
    kMCLVEventMessage,
    kMCLVEventFirstLoad,
} MCLVEvent;

@implementation MCLiveTubeClient
@synthesize isJoin      =   _isJoin;
@synthesize liveURL     =   _liveURL;
@synthesize messageTBL  =   _messageTBL;
@synthesize usernameTF  =   _usernameTF;
@synthesize messageTF   =   _messageTF;

- (void)dealloc {
    RELEASE(_messageList);
    RELEASE(_webView);
    [super dealloc];
}


- (id)initWithDelegate:(id<MCClientProtocol>)delegate {
    self = [super initWithDelegate:delegate nibName:NIBNAME];
    if (self){
        _webView = [[WebView alloc] init];
    }
    return self;
}

- (void)awakeFromNib {
    [_webView setPolicyDelegate:self];
    [_webView setUIDelegate:self];
    [_webView setFrameLoadDelegate:self];
    
    id wso = [_webView windowScriptObject];
    [wso setValue:self forKey:JSCallKey];
    
    NSBundle * bundle = [NSBundle mainBundle];
    NSString * urlstring = [[bundle URLForResource:@"livetube" withExtension:@"html"] absoluteString];
    [_webView setMainFrameURL:urlstring];
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    
}





#pragma mark -
#pragma mark Required Methods
/*==============================================================================
 *
 *  Required
 *
 *
 *  TODO: Livetubeコメントしゅうとく。
 *      start : タイマースタート
 *          リフレッシュ感覚
 *          チャットIDのしゅうとく
 *      end : タイマーストップ
 *
 *==============================================================================*/

- (BOOL)startChat {
    /*
    NSString * url = _liveURL.stringValue;
    if (!url.length) {
        NSRunAlertPanel(@"Livetube Client", @"不正なURLです。", @"O.K.", nil, nil);
        return NO;
    }
    
    EVALUATEJS( STRINGFORMAT(@"enterChannel('%@')",url) );
    */
    _isJoin = YES;
    return YES;
}


- (void)endChat {
    _isJoin = NO;
    return;
}










#pragma mark -
#pragma mark Actions
/*==============================================================================
 *
 *  Action
 *
 *==============================================================================*/

- (IBAction)sendMessage:(id)sender {
    NSString * message = _messageTF.stringValue;
    
    if (!message.length) return;
    
    EVALUATEJS( STRINGFORMAT(@"postComment('%@','%@')",_usernameTF.stringValue,message) );
    [sender setString:@""];
    
}







#pragma mark -
#pragma mark javascript - cocoa  bridge
/*==============================================================================
 *
 *  js - cocoa
 *
 *==============================================================================*/
- (NSDictionary*)MC_PRIVATE_METHOD_PREPEND(convertPost):(WebScriptObject*)obj {
    /*
     image
     message
     username
     commentNum
     */
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [obj valueForKey:@"username"],kMCClientUserNameKey,
            [obj valueForKey:@"message"],kMCClientMessageKey,
            [obj valueForKey:@"commentNum"],@"commentNum",
            [obj valueForKey:@"image"],@"image",
            nil];
}

- (void)MC_PRIVATE_METHOD_PREPEND(getComment):(WebScriptObject *)obj {
    NSDictionary * msgInfo = [self MC_PRIVATE_METHOD_PREPEND(convertPost):obj];
    
    NSString * name = [msgInfo objectForKey:kMCClientUserNameKey];
    NSString * message = [msgInfo objectForKey:kMCClientMessageKey];
    
    [self.delegate clientGetMessage:message userName:name];
    
    
    NSString * dispayName = STRINGFORMAT(@"%@: %@",[msgInfo objectForKey:@"commentNum"],name);
    [_messageList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                             dispayName,kMCClientUserNameKey,
                             message,kMCClientMessageKey,
                             nil]];
    
    MCTBLReloadData(_messageTBL, _messageList.count);
    
}

- (void)MC_PRIVATE_METHOD_PREPEND(getPosted):(WebScriptObject*)obj {
    NSMutableArray * convertedArr = [NSMutableArray array];
    int i;
    int jsArrNum = (int)[[obj valueForKey:@"length"] integerValue];
    for (i=0;i<jsArrNum;i++) {
        NSDictionary * post =[self MC_PRIVATE_METHOD_PREPEND(convertPost):[obj webScriptValueAtIndex:i]];
        [convertedArr addObject:post];
    }
    
    [_messageList addObjectsFromArray:convertedArr];
    MCTBLReloadData(_messageTBL, _messageList.count);
}


- (void)MC_PRIVATE_METHOD_PREPEND(livetubeEvent):(MCLVEvent)code message:(id)message {
    switch (code) {
        case kMCLVEventMessage:
            [self MC_PRIVATE_METHOD_PREPEND(getComment):message];
            break;
            
        case kMCLVEventFirstLoad:
            [self MC_PRIVATE_METHOD_PREPEND(getPosted):message];
            break;
            
        default:
            break;
    }
}


//
// bridge controlle
//
+ (BOOL)isSelectorExcludedFromWebScript:(SEL)selector{
	if( selector == @selector(MC_PRIVATE_METHOD_PREPEND(livetubeEvent):message:) ){
		return NO;
	}
	
	return YES;
}



//
// bridged method name in JS
//
+ (NSString *)webScriptNameForSelector:(SEL)aSelector {
    if (aSelector == @selector(MC_PRIVATE_METHOD_PREPEND(cavetubeEvent):message:))
        return @"ltevent";
    
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
	NSRunAlertPanel(@"CaveTube", message, @"OK", nil, nil);
}



- (BOOL)webView:(WebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame {
	DLOG(@"javascript calls confirm");
	NSInteger choice = NSRunAlertPanel(@"CaveTube", message, @"OK", @"Cancel", nil);
	return choice == NSAlertDefaultReturn;
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
    NSString * message = [[_messageList objectAtIndex:row] objectForKey:kMCClientMessageKey];
    NSDictionary * attribute;
    NSTableColumn * column = [tableView tableColumnWithIdentifier:kMCClientMessageKey];
    NSAttributedString * attributeStr = [[column dataCellForRow:row] attributedStringValue];
    attribute = [attributeStr attributesAtIndex:0 effectiveRange:nil];
    size = [message sizeWithAttributes:attribute];
    
    return size.height;
}

@end
