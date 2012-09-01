//
//  MCSoundDeviceColumn.m
//  MikanChat
//
//  Created by hsmikan on 9/1/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import "MCSoundDeviceColumn.h"
#import "../SoundDevice/MCSoundDevice.h"
#import "../ReadManager/MCReadManager.h"
#import "../MCUserDefaultsKeys.h"


@implementation MCSoundDeviceColumn

- (id)dataCellForRow:(NSInteger)row {
    NSPopUpButtonCell *cell = [self dataCell];
    
    NSUserDefaults * df = [NSUserDefaults standardUserDefaults];
    NSArray * modelist = [df objectForKey:kMCReadModeListKey];
    NSInteger index = [[[modelist objectAtIndex:row] objectForKey:kMCReadModeSystemIndexKey] integerValue];
    
    NSArray * devices;
    if ( COMPARESTRING([[MCReadManager sharedReader] systemNameAtIndex:index], @"Yukkuroid") )
        devices = [NSArray arrayWithObject:@"Unavailable with Yukkuroid"];
    else {
        devices = [[MCSoundDevice sharedAudioDevice] deviceNameList];
    }
    
    [cell removeAllItems];
    [cell addItemsWithTitles:devices];
    
	return cell;
}

@end
