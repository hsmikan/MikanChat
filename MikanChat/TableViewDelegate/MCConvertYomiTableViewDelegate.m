//
//  MCConvertYomiTableViewDelegate.m
//  MikanChat
//
//  Created by hsmikan on 8/12/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import "MCConvertYomiTableViewDelegate.h"
#import "../MCUserDefaultsKeys.h"


@implementation MCConvertYomiTableViewDelegate
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    NSUserDefaults * df = [NSUserDefaults standardUserDefaults];
    return [df arrayForKey:kMCConvertYomiListKey].count;
}



- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSUserDefaults * df = [NSUserDefaults standardUserDefaults];
    return [[[df arrayForKey:kMCConvertYomiListKey] objectAtIndex:row] objectForKey:[tableColumn identifier]];
}



- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSUserDefaults * df = [NSUserDefaults standardUserDefaults];
    NSMutableArray * subarr = [NSMutableArray arrayWithArray:[df arrayForKey:kMCConvertYomiListKey]];
    NSMutableDictionary * subdic = [NSMutableDictionary dictionaryWithDictionary:[subarr objectAtIndex:row]];
    [subdic setObject:object forKey:[tableColumn identifier]];
    [subarr replaceObjectAtIndex:row withObject:subdic];
    [df setObject:subarr forKey:kMCConvertYomiListKey];
    [tableView reloadData];
}
@end
