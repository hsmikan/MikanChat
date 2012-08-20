//
//  NSString+MCRegex.m
//  MikanChat
//
//  Created by hsmikan on 8/9/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import "NSString+MCRegex.h"

@implementation NSString (MCRegex)
- (NSRange)rangeOfRegex:(NSString *)regex {
    return [self rangeOfString:regex options:NSRegularExpressionSearch];
}

- (BOOL)isMatchedByRegex:(NSString*)regex {
    NSError * err = nil;
    NSRegularExpression * regexp = [NSRegularExpression regularExpressionWithPattern:regex options:0 error:&err];
    
    if (err != nil) {
        return NO;
    }
    NSTextCheckingResult * matched = [regexp firstMatchInString:self options:0 range:NSMakeRange(0, [self length])];
    
    return [self isEqualToString:[self substringWithRange:[matched rangeAtIndex:0]]];
}


- (NSArray*)componentsMatchedByRegex:(NSString*)regex {
    NSMutableArray * matchedStrings;
    
    NSRegularExpression * regexp;
    NSError * err = nil;
    {
        regexp = [NSRegularExpression regularExpressionWithPattern:regex
                                                           options:0
                                                             error:&err];
    }
    
    if (err != nil) {
        matchedStrings = nil;
    }
    else {
        matchedStrings = [NSMutableArray array];
        
        [regexp enumerateMatchesInString:self
                                 options:0
                                   range:NSMakeRange(0, [self length])
                              usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
         {
             NSString * matched = [self substringWithRange:[result rangeAtIndex:0]];
             if (![matchedStrings containsObject:matched]) {
                 [matchedStrings addObject:[self substringWithRange:[result rangeAtIndex:0]]];
             }
         }];
    }
    
    return matchedStrings;
}



- (NSString*)stringByReplacingOccurrencesOfRegex:(NSString*)regex withString:(NSString*)replaced {
    NSError * err = nil;
    NSRegularExpression * regexp = [NSRegularExpression regularExpressionWithPattern:regex options:0 error:&err];
    if (err != nil)
        return nil;
    
    return [regexp stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, [self length]) withTemplate:replaced];
}

@end



@implementation NSMutableString (MCRegex)

- (void)replaceOccurrencesOfRegex:(NSString*)regex withString:(NSString *)replaced {
    NSError * err = nil;
    NSRegularExpression * regexp = [NSRegularExpression regularExpressionWithPattern:regex options:0 error:&err];
    
    [regexp replaceMatchesInString:self options:0 range:NSMakeRange(0, [self length]) withTemplate:replaced];
}

@end
