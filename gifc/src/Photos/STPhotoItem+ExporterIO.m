//
// Created by BLACKGENE on 2016. 3. 31..
// Copyright (c) 2016 stells. All rights reserved.
//

#import "STPhotoItem+ExporterIO.h"
#import "BlocksKit.h"

@implementation STPhotoItem (ExporterIO)

DEFINE_ASSOCIATOIN_KEY(kExporting)
- (BOOL)exporting {
    return [[self bk_associatedValueForKey:kExporting] boolValue];
}

- (void)setExporting:(BOOL)exporting {
    @synchronized (self) {
        [self bk_associateValue:@(exporting) withKey:kExporting];

        //finished export
        if(!exporting && self.exporting){
            self.exportAsOnlyDefaultImageOfImageSet = NO;
        }
    }
}

DEFINE_ASSOCIATOIN_KEY(kExportAsOnlyDefaultImageOfImageSet)
- (BOOL)exportAsOnlyDefaultImageOfImageSet {
    return [[self bk_associatedValueForKey:kExportAsOnlyDefaultImageOfImageSet] boolValue];
}

- (void)setExportAsOnlyDefaultImageOfImageSet:(BOOL)exportAsOnlyDefaultImageOfImageSet {
    BOOL possibleToExport = self.sourceForCapturedImageSet!=nil;
    NSAssert(!exportAsOnlyDefaultImageOfImageSet || exportAsOnlyDefaultImageOfImageSet && possibleToExport, @"ImageSet is nil. Impossible to set YES to exportAsSingleDefaultImageOfImageSet.");
    [self bk_associateValue:@(possibleToExport && exportAsOnlyDefaultImageOfImageSet) withKey:kExportAsOnlyDefaultImageOfImageSet];
}

DEFINE_ASSOCIATOIN_KEY(kExportedTempFileURL)
- (NSURL *)exportedTempFileURL {
    return [self bk_associatedValueForKey:kExportedTempFileURL];
}

- (void)setExportedTempFileURL:(NSURL *)exportedTempFileURL {
    @synchronized (self) {
        //set temp url and notifiy
        [self willChangeValueForKey:@keypath(self.exportedTempFileURL)];
        [self bk_associateValue:exportedTempFileURL withKey:kExportedTempFileURL];
        self.exporting = NO;

        //update origin
        [self _updateOrRestoreOriginFromExportedTempFileURLIfNeeded];

        //commit
        [self didChangeValueForKey:@keypath(self.exportedTempFileURL)];
    }
}

DEFINE_ASSOCIATOIN_KEY(kBeforeExportedOrigin)
- (void)_updateOrRestoreOriginFromExportedTempFileURLIfNeeded{
    STPhotoItemOrigin newOrigin = STPhotoItemOriginUndefined;
    if(self.sourceForAsset){
        newOrigin = STPhotoItemOriginGIFExportedVideo;
    }

    if(newOrigin==STPhotoItemOriginUndefined){
        return;
    }

    if(self.exportedTempFileURL && self.origin!=newOrigin){
        [self bk_associateValue:@(self.origin) withKey:kBeforeExportedOrigin];
        self.origin = newOrigin;

    }else if(!self.exportedTempFileURL && self.origin==newOrigin){
        self.origin = (STPhotoItemOrigin)[[self bk_associatedValueForKey:kBeforeExportedOrigin] integerValue];
    }
}
@end