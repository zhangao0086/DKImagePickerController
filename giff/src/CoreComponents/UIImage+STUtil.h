
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

@interface UIImage (STUtil)

+ (UIImage *)imageBundled:(NSString *)aFileName;

+ (UIImage *)imageBundledCache:(NSString *)aFileName;

+ (NSArray *)imageArrayBundled:(NSArray *)fileNames;

+ (NSArray *)imageArrayBundledCache:(NSArray *)fileNames;

+ (UIImage *)imageWithDocument:(NSString *)relativeFilePath;

+ (UIImage *)imageWithURL:(NSURL *)url;

+ (UIImage *)imageAsColor:(UIColor *)color;

+ (UIImage *)imageAsColor:(UIColor *)color withSize:(CGSize)size;

+ (CGAffineTransform)fixingTransformForOrientation:(UIImageOrientation)orientation size:(CGSize)size;

+ (UIImageOrientation)imageOrientationFromCurrentDeviceOrientation;

+ (NSUInteger)exifOrientation:(UIImageOrientation)imageOrientation;

- (UIImage *)addText:(NSString *)text;

- (UIImage *)addText:(NSString *)text size:(CGSize)size backgroundColor:(UIColor *)backgroundColor fontSize:(CGFloat)fontSize fontColor:(UIColor *)fontColor;

- (UIImage *)negative;

- (UIImage *)fixOrientation;

- (UIImage *)fixOrientation:(UIImageOrientation)orientation;

- (UIImage *)invertAlpha;

- (BOOL)isDarkImage:(CGFloat)pixelAmountRatio;

- (UIImage *)animatedImageWithAppendingReverse:(NSTimeInterval)newDuration;

- (UIImage *)drawOver:(UIImage *)targetImage atPosition:(CGPoint)origin;

- (UIImage *)drawOver:(UIImage *)targetImage atPosition:(CGPoint)origin alpha:(float)alpha;

- (UIImage *)imageByCroppingNormalizedRect:(CGRect)normalizedRect;

- (UIImage *)imageByCroppingRect:(CGRect)rect;

- (UIImage *)imageByCroppingAspectFillRatio:(CGSize)sizeOfAspectRatio;

- (UIImage *)maskWithColor:(UIColor *)color;

- (UIImage *)clipAsRoundedRect:(CGSize)sizeToFit;

- (UIImage *)clipAsRoundedRectWithCornerRadius:(CGFloat)radius;

- (UIImage *)clipAsRoundedRectWithCornerRadius:(CGFloat)radius cropAsSquare:(BOOL)crop;

- (UIImage *)clipAsRoundedRect:(CGSize)sizeToFit cornerRadius:(CGFloat)radius;

- (UIImage *)clipAsCenteredCircle;

- (UIImage *)clipAsCircle:(CGFloat)diameter;

- (UIImage *)clipAsCircle:(CGFloat)diameter scale:(CGFloat)scale;

- (UIColor *)averageColor;

- (NSUInteger)exifOrientation;

- (CGSize)sizeWithRasterizationScale;
@end
