//
//  MCUpdatesController.m
//  MikanChat
//
//  Created by hsmikan on 8/22/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import "MCUpdatesController.h"

#ifdef DEBUG
#define kFEEDURL @"file:///Users/hsmikan/Documents/MyPrograms/Xcode4/MikanChat/MikanChat.xml"
#else
#define kFEEDURL @"http://www.waterbolt.info/apps/feed/MikanChat.xml"
#endif

#define kDOWNLOADURL @"http://www.waterbolt.info/~hsmikan/blog/?page_id=179#license"

@interface MCUpdatesController () <NSWindowDelegate,NSXMLParserDelegate>

@end

@implementation MCUpdatesController

@synthesize isUpToDate = _isUpToDate;
@synthesize downloadPageBT = _downloadPageBT;
@synthesize updateStatement = _updateStatement;
@synthesize messageTF = _notesTF;


- (void)dealloc {
    RELEASE(_notes);
    RELEASE(_latestVersion);
    [super dealloc];
}
- (void)windowWillClose:(NSNotification *)notification {
    [self release];
}




- (id)init {
    self = [super initWithWindowNibName:@"MCUpdatesController"];
    if (self) {
        _isUpToDate = NO;
        _notes = [[NSMutableString alloc] init];
        _currentBuild = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] intValue];
        _latestBuild = _currentBuild;
        
        NSURL       * url       = [NSURL URLWithString:kFEEDURL];
        NSData      * data      = [NSData dataWithContentsOfURL:url];
        NSXMLParser * parser    = [[[NSXMLParser alloc] initWithData:data] autorelease];
        parser.delegate         = self;
        [parser parse];
    }
    
    return self;
}


- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [[self window] setDelegate:self];
    
    
    if (_isUpToDate) {
        [_updateStatement setStringValue:STRINGFORMAT(@"New Version : %@ is available.",_latestVersion)];
        [_notesTF setStringValue:_notes];
        [_downloadPageBT setEnabled:YES];
    }
    else {
        [_updateStatement setStringValue:@"Up to date."];
    }

}



- (IBAction)openDownloadPage:(id)sender {
    NSURL * url = [NSURL URLWithString:kDOWNLOADURL];
    [[NSWorkspace sharedWorkspace] openURL:url];
}



#pragma mark -
#pragma mark NSXMLparser delegate
/*==============================================================================
 *
 *  xml delegate
 *
 *==============================================================================*/
#define kMCFeedVersionAttributes @"version"
#define kMCFeedBuildAttributes   @"build"
#define kMCFeedTag               @"item"

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (isUpdateNotes)
        [_notes appendString:string];
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    
}
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    NSString * version = [attributeDict objectForKey:@"version"];
    int build = [[attributeDict objectForKey:@"build"] intValue];
    if (_latestBuild < build) {
        _latestBuild = build;
        
        [_latestVersion autorelease];
        _latestVersion = [STRINGFORMAT(@"%@(%d)",version,build) copy];
        
        isUpdateNotes = YES;
        
        [_notes setString:@""];
    }
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    isUpdateNotes = NO;
}
- (void)parserDidEndDocument:(NSXMLParser *)parser {
    if (_latestBuild > _currentBuild) {
        _isUpToDate = YES;
    }
}


@end
