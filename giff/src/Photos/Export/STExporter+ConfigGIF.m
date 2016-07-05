//
// Created by BLACKGENE on 5/11/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STExporter+ConfigGIF.h"
#import "STPhotoItem.h"
#import "BlocksKit.h"
#import "NSGIF.h"
#import "NSString+STUtil.h"
#import "STPhotoItem+STExporterIOGIF.h"

@implementation STExporter (ConfigGIF)

/*
 * priority : Allowing > Targeting > Should
 */

/*
 * Allowing
 */
+ (BOOL)isAllowedToExportGIF:(STExportType)type{
    switch (type){
        case STExportTypeOpenIn:
        case STExportTypeShare:
        case STExportTypeFacebookMessenger:
        case STExportTypeTumblr:
        case STExportType_blank:
            return YES;

        default:
            return NO;
    }
}

- (BOOL)isAllowedToExportGIF{
    return [[self class] isAllowedToExportGIF:self.type];
}

/*
 * Targeting
 */
- (NSArray *)photoItemsCanExportGIF {
    if([self isAllowedToExportGIF]){
        NSArray * items = [self.photoItems bk_select:^BOOL(STPhotoItem * photoItem) {
            return [self.class canExportGIF:photoItem];
        }];
        return !items || items.count==0 ? nil : items;
    }
    return nil;
}

+ (BOOL)canExportGIF:(STPhotoItem *)photo{
    BOOL exportFromAsset = photo.sourceForAsset && (
            photo.origin == STPhotoItemOriginAssetLivePhoto
                    || photo.origin == STPhotoItemOriginAssetVideo
    );

    BOOL exportFromCapturedImageSet = photo.sourceForCapturedImageSet && (
            photo.origin == STPhotoItemOriginPostFocus
                    || photo.origin == STPhotoItemOriginAnimatable
    );

    BOOL can = exportFromAsset || exportFromCapturedImageSet;

#if DEBUG
    if([photo isExportedTempFileGIF]) {
        NSAssert(can, @"Wrong configured photo items origin");
    }
#endif
    return can;
}

+ (NSGIFRequest *)createRequestExportGIF:(STPhotoItem *)item{
    NSGIFRequest * request = nil;
    if([self canExportGIF:item]){
        switch (item.origin){
            case STPhotoItemOriginAnimatable:
            case STPhotoItemOriginPostFocus:{
                request = [[NSGIFRequest alloc] init];
                request.destinationVideoFile = [item.uuid URLForTemp:@"gif"];
                request.maxDuration = 3;
            }
                break;
            case STPhotoItemOriginAssetVideo:
                request = [NSGIFRequest requestWithSourceVideo:nil];;
                request.maxDuration = 4;
                break;

            case STPhotoItemOriginAssetLivePhoto:
                request = [NSGIFRequest requestWithSourceVideoForLivePhoto:nil];
                break;

            default:
                break;
        }
    }
    NSAssert(request, @"this origin is not supported. check STPhotoItem's origin");
    return request;
}

/*
 * Should
 */
+ (BOOL)shouldExportGIF:(NSArray<STPhotoItem *> *)photoItems{
    return photoItems.count ? [photoItems bk_match:^BOOL(STPhotoItem * photoItem) {
        return photoItem.exportGIFRequest != nil || photoItem.isExportedTempFileGIF;
    }] != nil : NO;
}

- (BOOL)shouldExportGIF{
    return [[self class] shouldExportGIF:self.photoItemsCanExportGIF];
}

@end