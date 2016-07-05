//
// Created by BLACKGENE on 2014. 10. 13..
// Copyright (c) 2014 Eliecam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WCFastCollectionViewCell.h"
#import "WCFCImageView.h"

@class STPhotoItem;

@interface STThumbnailGridViewCell : WCFastCollectionViewCell <UIGestureRecognizerDelegate>

@property (nonatomic, readwrite) UIColor * filterRepresentiveColor;

@property (nonatomic, readonly) STPhotoItem * item;

- (void)presentItem:(STPhotoItem *)item;

- (void)presentItem:(STPhotoItem *)item animation:(BOOL)animation;

- (void)clearItem;
@end