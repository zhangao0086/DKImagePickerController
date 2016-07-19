//
//  SPPrismFilter.h
//  prism
//
//  Created by Hyojin Mo on 2014. 3. 7..
//  Copyright (c) 2014년 Starpret. All rights reserved.
//

#import "GPUImageFilterGroup.h"
#import "STFilterItem.h"

@interface STFilter : GPUImageFilterGroup

@property (nonatomic, readonly) NSString *filterName;
@property (nonatomic, readonly) STFilterItem * item;

- (id)initWith:(STFilterItem *)item;
- (id)initWithFilters:(NSArray<GPUImageOutput <GPUImageInput> *> *)filters;

- (id)initWithLookupName:(NSString *)lookupName;
- (id)initWithLookupImage:(UIImage *)lookupImage;

- (void)clearChildFilters;
@end
