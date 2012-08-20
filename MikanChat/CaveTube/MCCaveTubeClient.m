//
//  MCCaveTubeClient.m
//  MikanChat
//
//  Created by hsmikan on 8/9/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//


/* MEMEO
 FIXME: [_liveURLTF setEnable:] の タイミング
 */


#import "MCCaveTubeClient.h"
#import "MCCaveTubeClientConstants.h"

#import "../NSString/NSString+MCRegex.h"

#define NIBNAME @"CaveTubeView"
#define kServiceName @"CaveTube"
#define kMCCavetubeUserNameForReadingKey @"CavetubeForRead"
#define kMCCVTBLUserNameColumnKey @"MCCVTBLUserNameColumn"
#define kMCCVTBLMessageColumnKey  @"MCCVTBLMessageColumn"

#define kMCCVUserIconURLKey @"MCCVUserIconURL"
#define kMCCVIsAuthorizedUserKey @"MCCVISAUTHORIZEDUSER"


#import <WebKit/WebKit.h>



#define JSCallKey @"cavetube"

#define EvalJS(...) [[_webView windowScriptObject] evaluateWebScript:[NSString stringWithFormat:__VA_ARGS__]];
#define Join(LIVEID) @"joinChannel('%@')",(LIVEID)
#define Leave @"leaveChannel()"


typedef enum {
    kMCCVEventNewMessage = 0,
    kMCCVEventPostedMessages,
    kMCCVEventReady,
    kMCCVEventStartEntry,
    kMCCVEventCloseEntry,
    kMCCVEventBan,
    kMCCVEventJoin,
    kMCCVEventLeave,
    kMCCVEventConnected,
    kMCCVEventUnready,
    kMCCVEventSet,
    
    kMCCVEventError = 400,
#ifdef DEBUG
    kMCCVEventTest = 1000,
#endif
} MCCVEventCode;


@interface MCCaveTubeClient () <NSTableViewDataSource,NSTableViewDelegate>
- (void)MC_PRIVATE_METHOD_PREPEND(addNewPost):(WebScriptObject*)post;
- (void)MC_PRIVATE_METHOD_PREPEND(addNewPosts):(WebScriptObject*)posts;
@end

@implementation MCCaveTubeClient

@synthesize isReadCommentNumber = _isReadCommentNumber;
@synthesize liveURLTF = _liveURLTF;
@synthesize messageTBL = _messageTBL;
@synthesize username = _username;
@synthesize isJoin = _isJoin;
@synthesize delegate = _delegate;
- (void)awakeFromNib {
    _webView = [[WebView alloc] init];
    {
        [_webView setPolicyDelegate:self];
        [_webView setUIDelegate:self];
        [_webView setFrameLoadDelegate:self];

        id wso = [_webView windowScriptObject];
        [wso setValue:self forKey:JSCallKey];
        
        NSBundle * bundle = [NSBundle mainBundle];
        NSString * urlstring = [[bundle URLForResource:@"cavetube" withExtension:@"html"] absoluteString];
        [_webView setMainFrameURL:urlstring];
    }
    
    [_liveURLTF setEnabled:NO];
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    
}

