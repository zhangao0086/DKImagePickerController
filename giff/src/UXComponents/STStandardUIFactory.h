//
// Created by BLACKGENE on 2015. 4. 2..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STStandardButton.h"

@interface STStandardUIFactory : NSObject

+ (STStandardButton *)arrowUp:(STStandardButtonSetButtonsBlock)block;

+ (STStandardButton *)arrowDown:(STStandardButtonSetButtonsBlock)block;

+ (UILabel *)labelBulletLighten;

+ (UILabel *)labelBulletDarken;

+ (UILabel *)labelStatusBar;
@end