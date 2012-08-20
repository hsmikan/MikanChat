//
//  NSColorWell+MCCategory.h
//  MikanChat
//
//  Created by hsmikan on 8/19/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSColorWell (MCCategory)
+ (NSColor*)hex2NSColor:(NSString*)colorStr;
- (NSString*)hexColor;
@end
