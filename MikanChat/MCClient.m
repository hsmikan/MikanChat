//
//  MCParentClient.m
//  MikanChat
//
//  Created by hsmikan on 8/19/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import "MCClient.h"



@interface MCClient ()

@end

@implementation MCClient
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
- (id)initWithDelegate:(id<MCClientWindowDelegate>)delegate nibName:(NSString*)nibName {
    self = [super initWithNibName:nibName bundle:nil];
    if (self){
        self.delegate = delegate;
        _messageList = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void)dealloc {
    RELEASE(_messageList);
    [super dealloc];
}
@end
