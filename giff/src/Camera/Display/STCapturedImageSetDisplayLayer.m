#import "STCapturedImage.h"
#import "STCapturedImageSetDisplayLayer.h"
#import "STCapturedImageSet.h"

@implementation STCapturedImageSetDisplayLayer {

}
- (instancetype)initWithImageSet:(STCapturedImageSet *)imageSet {
    self = [super init];
    if (self) {
        _imageSet = imageSet;
    }

    return self;
}


+ (instancetype)layerWithImageSet:(STCapturedImageSet *)imageSet {
    return [[self alloc] initWithImageSet:imageSet];
}

@end