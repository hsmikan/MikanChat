//
//  NSUserDefaults+myColorSuport.m
//  MikanChat
//
//  Created by hsmikan on 9/13/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import "NSUserDefaults+myColorSupport.h"


@implementation NSUserDefaults(myColorSupport)

- (void)setColor:(NSColor *)aColor forKey:(NSString *)aKey
{
    NSData *theData=[NSArchiver archivedDataWithRootObject:aColor];
    [self setObject:theData forKey:aKey];
}

- (NSColor *)colorForKey:(NSString *)aKey
{
    NSColor *theColor=nil;
    NSData *theData=[self dataForKey:aKey];
    if (theData != nil)
        theColor=(NSColor *)[NSUnarchiver unarchiveObjectWithData:theData];
    return theColor;
}

@end
