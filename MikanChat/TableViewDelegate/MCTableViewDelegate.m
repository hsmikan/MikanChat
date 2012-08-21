//
//  MCTableViewDelegate.m
//  MikanChat
//
//  Created by hsmikan on 8/10/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import "MCTableViewDelegate.h"
#import "../MCUserDefaultsKeys.h"
#import "../ReadManager/MCReadManager.h"
#import "../Yukkuroid/YukkuroidRPCClinet.h"

@implementation MCTableViewDelegate
+ (NSString *)tableViewKey:(NSTableView*)tableView {
    if      (COMPARESTRING([tableView identifier], kMCIgnoreTBLID))
        return kMCIgnoreListKey;
    
    else if (COMPARESTRING([tableView identifier], kMCReadModeTBLID))
       return kMCReadModeListKey;
    
    else if (COMPARESTRING([tableView identifier], kMCConvertYomiTBLID))
        return kMCConvertYomiListKey;
    
    else
        return nil;
}




- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    NSString * operateKey = [[self class] tableViewKey:tableView];
    
    NSUserDefaults * df = [NSUserDefaults standardUserDefaults];
    NSArray * modeList = [df objectForKey:operateKey];
    
    return modeList == nil ? 0 : [modeList count];
}




- (void)MC_PRIVATE_METHOD_PREPEND(tableView):(NSTableView *)tableView row:(NSInteger)row yukkuroidMode:(BOOL)isEnable {
    for ( NSTableColumn * column in [tableView tableColumns] )
        if ( COMPARESTRING([column identifier],kMCReadModeDeviceIndexKey) )
            [[column dataCellForRow:row] setEnabled:!isEnable];
}


- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString * operateKey = [[self class] tableViewKey:tableView];

    NSArray * modeList = nil;
      NSUserDefaults * df = [NSUserDefaults standardUserDefaults];
      modeList = [df objectForKey:operateKey];
    
    
    if (COMPARESTRING([tableColumn identifier], kMCReadModeSystemIndexKey)) {
        //
        // isYukkuroid
        //
        if ([[MCReadManager sharedReader] isYukkuroidAtIndex:[[[modeList objectAtIndex:row] objectForKey:kMCReadModeSystemIndexKey] integerValue]])
            [self MC_PRIVATE_METHOD_PREPEND(tableView):tableView row:row yukkuroidMode:YES];
        else
            [self MC_PRIVATE_METHOD_PREPEND(tableView):tableView row:row yukkuroidMode:NO];
    }

    
    return [[modeList objectAtIndex:row] objectForKey:[tableColumn identifier]];
}



- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
#define SETNEW subarr = [NSMutableArray arrayWithArray:[df arrayForKey:arrayKey]];\
subdic = [NSMutableDictionary dictionaryWithDictionary:[subarr objectAtIndex:row]];\
[subdic setObject:object forKey:[tableColumn identifier]]

    NSUserDefaults * df = [NSUserDefaults standardUserDefaults];
    NSMutableArray * subarr = nil;
    NSMutableDictionary * subdic = nil;
    BOOL isContained = NO;
    NSString * arrayKey = nil;
    
    if (COMPARESTRING([tableView identifier], kMCIgnoreTBLID)) {
        arrayKey = kMCIgnoreListKey;
        
        SETNEW;
        
        //
        // is already contained
        //
        if([subarr containsObject:subdic])
            isContained = YES;
    }
    else {
        NSString * containCheckColumnKey = nil;
        
        if (COMPARESTRING([tableView identifier], kMCReadModeTBLID)) {
            arrayKey = kMCReadModeListKey;
            containCheckColumnKey = kMCReadModeNameKey;
        }
        else if (COMPARESTRING([tableView identifier], kMCConvertYomiTBLID)) {
            arrayKey = kMCConvertYomiListKey;
            containCheckColumnKey = kMCConvertYomiListPatternKey;
        }
        
        
        SETNEW;

        
        //
        // is already contained
        //
        if (COMPARESTRING([tableColumn identifier], containCheckColumnKey)) {
            for (NSDictionary * item in subarr) {
                if (COMPARESTRING([item objectForKey:containCheckColumnKey],object)) {
                    isContained = YES;
                    break;
                }
            }
        }
    }
    
    
    if (isContained) return;
    
    //
    // Change Read System
    //
    if (COMPARESTRING([tableColumn identifier], kMCReadModeSystemIndexKey)) {
        //
        //  reset Phont index
        //
        [subdic setObject:[NSNumber numberWithInteger:0] forKey:kMCReadModePhontIndexKey];
    }

    
    [subarr replaceObjectAtIndex:row withObject:subdic];
    [df setObject:subarr forKey:arrayKey];
    
    [tableView reloadData];
    
    
#undef SETNEW
}



//
// Sort
//
- (void)tableView:(NSTableView *)tableView sortDescriptorsDidChange:(NSArray *)oldDescriptors {
    NSString * operateKey = [[self class] tableViewKey:tableView];
    
    NSUserDefaults * df = [NSUserDefaults standardUserDefaults];
    NSMutableArray * sortedArr = [NSMutableArray arrayWithArray:[df arrayForKey:operateKey]];
    [sortedArr sortUsingDescriptors:oldDescriptors];
    
    [df setObject:sortedArr forKey:operateKey];
    [tableView reloadData];
}

@end
