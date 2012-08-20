//
//  NSString+MCConverter.h
//  MikanChat
//
//  Created by hsmikan on 8/9/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MCConverter)

- (NSString *)stringByConvertingYomi;
- (NSString *)stringByTrimmingUnvalidCharacters;
@end

@interface NSMutableString (MCConverter)

@end