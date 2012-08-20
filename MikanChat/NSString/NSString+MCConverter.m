//
//  NSString+MCConverter.m
//  MikanChat
//
//  Created by hsmikan on 8/9/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import "NSString+MCConverter.h"
#import "../MCUserDefaultsKeys.h"
#import "NSString+MCRegex.h"


#define MCUnvalidRegex @"[\\(\\)\\*\\{\\}\\^\\`]"

#define MCConvertUnvalidList \
[NSArray arrayWithObjects:\
[NSArray arrayWithObjects:@"?",@"？",nil],\
[NSArray arrayWithObjects:@"!",@"！",nil],\
[NSArray arrayWithObjects:@"",@"",nil],\
nil]
//[NSArray arrayWithObjects:@"",@"",nil],\


@implementation NSString (MCConverter)

- (NSString *)MC_PRIVATE_METHOD_PREPEND(stringByConvertingYomi):(NSArray *)sortedConvertList {
    
    if (sortedConvertList.count == 0) return self;
    
    NSMutableString * ret = [NSMutableString string];
    
    NSString * pattern = [[sortedConvertList objectAtIndex:0] objectForKey:kMCConvertYomiListPatternKey];
    if ([self rangeOfString:pattern].location != NSNotFound) {
        NSArray * subarr = [self componentsSeparatedByString:pattern];
        NSUInteger subarrCnt = [subarr count];
        if (subarrCnt) {
            [subarr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj length]) {
                    [ret appendString:[obj MC_PRIVATE_METHOD_PREPEND(stringByConvertingYomi):[sortedConvertList subarrayWithRange:NSMakeRange(1, sortedConvertList.count-1)]]];
                }
                
                if (subarrCnt <= 1 || idx != subarrCnt-1) {
                    [ret appendString:[[sortedConvertList objectAtIndex:0] objectForKey:kMCConvertYomiListYomiKey]];
                }
            }];
        }
        else {
            [ret appendString:[[sortedConvertList objectAtIndex:0] objectForKey:kMCConvertYomiListYomiKey]];
        }
    }
    else {
        [ret appendString:[self MC_PRIVATE_METHOD_PREPEND(stringByConvertingYomi):[sortedConvertList subarrayWithRange:NSMakeRange(1, sortedConvertList.count-1)]]];
    }
    
    return ret;
}
- (NSString *)stringByConvertingYomi {
    NSUserDefaults * df = [NSUserDefaults standardUserDefaults];
    NSArray * yomidic = [NSArray arrayWithArray:[df arrayForKey:kMCConvertYomiListKey]];
    
    NSMutableArray * found = [NSMutableArray array];
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    for (NSDictionary * item in yomidic) {
        NSAutoreleasePool * internalPool = [[NSAutoreleasePool alloc] init];
        
        NSArray * matches = [self componentsMatchedByRegex:[item objectForKey:kMCConvertYomiListPatternKey]];
        for (NSString * str in matches) {
            if (str.length) {
                [found addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                  str,kMCConvertYomiListPatternKey,
                                  [item objectForKey:kMCConvertYomiListYomiKey],kMCConvertYomiListYomiKey,
                                  nil]];
            }
        }
        
        [internalPool release];
    }
    [pool release];
    
    if ([found count]) {
        NSSortDescriptor * sortdesc = [[[NSSortDescriptor alloc] initWithKey:STRINGFORMAT(@"%@.length",kMCConvertYomiListPatternKey) ascending:NO] autorelease];
        [found sortUsingDescriptors:[NSArray arrayWithObject:sortdesc]];
        
        return [self MC_PRIVATE_METHOD_PREPEND(stringByConvertingYomi):found];
    }
    else {
        return self;
    }
}



- (NSString*)stringByTrimmingUnvalidCharacters {
    NSMutableString * converted = [NSMutableString stringWithString:self];
    for (NSArray * convertArr in MCConvertUnvalidList) {
        [converted replaceOccurrencesOfString:[convertArr objectAtIndex:0]
                                   withString:[convertArr objectAtIndex:1]
                                      options:0
                                        range:NSMakeRange(0, converted.length)];
    }
    return [converted stringByReplacingOccurrencesOfRegex:MCUnvalidRegex withString:@""];
}
@end



@implementation NSMutableString (MCConverter)

@end
