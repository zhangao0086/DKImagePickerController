//
// Created by BLACKGENE on 2015. 10. 9..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STUIApplication.h"

extern NSString * const STSearchableItemIdentifierXXXXX;

@interface STUIApplication (SpotlightSearch)
- (BOOL)launchFromNeededSearchableItemByUserActivityIfPossible:(NSUserActivity *)userActivity;

- (void)indexDefaultSearchableItemsIfPossible;

- (void)indexControllableItemsIfPossible:(NSDictionary *)items;
@end