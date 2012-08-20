//
//  MCLiveTubeClient.h
//  MikanChat
//
//  Created by hsmikan on 8/9/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../MCParentClient.h"


@interface MCLiveTubeClient : MCParentClient
- (id)initWithDelegate:(id<MCClientProtocol>)delegate;
@end
