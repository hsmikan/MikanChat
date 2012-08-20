//
//  NSString+MCRegex.h
//  MikanChat
//
//  Created by hsmikan on 8/9/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//


//#import "RegexKitLite.h"


 #import <Foundation/Foundation.h>

@interface NSString (MCRegex)
- (NSRange)rangeOfRegex:(NSString *)regex;
- (BOOL)isMatchedByRegex:(NSString*)regex;
- (NSArray*)componentsMatchedByRegex:(NSString*)regex;
- (NSString*)stringByReplacingOccurrencesOfRegex:(NSString*)regex withString:(NSString*)replaced;
@end

@interface NSMutableString (MCRegex)
- (void)replaceOccurrencesOfRegex:(NSString*)regex withString:(NSString *)replaced;
@end
