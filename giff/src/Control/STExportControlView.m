//
// Created by BLACKGENE on 7/25/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STExportControlView.h"
#import "STExportSelectView.h"
#import "UIView+STUtil.h"


@implementation STExportControlView {
    STExportSelectView * _exportSelectView;

}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }

    return self;
}

- (void)setExporterTypes:(NSArray *)exporterTypes {
    if(!_exportSelectView){
        _exportSelectView = [[STExportSelectView alloc] initWithSize:self.size];
        [self addSubview:_exportSelectView];
    }
    _exportSelectView.exporterTypes = exporterTypes;
}

- (NSArray *)exporterTypes {
    return _exportSelectView.exporterTypes;
}


- (void)createContent {
    [super createContent];


}

@end