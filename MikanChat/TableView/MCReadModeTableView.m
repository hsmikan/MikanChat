//
//  MCReadModeTableView.m
//  MikanChat
//
//  Created by hsmikan on 8/10/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import "MCReadModeTableView.h"
#import "../MCUserDefaultsKeys.h"
#import "../ReadManager/MCReadManager.h"
#import "../SoundDevice/MCSoundDevice.h"


@implementation MCReadModeTableView
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
    [super drawRect:dirtyRect];
}
*/

- (void)MC_PRIVATE_METHOD_PREPEND(loadReadSystemDevice) {
    //
    // readSystem Column
    //
    NSTableColumn * systemTBLCL = [self tableColumnWithIdentifier:kMCReadModeSystemIndexKey];
	NSArray * systemArr = [[MCReadManager sharedReader] readSystemNameList];
    [[systemTBLCL dataCell] addItemsWithTitles:systemArr];
    
    //
    // sound device column
    //
    NSTableColumn * deviceTBLCL = [self tableColumnWithIdentifier:kMCReadModeDeviceIndexKey];
    NSArray * deviceList = [[MCSoundDevice sharedAudioDevice] deviceNameList];
    [[deviceTBLCL dataCell] addItemsWithTitles:deviceList];
}



- (void) awakeFromNib {
    NSNotificationCenter * nfc = [NSNotificationCenter defaultCenter];
    [nfc addObserver:self selector:@selector(_loadReadSystemDevice) name:kMCReadModeSystemDeviceUpdateNotification object:nil];
    [self MC_PRIVATE_METHOD_PREPEND(loadReadSystemDevice)];
}

@end
