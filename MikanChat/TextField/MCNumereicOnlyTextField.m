//
//  MCNumereicOnlyTextField.m
//  MikanChat
//
//  Created by hsmikan on 8/12/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import "MCNumereicOnlyTextField.h"
#import "../NSString/NSString+MCRegex.h"

@implementation MCNumereicOnlyTextField

- (void)awakeFromNib {
	[self textDidChange:nil];
}


- (void)textDidChange:(NSNotification *)notification {

    self.stringValue = [self.stringValue stringByReplacingOccurrencesOfRegex:@"[^0-9]" withString:@""];
}

@end
