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

@interface MCReadModeTableView()
- (void)MC_PRIVATE_METHOD_PREPEND(loadReadSystemDevice);
@end


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

- (void) awakeFromNib {
    NSNotificationCenter * nfc = [NSNotificationCenter defaultCenter];
    [nfc addObserver:self selector:@selector(MC_PRIVATE_METHOD_PREPEND(loadReadSystemDevice)) name:kMCReadModeSystemDeviceUpdateNotification object:nil];
    [self MC_PRIVATE_METHOD_PREPEND(loadReadSystemDevice)];
}



- (void)MC_PRIVATE_METHOD_PREPEND(loadReadSystemDevice) {
    //
    // readSystem Column
    //
    NSTableColumn * systemTBLCL = [self tableColumnWithIdentifier:kMCReadModeSystemIndexKey];
	NSArray * systemArr = [[MCReadManager sharedReader] readSystemNameListByReload];
    id systems = [systemTBLCL dataCell];
    [systems removeAllItems];
    [systems addItemsWithTitles:systemArr];
    
    //
    // sound device column
    //
    NSTableColumn * deviceTBLCL = [self tableColumnWithIdentifier:kMCReadModeDeviceIndexKey];
    NSArray * deviceList = [[MCSoundDevice sharedAudioDevice] deviceNameListByReload];
    id sounds = [deviceTBLCL dataCell];
    [sounds removeAllItems];
    [sounds addItemsWithTitles:deviceList];
}


@end
