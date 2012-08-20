//
//  MCLiveTubeClient.m
//  MikanChat
//
//  Created by hsmikan on 8/9/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import "MCLiveTubeClient.h"
#define NIBNAME @"LiveTube"

@implementation MCLiveTubeClient
- (id)initWithDelegate:(id<MCClientProtocol>)delegate {
    self = [super initWithDelegate:delegate nibName:NIBNAME];
    if (self){
        
    }
    return self;
}
@end
