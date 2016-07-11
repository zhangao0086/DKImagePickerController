//
// Created by BLACKGENE on 5/11/16.
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STPhotoItem+STExporterIOGIF.h"
#import "NSGIF.h"
#import "BlocksKit.h"
#import "STPhotoItem+STExporterIO.h"

NSString * const STPhotoItemsGIFsFileNamePrefix = @"com_stells_exported_gif_";

@implementation STPhotoItem (STExporterIOGIF)

- (BOOL)isExportedTempFileGIF{
    return self.exportedTempFileURL && [self.exportedTempFileURL.lastPathComponent hasPrefix:STPhotoItemsGIFsFileNamePrefix];
}

+ (NSURL *)exportingTempFileGIF:(NSURL *)originalURL extension:(NSString *)extension{
    NSString *gifFileName = [[[originalURL lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:extension?:@"gif"];
    //apply prefix
    gifFileName = [STPhotoItemsGIFsFileNamePrefix stringByAppendingString:gifFileName];

    return [NSURL fileURLWithPath:[[originalURL.path stringByDeletingLastPathComponent] stringByAppendingPathComponent:gifFileName]];
}

DEFINE_ASSOCIATOIN_KEY(kExportGIFRequest)
- (NSGIFRequest *)exportGIFRequest{
    return [self bk_associatedValueForKey:kExportGIFRequest];
}

- (void)setExportGIFRequest:(NSGIFRequest *)exportGIFRequest {
    if(exportGIFRequest){
        NSAssert(!(self.origin==STPhotoItemOriginAssetVideo && self.origin==STPhotoItemOriginAssetLivePhoto) || exportGIFRequest.maxDuration==3, @"Allowed maxDuration is 3 seconds for STPhotoItemOriginAssetVideo, STPhotoItemOriginAssetLivePhoto.");
    }else{
        //interrupt when set nil
        NSGIFRequest * request = [self bk_associatedValueForKey:kExportGIFRequest];
        if(request){
//            [request cancelIfNeeded];
        }
    }
    [self bk_associateValue:exportGIFRequest withKey:kExportGIFRequest];
}
@end