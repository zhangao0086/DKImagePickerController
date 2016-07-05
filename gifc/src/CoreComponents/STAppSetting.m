//
// Created by BLACKGENE on 2014. 11. 10..
// Copyright (c) 2014 StellarStep. All rights reserved.
//

#import "NSArray+BlocksKit.h"
#import "STApp.h"
#import "STAppSetting.h"
#import "NSObject+STUtil.h"
#import "NSArray+STUtil.h"
#import "NSObject+STAppProducts.h"
#import "INTULocationManager.h"
#import "UIApplication+STUtil.h"
#import "UIAlertController+Blocks.h"
#import "NSMutableDictionary+ImageMetadata.h"

@implementation STAppSetting

static NSMutableArray *_loadedKeys;
static BOOL _isFirstLaunch;
static BOOL _isFirstLaunchSinceLastBuild;

STAppSettingCorePropertiesImplementation

#pragma mark STSetting initialize (the most first)
- (void)initialize{
    if(![[STApp buildVersion] isEqualToString:self._lastLaunchedBuildVersion]){
        self._previousLaunchedBuildVersion = self._lastLaunchedBuildVersion;
        self._lastLaunchedBuildVersion = [STApp buildVersion];
        _isFirstLaunchSinceLastBuild = YES;
    }
}

#pragma mark check firstRun
- (BOOL)isFirstLaunch{
    return _isFirstLaunch;
}

- (BOOL)isFirstLaunchSinceLastBuild{
    return _isFirstLaunchSinceLastBuild;
}

- (NSInteger)appVersionDistanceSinceFirstLaunch{
    return [STApp appVersionsDistanceWithCurrent:self._firstLaunchedAppVersion];
}

- (void)willFirstLaunch {
    _isFirstLaunch = YES;
    self._guid = [STApp createNewGid];
    self._firstLaunchedAppVersion = [STApp appVersion];
}

- (NSString *)gidAppVersion {
    return self._guid ? [[self._guid split:[STApp gidDelimeter]] st_objectOrNilAtIndex:1] : nil;
}

- (void)touchForLastLaunchTime {
    self._lastLaunchedDate = [NSDate date];
}

- (BOOL)isPassedTimeIntervalSinceLastLaunched:(NSTimeInterval)interval{
    if(self._lastLaunchedDate){
        return [[NSDate date] timeIntervalSinceDate:self._lastLaunchedDate] >= interval;
    }
    return YES;
}

- (BOOL)isPassedHoursSinceLastLaunched:(NSUInteger)hour{
    return [self isPassedTimeIntervalSinceLastLaunched:60 * 60 * hour];
}

#pragma mark In-App Properties for Products - Common
- (void)setValueForProduct:(id)value forKeyPath:(NSString *)keyPath{
    NSString * productId = [self productIdForKeyPath:keyPath];
    if(productId){
        [[STApp defaultAppClass] setValue:[self userDefaults] value:value forKeyPath:keyPath forProductId:productId defaultValue:[self productDefaultValueForKeyPath:keyPath]];
    }
}


#pragma mark defaults
- (void)setDefaultToChangable:(NSString *)key; {

}

- (void)validate {

}

- (void)setPolicy {
    //geo tag
    if(!self.geotagEnabled && self.geotagData){
        self.geotagData = nil;
    }
}

- (void)setPolicyLaunchFirst {

}

- (void)setPolicyLaunchSinceLastBuildNotFirst:(NSString *)previousBuildVersion {

}

- (void)setSubscribe{

}

static NSMutableDictionary *_fastReadDict;
- (void)setFastReadable{
    Weaks
    BlockOnce(^{
        _fastReadDict = [NSMutableDictionary dictionary];

        //changd
        [Wself whenSavedToAll:_fastReadDict.st_uid withBlock:^(NSString *key, id value) {
            @synchronized (Wself) {
                value ? (_fastReadDict[key] = value) : [_fastReadDict removeObjectForKey:key];
            }
        }];

        //initialize
        for(NSString * key in [Wself st_propertyNames]){
            id value = [Wself valueForKey:key];
            if(value){
                _fastReadDict[key] = value;
            }
        }
    });
}

- (id)read:(NSString *)key{
    if(!_fastReadDict[key]){
        id value = [self valueForKey:key];
        if(!value){
            return nil;
        }
        @synchronized (self) {
            _fastReadDict[key] = value;
        }
    }
    id value = _fastReadDict[key];
    return value;
}

