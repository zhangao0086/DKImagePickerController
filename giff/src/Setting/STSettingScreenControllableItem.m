//
// Created by BLACKGENE on 2015. 8. 17..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <BlocksKit/NSDictionary+BlocksKit.h>
#import "STSettingScreenControllableItem.h"
#import "STGIFFAppSetting.h"


@implementation STSettingScreenControllableItem {

}

- (instancetype)initWithButtonIconName:(NSString *)buttonIconName name:(NSString *)name {
    self = [super init];
    if (self) {
        self.buttonIconName = buttonIconName;
        self.name = name;
    }

    return self;
}

- (instancetype)initWithType:(NSInteger)type name:(NSString *)name buttonIconName:(NSString *)buttonIconName collectableIconName:(NSString *)collectableIconName color:(UIColor *)color keypath:(NSString *)keypath {
    self = [super init];
    if (self) {
        self.type = type;
        self.name = name;
        self.buttonIconName = buttonIconName;
        self.collectableIconName = collectableIconName;
        self.color = color;
        self.keypath = keypath;
    }

    return self;
}

+ (instancetype)itemWithType:(NSInteger)type name:(NSString *)name buttonIconName:(NSString *)buttonIconName collectableIconName:(NSString *)collectableIconName color:(UIColor *)color keypath:(NSString *)keypath {
    return [[self alloc] initWithType:type name:name buttonIconName:buttonIconName collectableIconName:collectableIconName color:color keypath:keypath];
}

+ (instancetype)itemWithButtonIconName:(NSString *)buttonIconName name:(NSString *)name {
    return [[self alloc] initWithButtonIconName:buttonIconName name:name];
}

- (instancetype)initWithButtonIconName:(NSString *)buttonIconName name:(NSString *)name keypath:(NSString *)keypath {
    self = [super init];
    if (self) {
        self.buttonIconName = buttonIconName;
        self.name = name;
        self.keypath = keypath;
    }
    return self;
}

+ (instancetype)itemWithButtonIconName:(NSString *)buttonIconName name:(NSString *)name keypath:(NSString *)keypath {
    return [[self alloc] initWithButtonIconName:buttonIconName name:name keypath:keypath];
}


- (NSString *)collectableIconName {
    return _collectableIconName ? _collectableIconName : _buttonIconName;
}

+ (NSDictionary *)targetItems{
    NSAssert(NO, @"not support controlled items yet.");

    @synchronized (self) {
        static NSMutableDictionary *items;
        if(items){
            return items;
        }
        items = [NSMutableDictionary dictionary];

#if DEBUG
        for(id item in [items allValues]) {
            STSettingScreenControllableItem *_item = [item isKindOfClass:NSArray.class] ? [item firstObject] : item;
            NSAssert(!!items[_item.keypath], @"item MUST have same keypath");
        }
#endif
        return items;
    }
}

+ (BOOL)hasAddedUntouchedItems {
    return [self addedUntouchedItems].count>0;
}

+ (NSDictionary *)addedUntouchedItems {
    return [self.targetItems bk_select:^BOOL(NSString * key, id obj) { return [[STGIFFAppSetting get] isNewAddedKey:key]; }];
}

@end