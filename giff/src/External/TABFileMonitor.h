//
//  TABFileMonitor.h
//  File Monitor
//
//  Created by Travis Blankenship on 3/27/14.
//  Copyright (c) 2014 Travis Blankenship. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TABFileMonitorChangeType)
{
    TABFileMonitorChangeTypeModified,
    TABFileMonitorChangeTypeMetadata,
    TABFileMonitorChangeTypeSize,
    TABFileMonitorChangeTypeRenamed,
    TABFileMonitorChangeTypeDeleted,
    TABFileMonitorChangeTypeObjectLink,
    TABFileMonitorChangeTypeRevoked
};

@protocol TABFileMonitorDelegate;

@interface TABFileMonitor : NSObject

@property (nonatomic, weak) id<TABFileMonitorDelegate> delegate;

- (id)initWithURL:(NSURL *)URL;

@end

@protocol TABFileMonitorDelegate <NSObject>
@optional

- (void)fileMonitor:(TABFileMonitor *)fileMonitor didSeeChange:(TABFileMonitorChangeType)changeType;

@end
