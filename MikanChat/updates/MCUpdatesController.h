//
//  MCUpdatesController.h
//  MikanChat
//
//  Created by hsmikan on 8/22/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MCUpdatesController : NSWindowController {
    NSMutableString * _notes;
    NSString * _latestVersion;
    int _currentBuild;
    int _latestBuild;
    BOOL isUpdateNotes;
}
@property (readonly) BOOL isUpToDate;
@property (assign) IBOutlet NSTextField *updateStatement;
@property (assign) IBOutlet NSTextField *messageTF;
- (IBAction)openDownloadPage:(id)sender;
@property (assign) IBOutlet NSButton *downloadPageBT;

@end