- (id)initWithDelegate:(id<MCClientProtocol>)delegate {
    self = [super initWithDelegate:delegate nibName:NIBNAME];
    if (self) {
        _isJoin = NO;
        _messageList = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    EvalJS(Leave);
    [_webView release];
    [_messageList release];
    
    [super dealloc];
}






#pragma mark -
#pragma mark Chat Comunicate
/*==============================================================================
 *
 *  Chat Comunicate
 *
 *==============================================================================*/

- (BOOL)startChat {
    NSString * liveID = [[[_liveURLTF stringValue] componentsSeparatedByString:@"/"] lastObject];
    if (liveID.length && [liveID isMatchedByRegex:@"[A-Z0-9]+"] ){
        _isJoin = YES;
        EvalJS(Join(liveID));
        [_liveURLTF setStringValue:liveID];
        [_liveURLTF setEnabled:NO];
        
        
        [_messageList removeAllObjects];
        [_messageTBL reloadData];
        
        return YES;
    }
    else {
        NSRunAlertPanel(@"MikanChat - cavetube -", @"不正なチャンネル名です。", @"O.K.", nil, nil);
    }
    
    return NO;
}


- (void)MC_PRIVATE_METHOD_PREPEND(endChat) {
    _isJoin = NO;
    [_liveURLTF setEnabled:YES];
}

- (void)endChat {
    EvalJS(Leave);
    [self MC_PRIVATE_METHOD_PREPEND(endChat)];
//    [_webView reload:self];
}



- (IBAction)sendMessage:(id)sender {
    NSString * message = [sender stringValue];
    NSString * username = [_username stringValue];
    if (message.length) {
        EvalJS(@"sendMessage('%@','%@')",username,message);
        [sender setStringValue:@""];
    }
}







#pragma mark -
#pragma mark New JS Post Data
/*==============================================================================
 *
 *  New JS Post Data
 *
 *==============================================================================*/
//
// Convert JS Data
//
 /*{
- "mode": "post",
- "comment_num": 1,
- "name": "hoge",
- "message": "コメント内容",
 "user_id": "I1MJRQP",
 "time": 1336212176466,
 "is_ban": false,
- "auth": true,
 "user_icon": "http://img.cavelis.net/userimage/m/hoge.jpg"
 }
 */

#define JSValueForKey(KEY) [jsObject valueForKey:KEY]
- (NSDictionary *)MC_PRIVATE_METHOD_PREPEND(convertPost):(WebScriptObject *)jsObject {
    NSString * username = JSValueForKey(@"name");
    NSNumber * commentNum = JSValueForKey(@"comment_num");
    
    NSString * nameForReading;
    if ([_isReadCommentNumber state])
        nameForReading = STRINGFORMAT(@"%@番、%@",commentNum,username);
    else
        nameForReading = username;
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            STRINGFORMAT(@"%@: %@",commentNum,username),kMCClientUserNameKey,
            JSValueForKey(@"message"),kMCClientMessageKey,
            JSValueForKey(@"user_icon"),kMCCVUserIconURLKey,
            nameForReading, kMCCavetubeUserNameForReadingKey,
            JSValueForKey(@"auth"),kMCCVIsAuthorizedUserKey,
            nil];
}
- (NSArray *)MC_PRIVATE_METHOD_PREPEND(convertedPosts):(WebScriptObject*)jsObject {
    NSMutableArray * convertedArr = [NSMutableArray array];
     int i;
     int jsArrNum = (int)[[jsObject valueForKey:@"length"] integerValue];
     for (i=0;i<jsArrNum;i++) {
         NSDictionary * post =[self MC_PRIVATE_METHOD_PREPEND(convertPost):[jsObject webScriptValueAtIndex:i]];
         [convertedArr addObject:post];
     }
    
    return convertedArr;
}
#undef JSValueForKey


//
// Add New Post
//
- (void)MC_PRIVATE_METHOD_PREPEND(addNewPost):(WebScriptObject*)post {
    NSDictionary * postinfo = [self MC_PRIVATE_METHOD_PREPEND(convertPost):post];
    [_messageList addObject:postinfo];
    MCTBLReloadData(_messageTBL, _messageList.count);
    
    //
    // upsteam - delegate
    //
    [self.delegate clientGetMessage:[postinfo objectForKey:kMCClientMessageKey]
                       userName:[postinfo objectForKey:kMCCavetubeUserNameForReadingKey]];
}
- (void)MC_PRIVATE_METHOD_PREPEND(addNewPosts):(WebScriptObject *)posts {
    NSArray * postarr = [self MC_PRIVATE_METHOD_PREPEND(convertedPosts):posts];
    [_messageList addObjectsFromArray:postarr];
    MCTBLReloadData(_messageTBL, _messageList.count);
}