#pragma mark migrate keys
- (void)migrate{
    NSParameterAssert(_loadedKeys);
    NSAssert([[[self st_propertyNames] symmetricDifference:_loadedKeys] count]==0, @"Migration start Error : must same 'st_propertyNames' and '_loadedKeys'. Check first '@dynamic newProperty' has added");

    if(!isEmpty(_loadedKeys)){
        Weaks
        //first run
        if(isEmpty(self._keys)){
            [_loadedKeys bk_each:^(id obj) {
                [Wself didKeyFirstInitialized:obj];
            }];
            self._keys = [NSArray arrayWithArray:[_loadedKeys copy]];
            [self synchronize];
            [self willFirstLaunch];
        }
        //exists
        else{
            // migrate new keys
            NSArray *diffKeys = [_loadedKeys symmetricDifference:self._keys];
            if(diffKeys.count){
                NSArray * addedKeys = [_loadedKeys intersectionWithArray:diffKeys];
                [addedKeys bk_map:^id(id obj) {
                    NSLog(@"(i) found new added key : %@", obj);
                    [Wself didMigratedKeyAdded:obj];
                    return obj;
                }];

                NSArray * deprecatedKeys = [self._keys intersectionWithArray:diffKeys];
                for(NSString * dKey in deprecatedKeys){
                    NSLog(@"(i) found deleted key : %@", dKey);
                    [Wself didMigratedKeyRemoved:dKey];
                }

                if(addedKeys.count || deprecatedKeys.count){
                    self._keys = [NSArray arrayWithArray:[_loadedKeys copy]];
                    [self synchronize];
                }
            }
        }

        NSAssert([[_loadedKeys symmetricDifference:self._keys] count]==0, @"Migration result Error : must same '_loadedKeys' and '_keys'");
    }
}

- (void)didKeyFirstInitialized:(NSString *)key; {
    [self setDefaultToChangable:key];
}

- (void)didMigratedKeyAdded:(NSString *)key; {
    [self setDefaultToChangable:key];
    [self keyToNewAddedKeysIfNeeded:key set:YES];
}

- (void)didMigratedKeyRemoved:(NSString *)key; {

}

#pragma mark New Key
- (BOOL)keyToNewAddedKeysIfNeeded:(NSString *)key set:(BOOL)set {
    BOOL performed = NO;
    if([@keypath(self._addedButUntouchedKeys) isEqualToString:key]){
        return performed;
    }

    NSMutableDictionary * dictionary = [NSMutableDictionary dictionaryWithDictionary:self._addedButUntouchedKeys];
    if(set){
       dictionary[key] = [STApp buildVersion];
       performed = YES;
    }else{
       if((performed = !!dictionary[key])){
           [dictionary removeObjectForKey:key];
       }
    }

    if(performed){
        NSAssert(!self._addedButUntouchedKeys || [self._addedButUntouchedKeys.allKeys symmetricDifference:dictionary.allKeys].count>0, @"keyToNewAddedKeysIfNeeded result Error : Maybe you currently did update from newer version to old version. must NOT same '_addedButUntouchedKeys' and performed dictionary.");
        self._addedButUntouchedKeys = dictionary;
    }else{
        NSAssert([self._addedButUntouchedKeys.allKeys symmetricDifference:dictionary.allKeys].count==0, @"keyToNewAddedKeysIfNeeded result Error : must same '_addedButUntouchedKeys' and performed dictionary");
    }

    return performed;
}

- (BOOL)isNewAddedKey:(NSString *)key{
    return [self._addedButUntouchedKeys hasKey:key];
}

- (BOOL)touchNewAddedKeyIfNeeded:(NSString *)key{
    return [self keyToNewAddedKeysIfNeeded:key set:NO];
}

#pragma mark impl
- (id)init; {
    self = [super init];
    if (self) {
        self.shouldAutomaticallySynchronize = NO;
        [self initialize];
        [self migrate];
        [self validate];
        [self setPolicy];
        if(self.isFirstLaunch){
            [self setPolicyLaunchFirst];
        }else if(self.isFirstLaunchSinceLastBuild){
            [self setPolicyLaunchSinceLastBuildNotFirst:self._previousLaunchedBuildVersion];
        }
        [self setSubscribe];
        [self setFastReadable];
    }
    return self;
}

+ (instancetype)get{
    return [self sharedInstance];
}

+ (NSString *)defaultsKeyForPropertyName:(NSString *)key{
    if(!_loadedKeys){
        _loadedKeys = [NSMutableArray array];
    }
    [_loadedKeys addObject:key];
    return key;
};

+ (BOOL)isKeyPathForInternalValue:(NSString*)keyPath{
    return [keyPath hasPrefix:@"_"];
}

