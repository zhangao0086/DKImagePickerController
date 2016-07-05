//
// Created by BLACKGENE on 2016. 4. 14..
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, STPhotoItemOrigin) {
    STPhotoItemOriginUndefined,
    //from elie camera
    STPhotoItemOriginManualCamera,
    STPhotoItemOriginQuickCamera,
    STPhotoItemOriginElie,
    STPhotoItemOriginExportedFromRoom,
    //animatable - special
    STPhotoItemOriginAnimatable,
    STPhotoItemOriginPostFocus,
    //animatable - assets
    STPhotoItemOriginAssetVideo,
    STPhotoItemOriginAssetLivePhoto,
    //exported
    STPhotoItemOriginGIFExportedVideo
};

typedef NS_ENUM(NSInteger, STPhotoViewType) {
    STPhotoViewTypeGrid,
    STPhotoViewTypeGridHigh,
    STPhotoViewTypeDetail,
    STPhotoViewTypeMinimum,
    STPhotoViewTypeEdit,
    STPhotoViewTypeEditAfterCapture,
    STPhotoViewTypeReviewAfterAnimatableCapture,
    STPhotoViewTypeLivePreview,
    STPhotoViewType_count
};

typedef NS_ENUM(NSInteger, STPhotoSource) {
    STPhotoSourceAssetLibrary,
    STPhotoSourceRoom,
    STPhotoSourceRemote,
    STPhotoSourceCapturedImageStorage,
    STPhotoSource_count
};

@interface STPhotos : NSObject
@end