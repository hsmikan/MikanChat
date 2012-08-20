//
//  MCDIctionary.m
//  MikanChat
//
//  Created by hsmikan on 8/9/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import "MCDictionary.h"

@implementation MCDictionary

static MCDictionary * _sharedInstance = nil;

+ (MCDictionary *)sharedDictionary {
    @synchronized(self) {
        if (_sharedInstance == nil) {
            [[self alloc] init];
            NSNotificationCenter * ntc = [NSNotificationCenter defaultCenter];
            [ntc addObserver:self selector:@selector(sharedDictionaryWillClose:)
                        name:NSApplicationWillTerminateNotification object:NSApp];
        }
    }
    
    return _sharedInstance;
}


+ (void)sharedDictionaryWillClose:(NSNotification *)notification {
    if (_sharedInstance) [_sharedInstance release];
}


+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        _sharedInstance = [super allocWithZone:zone];
        return _sharedInstance;
    }
    return nil;
}
- (id)copyWithZone:(NSZone *)zone   { return self; }
- (id)retain                        { return self; }
- (NSUInteger)retainCount           { return UINT_MAX; }
- (oneway void)release              { return; }
- (id)autorelease                   { return self; }
@end
