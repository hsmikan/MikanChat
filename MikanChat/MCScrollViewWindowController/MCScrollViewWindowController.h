//
//  MCScrollViewWindowController.h
//  MikanChat
//
//  Created by hsmikan on 9/13/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define HSMScrollViewerFontSize @"HSMFontSize"
#define HSMScrollViewerFontColor @"HSMFontColor"
#define HSMScrollViewerDuration @"HSMDuration"


@class MCScrollView;
@interface MCScrollViewWindowController : NSWindowController {
    MCScrollView * _contentView;
}
- (void)lockWindow;
- (void)unlockWindow;
- (void)scrollString:(NSString *)string attributes:(NSDictionary *)attributes;
- (void)changeBackgroundColor:(NSColor*)color;
- (void)setIsShowBorder:(BOOL)isShow;

//
// initだけを使うようにしたい
//
- (id)initWithWindow:(NSWindow *)window DEPRECATED_ATTRIBUTE;
- (id)initWithWindowNibName:(NSString *)windowNibName DEPRECATED_ATTRIBUTE;
- (id)initWithWindowNibName:(NSString *)windowNibName owner:(id)owner DEPRECATED_ATTRIBUTE;
- (id)initWithWindowNibPath:(NSString *)windowNibPath owner:(id)owner DEPRECATED_ATTRIBUTE;
@end
