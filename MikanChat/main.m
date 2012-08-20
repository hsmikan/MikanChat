//
//  main.m
//  MikanChat
//
//  Created by hsmikan on 8/9/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

int main(int argc, char *argv[])
{
    return NSApplicationMain(argc, (const char **)argv);
}

void MCTBLReloadData(NSTableView * tableView, NSInteger count){
    [tableView reloadData];
    [tableView scrollRowToVisible:(count==0 ? 0 : count-1)];
}
