//
//  MCExpansionSlider.m
//  MikanChat
//
//  Created by hsmikan on 8/10/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import "MCExpansionSlider.h"

@implementation MCExpansionSlider
- (NSRect)expansionFrameWithFrame:(NSRect)cellFrame inView:(NSView *)view {
	NSRect frame = cellFrame;
	  frame.origin.x += 10;
	  frame.origin.y -= 10;
	  frame.size.width  = 30;
	  frame.size.height = 20;
    
	return frame;
}
- (void)drawWithExpansionFrame:(NSRect)cellFrame inView:(NSView *)view {
	NSString *str =[NSString stringWithFormat:@"%d",[self intValue]];
	[str drawInRect:cellFrame
	 withAttributes:[NSDictionary dictionaryWithObject:[NSFont systemFontOfSize:12] forKey:NSFontAttributeName]];
}

@end
