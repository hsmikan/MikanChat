//
//  MCSoundDevice.h
//  MikanChat
//
//  Created by hsmikan on 8/9/12.
//  Copyright (c) 2012 hsmikan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCSoundDevice : NSObject
+ (MCSoundDevice*)sharedAudioDevice;
- (NSArray*)deviceNameList;
- (NSString*)deviceUIDByIndex:(NSUInteger)index;
@end
