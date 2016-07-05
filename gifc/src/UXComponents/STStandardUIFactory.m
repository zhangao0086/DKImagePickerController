//
// Created by BLACKGENE on 2015. 4. 2..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "STStandardUIFactory.h"

@implementation STStandardUIFactory {

}

+ (STStandardButton *)arrowUp:(STStandardButtonSetButtonsBlock)block{
    STStandardButton * button = [STStandardButton subAssistanceSize];
    block(button, @[@"arrowup"], nil);
    return button;
}

+ (STStandardButton *)arrowDown:(STStandardButtonSetButtonsBlock)block{
    STStandardButton * button = [STStandardButton subAssistanceSize];
    block(button, @[@"arrowdown"], nil);
    return button;
}

+ (UILabel *)labelBulletLighten {
    UILabel *label = [[UILabel alloc] init];
    label.size = CGSizeMake(50, [STStandardLayout widthBulletBig]);
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:[STStandardLayout widthBullet]];
    label.textColor = [STStandardUI textColorLighten];
    return label;
}

+ (UILabel *)labelBulletDarken {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:[STStandardLayout widthBullet]];
    label.size = CGSizeMake(50, [STStandardLayout widthBulletBig]);
    label.textColor = [STStandardUI textColorDarken];
    return label;
}

+ (UILabel *)labelStatusBar {
    UILabel *label = [[UILabel alloc] init];
    label.size = CGSizeMake(100, [STStandardLayout widthBulletMiddle]);
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:label.size.height];
    label.textColor = [STStandardUI textColorLighten];
    return label;
}

@end