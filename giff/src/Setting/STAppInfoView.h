//
// Created by BLACKGENE on 2015. 8. 26..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SCGridView;
@class STUIContentAlignmentView;


@interface STAppInfoView : UIScrollView
@property (nonatomic, readonly) SCGridView *gridView;
@property (nonatomic, readonly) STUIContentAlignmentView * bottomView;
@property (nonatomic, readonly) STStandardButton * closeButton;

- (void)setContents;

- (void)updateContent;

- (void)removeContents;

- (void)expressWhenPresentIfNeeded:(BOOL)force;
@end