//
//  NSColorWell+MCCategory.m
//  MikanChat
//
//  Created by hsmikan on 8/19/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import "NSColorWell+MCCategory.h"

@implementation NSColorWell (MCCategory)
+ (NSColor*)hex2NSColor:(NSString*)colorStr{
	NSString *redStr = [colorStr substringWithRange:NSMakeRange(1, 2)];
	NSString *greenStr = [colorStr substringWithRange:NSMakeRange(3, 2)];
	NSString *blueStr = [colorStr substringWithRange:NSMakeRange(5, 2)];
	
	unsigned int redInt;
	[[NSScanner scannerWithString:redStr] scanHexInt:&redInt];
	CGFloat red = (float)redInt/255;
	
	unsigned int greenInt;
	[[NSScanner scannerWithString:greenStr] scanHexInt:&greenInt];
	CGFloat green = (float)greenInt/255;
	
	unsigned int blueInt;
	[[NSScanner scannerWithString:blueStr] scanHexInt:&blueInt];
	CGFloat blue = (float)blueInt/255;
	
	return [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:1.0f];
	//	[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:red],@"red",
	//			[NSNumber numberWithFloat:green],@"green",
	//			[NSNumber numberWithFloat:blue],@"blue",nil];
}

- (NSString*)hexColor {
    CGFloat redFloat,greenFloat,blueFloat,alpha;
    [[self color] getRed:&redFloat green:&greenFloat blue:&blueFloat alpha:&alpha];
    return STRINGFORMAT(@"#%02x%02x%02x",(int)(redFloat*255),(int)(greenFloat*255),(int)(blueFloat*255));
}
@end
