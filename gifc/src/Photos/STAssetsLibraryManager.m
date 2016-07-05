#import "STAssetsLibraryManager.h"
#import "GPUImageOutput.h"

@implementation STAssetsLibraryManager

static const NSUInteger chunkSize = 50;
static NSUInteger chunkIndex = 0;
static NSInteger numbersOfAssets = 0;

+ (ALAssetsLibrary *)sharedManager
{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *assetsLibrary = nil;
    
    dispatch_once(&pred, ^{
        assetsLibrary = [[ALAssetsLibrary alloc] init];
        [self resetPhotosEnumerater];
    });
    
    return assetsLibrary;
}

+ (void)resetPhotosEnumerater; {
    chunkIndex = 0;
    numbersOfAssets = 0;
}

+ (void)enumerateNextGroupSavedPhotos:(ALAssetsGroupEnumerationResultsBlock)enumerationBlock completion:(void(^)(void))block{
    [self enumerateGroupSavedPhotosWithChunk:chunkIndex usingBlock:enumerationBlock completion:^{
        !block?:block();
        chunkIndex++;
    }];
}

+ (NSUInteger)lastChunkIndex{
    return [@((numbersOfAssets - (numbersOfAssets % chunkSize)) / chunkSize) unsignedIntegerValue];
}

+ (BOOL)hasNextPhotos{
    if(numbersOfAssets<1){
        return NO;
    }
    return chunkIndex <= [self lastChunkIndex];
}

+ (void)enumerateGroupSavedPhotosWithChunk:(NSUInteger)index usingBlock:(ALAssetsGroupEnumerationResultsBlock)enumerationBlock completion:(void(^)(void))block{
    NSParameterAssert(enumerationBlock);
    NSParameterAssert(block);

    [[self sharedManager] enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            if(!numbersOfAssets && group.numberOfAssets){
                numbersOfAssets = group.numberOfAssets;
            }

            if([self hasNextPhotos]){
                NSRange range = index < [self lastChunkIndex] ? NSMakeRange((numbersOfAssets-chunkSize)-(chunkSize*index), chunkSize) : NSMakeRange(0, numbersOfAssets % chunkSize);
                [group enumerateAssetsAtIndexes:[[NSIndexSet alloc] initWithIndexesInRange:range] options:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    if(result){
                        if(result.defaultRepresentation.size==0 || result.defaultRepresentation.dimensions.height < 2){
                            return;
                        }
                        enumerationBlock(result,index, stop);
                    }else{
                        // Assets ended.
                        runOnMainQueueWithoutDeadlocking(block);
                    }
                }];

            }else{
                NSLog(@"WARN : does not remain next photos");
                runOnMainQueueWithoutDeadlocking(block);
            }
        }else {
            // Groups ended.
        }
    } failureBlock:^(NSError *error) {

        runOnMainQueueWithoutDeadlocking(block);
    }];
}

+ (void)checkLast:(void(^)(ALAsset *result))block{
    [[self sharedManager] enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            if(!group.numberOfAssets){
                block(nil);
            }

            [group enumerateAssetsAtIndexes:[[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange((NSUInteger) (group.numberOfAssets-1), 1)] options:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if(result){
                    block(result);
                }
            }];

        }else {
            // Groups ended.
        }
    } failureBlock:^(NSError *error) {
        block(nil);
    }];
}

@end
