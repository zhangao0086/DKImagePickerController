//
// Created by BLACKGENE on 7/13/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STAfterImageLayerView.h"
#import "STCapturedImageSetDisplayLayer.h"
#import "NSString+STUtil.h"
#import "STQueueManager.h"
#import "NSArray+STUtil.h"
#import "STMultiSourcingImageProcessor.h"


@implementation STAfterImageLayerView {
    NSArray<NSURL *>* _preheatedImageUrlsAfterEffectsApplied;
}

- (void)dealloc {
    _layerItem = nil;
    _preheatedImageUrlsAfterEffectsApplied = nil;
}

//- (void)setViews:(NSArray *)presentableObjects {
//    NSAssert(_layerItem, @"set _layerItem first");
//
//    if(_layerItem.effect){
//
//        if(_preheatedImageUrlsAfterEffectsApplied){
//            [super setViews:_preheatedImageUrlsAfterEffectsApplied];
//
//        }else{
//            Weaks
//            dispatch_async([STQueueManager sharedQueue].uiProcessing,^{
//                NSArray <NSURL *> * preheatedImageUrls = [presentableObjects mapWithIndex:^id(NSURL *imageUrl, NSInteger index) {
//                    NSAssert([imageUrl isKindOfClass:NSURL.class], @"only NSURL was allowed.");
//
//                    @autoreleasepool {
//                        NSURL * tempURLToApplyEffect = [[NSString stringWithFormat:@"%@_%@_f%d",
//                                        Wself.layerItem.uuid,
//                                        Wself.layerItem.effect,
//                                        index
//                        ] URLForTemp:@"filter_applied_after_image" extension:@"jpg"];
//
//                        if([[NSFileManager defaultManager] fileExistsAtPath:tempURLToApplyEffect.path]){
//                            //cached
//                            return tempURLToApplyEffect;
//
//                        }else{
//                            //newly create
//                            if([UIImageJPEGRepresentation([_layerItem.effect processEffect:[UIImage imageWithContentsOfFile:imageUrl.path]], 1)
//                                    writeToURL:tempURLToApplyEffect
//                                    atomically:NO]){
//                                return tempURLToApplyEffect;
//                            }
//                        }
//                        return nil;
//                    }
//                }];
//
//                if(preheatedImageUrls.count){
//                    dispatch_async(dispatch_get_main_queue(),^{
//                        _preheatedImageUrlsAfterEffectsApplied = preheatedImageUrls;
//                        [super setViews:_preheatedImageUrlsAfterEffectsApplied];
//                    });
//                }
//
//            });
//        }
//    }else{
//        _preheatedImageUrlsAfterEffectsApplied = nil;
//        [super setViews:presentableObjects];
//    }
//}
@end