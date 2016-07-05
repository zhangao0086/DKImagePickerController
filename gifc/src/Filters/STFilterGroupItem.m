//
//  SPFilterGroupItem.m
//  prism
//
//  Created by Hyojin Mo on 2013. 12. 2..
//  Copyright (c) 2013년 Starpret. All rights reserved.
//

#import "STFilterGroupItem.h"
#import "UIColor+STColorUtil.h"

@interface STFilterGroupItem (){
    NSString *_uid;
}
@end

@implementation STFilterGroupItem

- (void)parseWithCLUTFileName:(NSString *)fileName
{
    // 959270_dc485072070c41a8a8a7896b445ffd12_16_popart
    // [0] : representative color
    // [1] : uid
    // [2] : flag
    // [3] : tag (optional)
    
    NSArray *filterGroupInfo = [fileName componentsSeparatedByString:@"_"];
    NSUInteger numberOfInfo = [filterGroupInfo count];

    if (numberOfInfo > 0) {
        _representativeColor = [UIColor colorWithRGBHexString:[NSString stringWithFormat:@"#%@", filterGroupInfo[0]]];
        _representativeColor = [_representativeColor multiplyColorWithHue:1.f saturation:3.f brightness:1.f alpha:1.f];
    }
    
    if (numberOfInfo > 1) {
        _uid = filterGroupInfo[1];
    }
    
    if (numberOfInfo > 2) {
        self.type = (STFilterType) [filterGroupInfo[2] unsignedIntValue];
    }
    
    if (numberOfInfo > 3) {
        self.tag = filterGroupInfo[3];
    }
}

- (NSString *)uid; {
    return _uid;
}

@end
