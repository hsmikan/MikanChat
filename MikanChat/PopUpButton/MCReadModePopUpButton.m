//
//  MCReadModePopUpButton.m
//  MikanChat
//
//  Created by hsmikan on 8/12/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import "MCReadModePopUpButton.h"
#import "../MCUserDefaultsKeys.h"


@implementation MCReadModePopUpButton
/*
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}
*/


- (void)MC_PRIVATE_METHOD_PREPEND(updateReadModeList) {
    NSString * curtitle = [[self selectedItem] title];
    
    [self removeAllItems];
    
    NSUserDefaults * df = [NSUserDefaults standardUserDefaults];
    NSArray * modelist = [[df arrayForKey:kMCReadModeListKey] valueForKeyPath:kMCReadModeNameKey];
    if (modelist.count) {
        [self addItemsWithTitles:modelist];
        
        if ([modelist containsObject:curtitle])
            [self selectItemWithTitle:curtitle];
    }
}



- (void)awakeFromNib {
    [self MC_PRIVATE_METHOD_PREPEND(updateReadModeList)];
    NSNotificationCenter * nfc = [NSNotificationCenter defaultCenter];
    [nfc addObserver:self selector:@selector(MC_PRIVATE_METHOD_PREPEND(updateReadModeList))
                name:kMCReadModePBNotficationKey object:nil];
}

@end
