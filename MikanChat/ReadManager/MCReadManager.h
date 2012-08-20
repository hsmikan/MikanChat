//
//  MCReadManager.h
//  MikanChat
//
//  Created by hsmikan on 8/9/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MCReadManager : NSObject
+ (MCReadManager *)sharedReader;
- (NSArray*)readSystemNameList;
- (NSString*)systemNameAtIndex:(NSUInteger)index;
- (NSArray*)phontsBySystemIndex:(NSUInteger)index;
- (NSString*)phontNameAtIndex:(NSUInteger)index systemIndex:(NSUInteger)systemIndex;
- (void)read:(NSString *)message name:(NSString *)title modeProperty:(NSDictionary*)property;
@end
