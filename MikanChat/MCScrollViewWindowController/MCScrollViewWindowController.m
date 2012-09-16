//
//  MCScrollViewWindowController.m
//  MikanChat
//
//  Created by hsmikan on 9/13/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import "MCScrollViewWindowController.h"
#import <QuartzCore/CoreAnimation.h>
#import "../NSUserDefaults+myColorSuports/NSUserDefaults+myColorSupport.h"
#import "../MCUserDefaultsKeys.h"

#define kAnimationRate 500.0f


@interface MCScrollView : NSView {
    CALayer * _rootLayer;
}

CABasicAnimation * createAnimation(CALayer const * rootLayer,CGFloat const duration,NSSize const stringSize,NSSize const viewSize);
CGFloat getNextRow(CALayer const * rootLayer, CGFloat const strHeight,NSSize const viewSize );

- (void)scrollString:(NSString *)string attributes:(NSDictionary *)attributes;
- (void)changeBackgroundColor:(NSColor*)color;
- (void)setBorderWidth:(CGFloat)width;
- (CGFloat)borderWidth;
@end



@implementation MCScrollView

//
// 初期化 initialize
//
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        _rootLayer = [[CALayer layer] retain];
        _rootLayer.layoutManager = [CAConstraintLayoutManager layoutManager];
        self.layer = _rootLayer;
        self.wantsLayer = YES;
    }
    
    return self;
}


//
// deallocate
//
- (void)dealloc {
    [_rootLayer release];
    [super dealloc];
}


- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}



#pragma mark -
#pragma mark Layer Control
/*==============================================================================
 *
 *  Layer Control
 *
 *==============================================================================*/
- (void)removeTextLayer:(CATextLayer const *)textLayer { [textLayer removeFromSuperlayer]; }

- (void)scrollString:(NSString *)string attributes:(NSDictionary *)attributes {
    CGFloat duration    = [[attributes objectForKey:HSMScrollViewerDuration] floatValue];
    CGFloat fontSize    = [[attributes objectForKey:HSMScrollViewerFontSize] floatValue];
    NSColor * fontColor = [attributes objectForKey:HSMScrollViewerFontColor];
    
    
    /*=====================Size=====================*/
    NSSize  viewSize   = [self frame].size;
    NSSize  strSize    = [string sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                     [NSFont systemFontOfSize:fontSize], NSFontAttributeName,
                                                     nil]];
    /*==============================================*/
    
    
    /*==============================================
     *    create new TextLayer
     *==============================================*/
    CATextLayer *textLayer = [CATextLayer layer];
    
    /*==============================================
     *    set TEXT ATTRIBUTE
     *==============================================*/
    textLayer.string          = string;
    textLayer.fontSize        = fontSize;
    textLayer.frame           = CGRectMake(0, 0, strSize.width, strSize.height);
    /* textLayer.foregroundColor */{
        CGFloat red,green,blue,alpha;
        [fontColor getRed:&red green:&green blue:&blue alpha:&alpha];
        CGColorRef color = CGColorCreateGenericRGB(red, green, blue, alpha);
        textLayer.foregroundColor = color;
        CGColorRelease(color);
    }
    
    /*==============================================
     *    put TextLayer in ROOTLAYER
     *==============================================*/
    [_rootLayer addSublayer:textLayer];
    
    /*==============================================
     *    Animation's setting
     *==============================================*/
    CGFloat calduration = duration * (viewSize.width/kAnimationRate);
    CABasicAnimation *movingAnimation = createAnimation(_rootLayer,calduration,strSize, viewSize);
    [textLayer addAnimation:movingAnimation forKey:@"moveingAnimation"];
    [self performSelector:@selector(removeTextLayer:)
               withObject:textLayer
               afterDelay:calduration-0.2];
}




CABasicAnimation * createAnimation(CALayer const * rootLayer,CGFloat const duration,NSSize const stringSize,NSSize const viewSize) {
    DLOG(@"string %f %f\nview %f %f",stringSize.width,stringSize.height,viewSize.width,viewSize.height);
    CGFloat rowShouldBeDraw = getNextRow(rootLayer, stringSize.height, viewSize);
    CABasicAnimation *movingAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    movingAnimation.duration  = duration;
      movingAnimation.fromValue = [NSValue valueWithPoint:NSMakePoint(viewSize.width+stringSize.width/2, rowShouldBeDraw)];
      movingAnimation.toValue   = [NSValue valueWithPoint:NSMakePoint(0/*-stringSize.width/2*/, rowShouldBeDraw)];
    DLOG(@"%@",movingAnimation.toValue);
    return movingAnimation;
}