- (void)whenSavedToAll:(NSString *)name withBlock:(void (^)(NSString * property, id value))block {
    NSParameterAssert(name!=nil);

    WeakSelf weakSelf = self;
    [[self st_propertyNames] bk_each:^(id obj) {
        [weakSelf whenSavedByProperty:name keyPath:obj withBlock:block];
    }];
}

- (void)whenSavedByProperty:(NSString *)name keyPath:(NSString *)keyPath withBlock:(void (^)(NSString * property, id value))block {
    NSParameterAssert(name!=nil);

    if(block){
        [self st_observe:keyPath block:^(id value, __weak id _weakSelf) {
            if([NSThread isMainThread]){
                block(keyPath, value);
            }else{
                dispatch_async(dispatch_get_main_queue(),^{
                    block(keyPath, value);
                });
            }
        }];

    }else{
        [self removeObserver:self forKeyPath:keyPath];
    }
}

#pragma mark SearchableIndex
- (BOOL)isIndexedSearchableContext:(NSString *)context{
    return [self._indexedSearchableContexts hasKey:context];
}

- (void)touchSearchableContext:(NSString *)context{
    @synchronized (self) {
        NSMutableDictionary * indexed = [self._indexedSearchableContexts mutableCopy];
        if(!indexed){
            indexed = [NSMutableDictionary dictionary];
        }
        indexed[context] = [@([[NSDate alloc] init].timeIntervalSince1970) stringValue];
        self._indexedSearchableContexts = indexed;
        [self synchronize];
    }
}


#pragma mark GeoLocation
- (void)aquireGeotagDataIfAllowed {
    Weaks
    BOOL neededEnabled = self.geotagEnabled;

    /*
     * check enabled by user
     */
    if(!neededEnabled){
        [self clearGeotagDataIfAllowed];
        return;
    }

    /*
     * check preconditions
     */
    switch([INTULocationManager locationServicesState]){
        case INTULocationServicesStateAvailable:
        case INTULocationServicesStateNotDetermined:
            //request
            break;

        case INTULocationServicesStateDenied:
        case INTULocationServicesStateDisabled:{
            [[UIApplication sharedApplication] openSettings:NSLocalizedString(@"alert.permission.denied",@"") cancel:^{
                [Wself clearGeotagDataIfAllowed];
                Wself.geotagEnabled = NO;
            }];
        }
            return;

        case INTULocationServicesStateRestricted:{
            self.geotagEnabled = NO;
            [self clearGeotagDataIfAllowed];
            [UIAlertController showAlertInViewController:[self st_rootUVC]
                                               withTitle:nil
                                                 message:NSLocalizedString(@"alert.permission.restricted",@"")
                                       cancelButtonTitle:nil
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:@[NSLocalizedString(@"OK", @"")]
                                                tapBlock:nil];
        }
            return;
    }

    /*
     * request location
     */

    //http://www.perspecdev.com/blog/2012/02/22/using-corelocation-on-ios-to-track-a-users-distance-and-speed/
    INTULocationRequestID requestID = [[INTULocationManager sharedInstance] requestLocationWithDesiredAccuracy:INTULocationAccuracyBlock timeout:10 block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
        switch (status){
            case INTULocationStatusSuccess:
            case INTULocationStatusTimedOut:{
                //save
                NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
                dictionary.location = currentLocation;
                Wself.geotagData = dictionary;
                break;
            }

            case INTULocationStatusServicesDenied:
            case INTULocationStatusServicesNotDetermined:
                [Wself clearGeotagDataIfAllowed];
                Wself.geotagEnabled = NO;
                break;

            case INTULocationStatusServicesDisabled:
                [[UIApplication sharedApplication] openSettings:NSLocalizedString(@"alert.permission.location.denied",@"")];

            case INTULocationStatusServicesRestricted:
            case INTULocationStatusError:
                [Wself clearGeotagDataIfAllowed];
                Wself.geotagEnabled = NO;
                break;

        }
    }];

    /*
     * did requested : save request history (append if histories are exists or create new one.)
     */
    NSMutableArray *requestedIDs = Wself._geotagRequestedIds ? [NSMutableArray arrayWithArray:Wself._geotagRequestedIds] : [@[] mutableCopy];
    if(![requestedIDs containsObject:@(requestID)]){
        [requestedIDs addObject:@(requestID)];
    }
    Wself._geotagRequestedIds = requestedIDs;
}

- (void)clearGeotagDataIfAllowed {
    for(id reqId in self._geotagRequestedIds){
        [[INTULocationManager sharedInstance] forceCompleteLocationRequest:(INTULocationRequestID)[reqId integerValue]];
    }
    self._geotagRequestedIds = nil;
    self.geotagData = nil;
}

@end
