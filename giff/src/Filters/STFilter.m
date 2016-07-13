//
//  SPPrismFilter.m
//  prism
//
//  Created by Hyojin Mo on 2014. 3. 7..
//  Copyright (c) 2014년 Starpret. All rights reserved.
//

#import "STFilter.h"
#import "UIImage+STUtil.h"
#import "NSObject+STUtil.h"
#import "NSString+STUtil.h"

@interface STFilter ()

@property (nonatomic, strong) GPUImageLookupFilter *lookupFilter;
@property (nonatomic, strong) GPUImagePicture *lookupSource;
@property (nonatomic, strong, readwrite) NSString *filterName;

@end

// destory : https://github.com/BradLarson/GPUImage/issues/1602#issuecomment-208478065

@implementation STFilter{

};

- (id)initWith:(STFilterItem *)item
{
    NSAssert(item && item.uid, @"must valid uid here. at 'STFilter/initWith'");

    if(!item){
        return nil;
    }

    _item = item;

    if(_item.fileNameForCLUT){
        return [self initWithLookupName:_item.fileNameForCLUT];

    }else{
        return [self initWithFilters:nil];
    }
}

- (id)initWithFilters:(NSArray<GPUImageFilter *> *)arrayOfFilters {
    self = [super init];
    if (self) {
        if(arrayOfFilters.count){
            self.filterName = [@"elie.filter.definedFilters" st_add:self.st_uid];
            self.initialFilters = arrayOfFilters;
            self.terminalFilter = [arrayOfFilters lastObject];

        }else{
            GPUImageFilter * imageFilter =  [[GPUImageFilter alloc] init];
            self.filterName = [@"elie.filter.emptyFilter." st_add:self.st_uid];
            self.initialFilters = @[imageFilter];
            self.terminalFilter = imageFilter;
        }
    }
    return self;
}


#pragma mark CLUT filter
- (id)initWithLookupName:(NSString *)lookupName
{
    self = [super init];
    if (self) {
        self.filterName = lookupName;

        UIImage * image = [UIImage imageBundledCache:lookupName];

        NSAssert(image, @"must valid CLUT image here. at 'STFilter/initWithLookupName'");

        [self prepareFilterWithLookupImage:image];
    }
    return self;
}

- (id)initWithLookupImage:(UIImage *)lookupImage
{
    self = [super init];
    if (self) {
        self.filterName = [@"elie.filter.lookupimage." st_add:lookupImage.st_uid];
        
        [self prepareFilterWithLookupImage:lookupImage];
    }
    return self;
}

- (void)useNextFrameForImageCapture
{
    [self.lookupSource processImage];
    
    [super useNextFrameForImageCapture];
}

- (void)clearChildFilters {
    [self removeAllTargets];

    if(self.lookupFilter){
        self.initialFilters = @[self.lookupFilter];
        self.terminalFilter = self.lookupFilter;
    }
}

#pragma mark - Private methods

- (void)prepareFilterWithLookupImage:(UIImage *)lookupImage
{
    self.lookupFilter = [[GPUImageLookupFilter allocWithZone:NULL] init];
    [self addFilter:self.lookupFilter];

    self.lookupSource = [[GPUImagePicture allocWithZone:NULL] initWithImage:lookupImage];

    [self.lookupSource addTarget:self.lookupFilter atTextureLocation:1];
    [self.lookupSource processImage];

    [self.lookupSource removeTarget:self.lookupFilter];

    self.initialFilters = @[self.lookupFilter];
    self.terminalFilter = self.lookupFilter;
}


- (void)dealloc; {
//    NSLog(@"- dealloc %@", self.filterName);

    _item = nil;

    self.lookupFilter = nil;
    self.lookupSource = nil;
    self.initialFilters = nil;
    self.terminalFilter = nil;

    if(self.targets.count){
        [self removeAllTargets];
    }
}
@end