CGFloat getNextRow(CALayer const * rootLayer, CGFloat const strHeight,NSSize const viewSize ) {
#define kTextMargin strHeight
#define kTopRow viewSize.height - kTextMargin/2.0f
    
    CGFloat rowShouldBeDraw  = 0;
    CGFloat lastRow = 0.0f;
    BOOL isFirst=YES;
    BOOL isDrawableAtSameRow = NO;
    for (CALayer* layer in [[rootLayer sublayers] reverseObjectEnumerator]) {
        CALayer * lay = (CALayer*)[layer presentationLayer];
        if (isFirst) {
            isFirst = NO;
            lastRow = lay.position.y;
        }
        if (lay.position.y > rowShouldBeDraw
            &&
            lay.position.x + lay.frame.size.width < viewSize.width )
        {/*---------------------------------------------------*/
            rowShouldBeDraw = lay.position.y;
            isDrawableAtSameRow = YES;
        }/*---------------------------------------------------*/
        
        if (lay.position.y >= kTopRow) { break; }
    }
    
    if (!isDrawableAtSameRow) { rowShouldBeDraw = lastRow - kTextMargin;}
    if (rowShouldBeDraw<=0 || rowShouldBeDraw >= viewSize.height-strHeight) {
        rowShouldBeDraw = kTopRow;
    }
    return rowShouldBeDraw;
#undef kTextMargin
#undef kTopRow
}





- (void)changeBackgroundColor:(NSColor*)color {
    NSUserDefaults * df = [NSUserDefaults standardUserDefaults];
    CGFloat red   = [color redComponent];
    CGFloat green = [color greenComponent];
    CGFloat blue  = [color blueComponent];
    CGFloat alpha = [df floatForKey:kMCScrollViewBGAlpha];
    CGColorRef cgColor = CGColorCreateGenericRGB(red, green, blue, alpha/100);
    _rootLayer.backgroundColor = cgColor;
    CGColorRelease(cgColor);
}


- (void)setBorderWidth:(CGFloat)width {
    _rootLayer.borderWidth = width;
}


- (CGFloat)borderWidth {
    return _rootLayer.borderWidth;
}

@end












@interface MCScrollViewWindowController ()

@end

@implementation MCScrollViewWindowController
 - (id)initWithWindow:(NSWindow *)window
{
    return [super initWithWindow:window];
}
- (id)initWithWindowNibName:(NSString *)windowNibName { return [super initWithWindowNibName:windowNibName];}
- (id)initWithWindowNibName:(NSString *)windowNibName owner:(id)owner {return [super initWithWindowNibName:windowNibName owner:owner];}
- (id)initWithWindowNibPath:(NSString *)windowNibPath owner:(id)owner {return [super initWithWindowNibPath:windowNibPath owner:owner];}


- (id)init {
    self = [super initWithWindowNibName:@"MCScrollViewWindowController"];
    if (self) {
        // Initialization code here.
        _contentView = [[MCScrollView alloc] init];
        NSWindow *win = [self window];
        /*
         NSBorderlessWindowMask      = 0,  // 枠が無い
         NSTitledWindowMask          = 1,  // タイトル部分を持つ
         NSClosableWindowMask        = 2,  // クローズボックスを持つ
         NSMiniaturizableWindowMask  = 4,  // 最小化ボタンを持つ
         NSResizableWindowMask       = 8   // リサイズボックスを持つ
         */
        [win setStyleMask:(NSTitledWindowMask |  NSResizableWindowMask | NSClosableWindowMask)];
        
        /*
         NSNormalWindowLevel
         NSFloatingWindowLevel
         NSSubmenuWindowLevel
         NSTornOffMenuWindowLevel
         NSMainMenuWindowLevel
         NSStatusWindowLevel
         NSDockWindowLevel
         NSModalPanelWindowLevel
         NSPopUpMenuWindowLevel
         NSScreenSaverWindowLeve
         */
        [win setLevel:NSStatusWindowLevel];
        
        [win setBackgroundColor:[NSColor clearColor]];
        [win setOpaque:NO];
        [win setShowsResizeIndicator:YES];
        [win setMovableByWindowBackground:YES];

        [self unlockWindow];
    }
    return self;
}


- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    NSWindow * window = [self window];
    window.contentView = _contentView;
    
    /*enum {
     NSViewNotSizable     = 0,
     NSViewMinXMargin     = 1,
     NSViewWidthSizable   = 2,
     NSViewMaxXMargin     = 4,
     NSViewMinYMargin     = 8,
     NSViewHeightSizable  = 16,
     NSViewMaxYMargin     = 32
     };
     */
//    [[window contentView] setAutoresizesSubviews:YES];
////    [[window contentView] setAutoresizingMask:0];
//    [[window contentView] setAutoresizingMask:NSViewMinXMargin | NSViewWidthSizable | NSViewMaxXMargin | NSViewMinYMargin | NSViewHeightSizable | NSViewMaxYMargin];

}



- (void)dealloc {
    [_contentView release];
    [super dealloc];
}



- (void)lockWindow {
    NSWindow *win = [self window];
    [win setStyleMask:NSBorderlessWindowMask];
    [[self window] setIgnoresMouseEvents:YES];
}
- (void)unlockWindow {
    [[self window] setStyleMask:(NSTitledWindowMask |  NSResizableWindowMask | NSClosableWindowMask)];
    [[self window] setIgnoresMouseEvents:NO];
}

- (void)scrollString:(NSString *)string attributes:(NSDictionary *)attributes {
    [_contentView scrollString:string attributes:attributes];
}


- (void)changeBackgroundColor:(NSColor*)color {
    [_contentView changeBackgroundColor:color];
}


- (void)setIsShowBorder:(BOOL)isShow {
    if (isShow)
        _contentView.borderWidth = 3;
    else
        _contentView.borderWidth = 0;
}

@end
