//
//  MCParentClient.m
//  MikanChat
//
//  Created by hsmikan on 8/19/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import "MCParentClient.h"

EXTERNED NSString * const kMCClientMessageKey  = @"message";
EXTERNED NSString * const kMCClientUserNameKey = @"username";


@interface MCParentClient ()

@end

@implementation MCParentClient
@synthesize delegate        = _delegate;

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Initialization code here.
//    }
//    
//    return self;
//}
- (id)initWithDelegate:(id<MCClientProtocol>)delegate nibName:(NSString*)nibName {
    self = [super initWithNibName:nibName bundle:nil];
    if (self){
        self.delegate = delegate;
    }
    return self;
}

- (id)initWithDelegate:(id<MCClientProtocol>)delegate {
    return nil;
}

- (BOOL)startChat
{
    return NO;
}
- (void)endChat
{
    return;
}
- (BOOL)isJoin
{
    return NO;
}

@end
