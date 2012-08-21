//
//  MCPhontColumn.m
//  MikanChat
//
//  Created by hsmikan on 8/10/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import "MCPhontColumn.h"
#import "../ReadManager/MCReadManager.h"
#import "../MCUserDefaultsKeys.h"

@implementation MCPhontColumn
- (id)dataCellForRow:(NSInteger)row {
    NSPopUpButtonCell *cell = [self dataCell];
    
    NSUserDefaults * df = [NSUserDefaults standardUserDefaults];
    NSArray * modelist = [df objectForKey:kMCReadModeListKey];
    NSInteger index = [[[modelist objectAtIndex:row] objectForKey:kMCReadModeSystemIndexKey] integerValue];
    NSArray * phontslist = [[MCReadManager sharedReader] phontsBySystemIndex:index];
    [cell removeAllItems];
    [cell addItemsWithTitles:phontslist];
    
	return cell;
}
@end
