//
// Created by BLACKGENE on 2015. 8. 17..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STItem.h"

@class STStandardButton;


@interface STSettingScreenControllableItem : STItem
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, readwrite) NSString *name;
@property (nonatomic, readwrite) NSString * buttonIconName;
@property (nonatomic, readwrite) NSString * collectableIconName;
@property (nonatomic, readwrite) UIColor * color;
@property (nonatomic, readwrite) NSString *keypath;

- (instancetype)initWithButtonIconName:(NSString *)buttonIconName name:(NSString *)name;

- (instancetype)initWithType:(NSInteger)type name:(NSString *)name buttonIconName:(NSString *)buttonIconName collectableIconName:(NSString *)collectableIconName color:(UIColor *)color keypath:(NSString *)keypath;

- (instancetype)initWithButtonIconName:(NSString *)buttonIconName name:(NSString *)name keypath:(NSString *)keypath;

+ (instancetype)itemWithButtonIconName:(NSString *)buttonIconName name:(NSString *)name keypath:(NSString *)keypath;

+ (instancetype)itemWithType:(NSInteger)type name:(NSString *)name buttonIconName:(NSString *)buttonIconName collectableIconName:(NSString *)collectableIconName color:(UIColor *)color keypath:(NSString *)keypath;

+ (instancetype)itemWithButtonIconName:(NSString *)buttonIconName name:(NSString *)name;

#pragma mark Items Dictionary
+ (NSDictionary *)targetItems;

+ (BOOL)hasAddedUntouchedItems;

+ (NSDictionary *)addedUntouchedItems;

@end