#pragma mark -
#pragma mark javascript - cocoa  bridge
/*==============================================================================
 *
 *  js - cocoa
 *
 *==============================================================================*/
- (void)MC_PRIVATE_METHOD_PREPEND(cavetubeEvent):(int)code message:(id)message {
    switch (code) {
#ifdef DEBUG
        case kMCCVEventTest:
            DLOG(@"test console : %@",message);
            break;
#endif
        case kMCCVEventConnected:
            [_liveURLTF setEnabled:YES];
            break;
        case kMCCVEventNewMessage:
            [self MC_PRIVATE_METHOD_PREPEND(addNewPost):message];
            break;
            
        case kMCCVEventPostedMessages:;
            [self MC_PRIVATE_METHOD_PREPEND(addNewPosts):message];
            break;
            
        case kMCCVEventReady:
            break;
        case kMCCVEventUnready:
            break;
        case kMCCVEventSet:
            [_liveURLTF setStringValue:message];
            break;
        case kMCCVEventStartEntry:
        case kMCCVEventCloseEntry:
        case kMCCVEventBan:
        case kMCCVEventJoin:
        case kMCCVEventLeave:
            break;
            
        case kMCClientError://400
        case kMCClientConnectionError://401
            [self MC_PRIVATE_METHOD_PREPEND(endChat)];
            [self.delegate clientEvent:kMCClientError message:message];
            break;
            
        default:
            break;
    }
}


//
// bridge controlle
//
+ (BOOL)isSelectorExcludedFromWebScript:(SEL)selector{
	if( selector == @selector(MC_PRIVATE_METHOD_PREPEND(cavetubeEvent):message:) ){
		return NO;
	}
	
	return YES;
}



//
// bridged method name in JS
//
+ (NSString *)webScriptNameForSelector:(SEL)aSelector {
    if (aSelector == @selector(MC_PRIVATE_METHOD_PREPEND(cavetubeEvent):message:))
        return @"cvevent";
    
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
	NSRunAlertPanel(@"CaveTube", message, @"OK", nil, nil);
}



- (BOOL)webView:(WebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame {
	DLOG(@"javascript calls confirm");
	NSInteger choice = NSRunAlertPanel(@"CaveTube", message, @"OK", @"Cancel", nil);
	return choice == NSAlertDefaultReturn;
}



@end








#pragma mark -
#pragma mark TableView Delegate Datasource
/*==============================================================================
 *
 *  tableveiew delegate datasource
 *
 *==============================================================================*/
@interface MCCaveTubeClient (tableViewDelegate) <NSTableViewDataSource,NSTableViewDelegate>
@end
@implementation MCCaveTubeClient (tableViewDelegate)


- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (COMPARESTRING([tableColumn identifier], kMCCVTBLUserNameColumnKey)) {
        if ([[_messageList objectAtIndex:row] boolForKey:kMCCVIsAuthorizedUserKey])
            [cell setTextColor:[NSColor blueColor]];
        else
            [cell setTextColor:[NSColor blackColor]];
    }
    
}


- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    NSSize size;
      NSString * message = [[_messageList objectAtIndex:row] objectForKey:kMCClientMessageKey];
      NSDictionary * attribute;
        NSTableColumn * column = [tableView tableColumnWithIdentifier:kMCCVTBLMessageColumnKey];
        NSAttributedString * attributeStr = [[column dataCellForRow:row] attributedStringValue];
      attribute = [attributeStr attributesAtIndex:0 effectiveRange:nil];
    size = [message sizeWithAttributes:attribute];
    
    return size.height;
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView { return [_messageList count]; }


- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if      (COMPARESTRING([tableColumn identifier], kMCCVTBLUserNameColumnKey))
        return [[_messageList objectAtIndex:row] objectForKey:kMCClientUserNameKey];
    
    else if (COMPARESTRING([tableColumn identifier], kMCCVTBLMessageColumnKey))
        return [[_messageList objectAtIndex:row] objectForKey:kMCClientMessageKey];
    
    return nil;
}

@end