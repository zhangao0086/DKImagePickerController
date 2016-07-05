//
// Created by BLACKGENE on 2016. 2. 2..
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STApp+Products.h"
#import "STExportContentView.h"

@implementation STExportContentView

- (void)createContent {
    [super createContent];
}

- (void)setExporter:(STExporter *)item {
    _exporter = item;

    Weaks
    if(_exporter){
        [self loadContents];
        [self layoutSubviews];

    }else{
        [self unloadContents];
    }
}

- (void)loadContents {

}

- (void)unloadContents {

}

- (void)reloadContents{

}

- (void)loadContentsLazily {

}

- (void)unloadContentsLazily:(void (^)(BOOL finished))block {
    !block?:block(YES);
}


@end
