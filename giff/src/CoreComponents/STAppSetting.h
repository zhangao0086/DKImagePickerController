//
// Created by BLACKGENE on 2014. 11. 10..
// Copyright (c) 2014 StellarStep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PAPreferences/PAPreferences.h>
#import "STApp+Products.h"

#pragma mark Define Settings Properties
// Rule : "_" prefix means "Private" and only just a storage, that must haven't any effect for UI updates and presentables things.
#define STAppSettingCorePropertiesImplementation \
@dynamic _keys; \
@dynamic _guid; \
@dynamic _firstLaunchedAppVersion; \
@dynamic _lastLaunchedBuildVersion; \
@dynamic _previousLaunchedBuildVersion; \
@dynamic _lastLaunchedDate; \
@dynamic _indexedSearchableContexts; \
@dynamic _addedButUntouchedKeys; \
@dynamic _geotagRequestedIds; \
@dynamic geotagEnabled; \
@dynamic geotagData; \

#define STAppSettingCorePropertiesInterface \
@property (nonatomic, assign) NSArray * _keys; \
@property (nonatomic, assign) NSString * _guid; \
@property (nonatomic, assign) NSDate * _lastLaunchedDate; \
@property (nonatomic, assign) NSDictionary * _indexedSearchableContexts; \
@property (nonatomic, assign) NSString * _firstLaunchedAppVersion; \
@property (nonatomic, assign) NSString * _lastLaunchedBuildVersion; \
@property (nonatomic, assign) NSString * _previousLaunchedBuildVersion; \
@property (nonatomic, assign) NSDictionary *_addedButUntouchedKeys; \
@property (nonatomic, assign) NSArray * _geotagRequestedIds; \
@property (nonatomic, assign) BOOL geotagEnabled; \
@property (nonatomic, assign) NSDictionary * geotagData; \

@interface STAppSetting : PAPreferences

STAppSettingCorePropertiesInterface

- (BOOL)isIndexedSearchableContext:(NSString *)context;

- (void)touchSearchableContext:(NSString *)context;

- (void)aquireGeotagDataIfAllowed;

- (void)clearGeotagDataIfAllowed;

- (void)didKeyFirstInitialized:(NSString *)key;

- (void)didMigratedKeyAdded:(NSString *)key;

- (void)didMigratedKeyRemoved:(NSString *)key;

- (BOOL)isNewAddedKey:(NSString *)key;

- (BOOL)touchNewAddedKeyIfNeeded:(NSString *)key;

+ (instancetype)get;

+ (BOOL)isKeyPathForInternalValue:(NSString *)keyPath;

- (void)whenSavedToAll:(NSString *)id withBlock:(void (^)(NSString *property, id value))block;

- (void)whenSavedByProperty:(NSString *)id keyPath:(NSString *)keyPath withBlock:(void (^)(NSString *property, id value))block;

- (BOOL)isFirstLaunch;

- (BOOL)isFirstLaunchSinceLastBuild;

- (NSInteger)appVersionDistanceSinceFirstLaunch;

- (void)willFirstLaunch;

- (NSString *)gidAppVersion;

- (void)touchForLastLaunchTime;

- (BOOL)isPassedTimeIntervalSinceLastLaunched:(NSTimeInterval)interval;

- (BOOL)isPassedHoursSinceLastLaunched:(NSUInteger)hour;

- (void)setValueForProduct:(id)value forKeyPath:(NSString *)keyPath;

- (void)setDefaultToChangable:(NSString *)key;

- (void)validate;

- (void)setPolicy;

- (void)setPolicyLaunchFirst;

- (void)setPolicyLaunchSinceLastBuildNotFirst:(NSString *)previousBuildVersion;

- (void)setSubscribe;

- (id)read:(NSString *)key;

@end