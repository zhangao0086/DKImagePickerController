/*
 * Code Creation
 *
The ECPropertyDefineLazy macro is defined like this:

#define ECPropertyDefineLazy(name, type, ...)       \
    @property (__VA_ARGS__) type name##Lazy; \
    @property (__VA_ARGS__) type name; \
    - (type) name##LazyInit

#define ECPropertySynthesizeLazy(name, setter, type)    \
    @synthesize name##Lazy = _##name; \
    - (type) name { if (!_##name) self.name##Lazy = [self name##LazyInit]; return   self.name##Lazy; } \
    - (void) setter: (type) value { self.name##Lazy = value; }

 */

#import <AGGeometryKit/CGGeometry+AGGeometryKit.h>
#import <AGGeometryKit/AGKQuad.h>
#import <objc/runtime.h>

#ifdef DEBUG
#define NSLog(args...) CustomLog(__FILE__, __LINE__, __PRETTY_FUNCTION__, args)
static inline void CustomLog(const char *file, int lineNumber, const char *functionName, NSString *format, ...)
{
    va_list ap;
    va_start (ap, format);
    if ([format hasSuffix:@"\n"])
        format = [format substringToIndex:[format length] - 1];
    format = [format stringByAppendingFormat:@" %@:%d %d\n", [[NSString stringWithUTF8String:file] lastPathComponent], lineNumber, [NSThread isMainThread]];
    va_end (ap);
    fprintf(stderr, "%s",[[[NSString alloc] initWithFormat:format arguments:ap] UTF8String]);
}
#else
   #define NSLog( s, ... )
#endif

#define NSLocalizedFormatString(fmt, ...) [NSString stringWithFormat:NSLocalizedString(fmt, nil), __VA_ARGS__]

#define ST_FW(view) (view.frame.size.width)
#define ST_FH(view) (view.frame.size.height)
#define ST_PP(p) CGPointMake(p, p)
#define ST_RS(size) CGRectMake(0,0, size, size)
#define ST_RSIZE(r) (r.size.width*r.size.height)
#define ST_DIF_RSIZE(r_big, r_small) (ST_RSIZE(r_big) > ST_RSIZE(r_small))
#define ST_XSIZE(size, factor) (CGSizeMake(size.width*factor, size.height*factor))
#define ST_CENTER_R_SWH(size, w, h) CGRectMake((w-size)*.5, (h-size)*.5, size, size)

#pragma mark -
#pragma mark ** Convenience macros **

// Quickly make an NSError
#define AMN_QUICK_ERROR(error_code, error_description) [NSError errorWithDomain:NSStringFromClass([self class]) code:error_code userInfo:[NSDictionary dictionaryWithObject:error_description forKey:NSLocalizedDescriptionKey]];

// Quickly get portrait mode
#define AMN_ORIENTATION_IS_PORTRAIT UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])

#pragma mark -
#pragma mark ** Log macros **

// standard types
#define bb(object)    NSLog(@"" #object @" %@", (object ? @"YES" : @"NO") );
#define logchar(object)    NSLog(@"" #object @" %c", object );
#define logint32(object)   NSLog(@"" #object @" %d", object );
#define loguint32(object)  NSLog(@"" #object @" %u", object );
#define loglong(object)    NSLog(@"" #object @" %ld", object );
#define logulong(object)   NSLog(@"" #object @" %lu", object );
#define logint64(object)   NSLog(@"" #object @" %qi", object );
#define loguint64(object)  NSLog(@"" #object @" %qu", object );
#define ff(object)   NSLog(@"" #object @" %f",object );
#define dd(object)  NSLog(@"" #object @" %lf",object );

// NSInteger and NSInteger are platform independant integer types
#if __LP64__ || (TARGET_OS_EMBEDDED && !TARGET_OS_IPHONE) || TARGET_OS_WIN32 || NS_BUILD_32_LIKE_64
#define ii(object)     NSLog(@"" #object @" %ld", object );
#define uii(object)    NSLog(@"" #object @" %lu", object );
#else
#define ii(object)     NSLog(@"" #object @" %d", object );
#define uii(object)    NSLog(@"" #object @" %u", object );
#endif

// Various Cocoa/Objective-C log macros
#define oo(object)  NSLog(object ? [object description] : @"nil");
#define ood(object)  NSLog(@"%@" @"" #object, [object description]);
#define logclass(object)  NSLog(@"[" #object @" class] %@", NSStringFromClass([object class]));
#define logmethod          NSLog(@"%@ %@:%d\n%@", NSStringFromSelector(_cmd), [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, self);
#define logend_method      NSLog(@"END %@", NSStringFromSelector(_cmd));
#define logmethod_name     NSLog(@"%p %@ %@", self, NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#define logmethod_thread   NSLog(@"%@ %@ %@:%d\n%@", NSStringFromSelector(_cmd), [NSThread currentThread], [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, self);
#define logclass_method    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

// Profiling Macros
#define START_TIME(tag) NSDate *startTime_ ## tag = [NSDate date];NSLog(@"start           " #tag);
#define CHECK_TIME(tag) NSLog(@"elapsed %0.5f " #tag, [[NSDate date] timeIntervalSinceDate:startTime_ ## tag]);

// Various Cocoa struct log macros
// NSRange
#define logrange(range)    NSLog(@"" #range @" loc:%u len:%u", range.location, range.length );
// CGPoint
#define pp(point)    NSLog(@"" #point @" x:%f y:%f", point.x, point.y );
// CGSize
#define ss(size)      NSLog(@"" #size @" width:%f height:%f", size.width, size.height );
// CGRect
#define rr(rect)      NSLog(@"" #rect @" x:%f y:%f w:%f h:%f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height );
// CLLocationCoordinate2D
#define logcoord2d(coord)  NSLog(@"" #coord @" lat,lon: %+.6f,%+.6f",coord.latitude, coord.longitude );

#pragma mark -
#pragma mark ** Assertion macros **

// Standard Assertions
#define ASSERT_NIL(x)           NSAssert4((x == nil), @"\n\n    ****  Unexpected Nil Assertion  ****\n    ****  Expected nil, but " #x @" is not nil.\nin file:%s at line %i in Method %@ with object:\n %@", __FILE__, __LINE__, NSStringFromSelector(_cmd), self)
#define ASSERT_NOT_NIL(x)       NSAssert4((x != nil), @"\n\n    ****  Unexpected Nil Assertion  ****\n    ****  Expected not nil, " #x @" is nil.\nin file:%s at line %i in Method %@ with object:\n %@", __FILE__, __LINE__, NSStringFromSelector(_cmd), self)
#define ASSERT_ALWAYS           NSAssert4(FALSE, @"\n\n    ****  Unexpected Assertion  **** \nAssertion in file:%s at line %i in Method %@ with object:\n %@", __FILE__, __LINE__, NSStringFromSelector(_cmd), self)
#define ASSERT_TRUE(test)       NSAssert4(test, @"\n\n    ****  Unexpected Assertion  **** \nAssertion in file:%s at line %i in Method %@ with object:\n %@", __FILE__, __LINE__, NSStringFromSelector(_cmd), self)
#define ASSERT_FALSE(test)      NSAssert4(!test, @"\n\n    ****  Unexpected Assertion  **** \nAssertion in file:%s at line %i in Method %@ with object:\n %@", __FILE__, __LINE__, NSStringFromSelector(_cmd), self)
#define ASSERT_WITH_MESSAGE(x)                  NSAssert5(FALSE, @"\n\n    ****  Unexpected Assertion  **** \nReason: %@\nAssertion in file:%s at line %i in Method %@ with object:\n %@", x, __FILE__, __LINE__, NSStringFromSelector(_cmd), self)
#define ASSERT_TRUE_WITH_MESSAGE(test, msg)     NSAssert5(test, @"\n\n    ****  Unexpected Assertion  **** \nReason: %@\nAssertion in file:%s at line %i in Method %@ with object:\n %@", msg, __FILE__, __LINE__, NSStringFromSelector(_cmd), self)
#define ASSERT_FALSE_WITH_MESSAGE(test, msg)    NSAssert5(!test, @"\n\n    ****  Unexpected Assertion  **** \nReason: %@\nAssertion in file:%s at line %i in Method %@ with object:\n %@", msg, __FILE__, __LINE__, NSStringFromSelector(_cmd), self)

// Useful, protective assertion macros
#define ASSERT_IS_CLASS(x, class)    NSAssert5([x isKindOfClass:class], @"\n\n    ****  Unexpected Class Assertion  **** \nReason: Expected class:%@ but got:%@\nAssertion in file:%s at line %i in Method %@\n\n", NSStringFromClass(class), x, __FILE__, __LINE__, NSStringFromSelector(_cmd))
#define SUBCLASSES_MUST_OVERRIDE     NSAssert2(FALSE, @"%@ Subclasses MUST override this method:%@\n\n", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#define SHOULD_NEVER_GET_HERE        NSAssert4(FALSE, @"\n\n    ****  Should Never Get Here  **** \nAssertion in file:%s at line %i in Method %@ with object:\n %@\n\n", __FILE__, __LINE__, NSStringFromSelector(_cmd), self)

// Blocks assertion, prevents NSAssert retain cycles in blocks
// http://getitdownonpaper.com/journal/2011/9/27/making-nsassert-play-nice-with-blocks.html
#if !defined(NS_BLOCK_ASSERTIONS)

#define BlockAssert(condition, desc, ...) \
do {\
if (!(condition)) { \
[[NSAssertionHandler currentHandler] handleFailureInFunction:NSStringFromSelector(_cmd) \
file:[NSString stringWithUTF8String:__FILE__] \
lineNumber:__LINE__ \
description:(desc), ##__VA_ARGS__]; \
}\
} while(0);

#else // NS_BLOCK_ASSERTIONS defined

#define BlockAssert(condition, desc, ...)

#endif

#pragma mark -
#pragma mark ** Utilities **

// Unabashedly cribbed from Wil Shipley (of Delicious Monster fame)
// http://www.wilshipley.com/blog/2005/10/pimp-my-code-interlude-free-code.html
static inline BOOL isEmpty(id thing)
{
    return thing == nil
            || ([thing respondsToSelector:@selector(length)] && [(NSData *)thing length] == 0)
            || ([thing respondsToSelector:@selector(count)] && [(NSArray *)thing count] == 0);
}

// UUIDs are uuuseful.
static inline CFStringRef createUniqueString(void)
{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    return uuidStringRef;
}

#define WeakObject(o) __typeof__(o) __weak
#define WeakAssign(o) __typeof__(o) __weak weak_##o = o;
#define WeakSelf WeakObject(self)
#define Weaks WeakSelf Wself = self;
#define Strongs __typeof__(Wself) __strong Sself = Wself;
#define StrongsAssign(o) __typeof__(o) __strong strong_##o = o;
#define BlockOnce(block) static dispatch_once_t onceToken; dispatch_once(&onceToken, block);
#define STSpinLock static OSSpinLock lock = OS_SPINLOCK_INIT; bool locked = OSSpinLockTry(&lock);
#define STSpinUnLock !locked?:OSSpinLockUnlock(&lock);

#define CGPointHalf CGPointMake(.5,.5)
#define CHK_BIT(p1, p2) (!!(p1 & p2))
#define TIMEINTERVAL_LAZY .5

CG_INLINE CGFloat
TwiceMaxScreenScale()
{
    CGFloat scale = [[UIScreen mainScreen] scale];
    scale < 3 ?: (scale=2);
    return scale;
}

CG_INLINE CGFloat
TwiceMaxScreenScaleRatioByCurrentScale()
{
    CGFloat scale = [[UIScreen mainScreen] scale];
    return TwiceMaxScreenScale()/scale;
}

CG_INLINE CGSize
CGSizeMakeValue(CGFloat scalarSize)
{
    CGSize size;
    size.width = scalarSize;
    size.height = scalarSize;
    return size;
}

CG_INLINE CGSize
CGSizeMakeFromImageToView(CGSize imageSize)
{
    CGSize size;
    CGFloat scale = [UIScreen mainScreen].scale;
    size.width = imageSize.width*(1/scale);
    size.height = imageSize.height*(1/scale);
    return size;
}

CG_INLINE CGRect
CGRectMakeValue(CGFloat scalarSize)
{
    CGRect rect;
    rect.origin = CGPointZero;
    rect.size = CGSizeMakeValue(scalarSize);
    return rect;
}

CG_INLINE CGRect
CGRectResolveOrientation(CGRect rect, UIInterfaceOrientation orientation, CGFloat containerPortraitWidth, CGFloat containersPortraitHeight) {
    switch(orientation)
    {
        case UIInterfaceOrientationLandscapeLeft:
            return CGRectMake(rect.origin.y, containerPortraitWidth -rect.origin.x-rect.size.width, rect.size.height, rect.size.width);
        case UIInterfaceOrientationLandscapeRight:
            return CGRectMake(containersPortraitHeight -rect.origin.y-rect.size.height, rect.origin.x, rect.size.height, rect.size.width);
        case UIInterfaceOrientationPortraitUpsideDown:
            return CGRectMake(containerPortraitWidth -rect.origin.x-rect.size.width, containersPortraitHeight - (rect.size.height + rect.origin.y), rect.size.width, rect.size.height);
        default:
            return rect;
    }
}

CG_INLINE CGFloat
RadianFromOrientation(UIInterfaceOrientation orientation) {
    switch(orientation)
    {
        case UIInterfaceOrientationLandscapeLeft:
            return (CGFloat) M_PI_2;
        case UIInterfaceOrientationLandscapeRight:
            return (CGFloat) (M_PI + M_PI_2);
        case UIInterfaceOrientationPortraitUpsideDown:
            return (CGFloat) M_PI;
        default:
            return 0;
    }
}

CG_INLINE CGFloat
CGSizeMaxSide(CGSize size)
{
    return MAX(size.width, size.height);
}

CG_INLINE CGFloat
CGSizeMinSide(CGSize size)
{
    return MIN(size.width, size.height);
}

CG_INLINE CGSize
CGSizeByScale(CGSize size, CGFloat scale)
{
    return CGSizeMake(size.width*scale, size.height*scale);
}

CG_INLINE CGSize
CGSizeMakeByScale(CGFloat width, CGFloat height, CGFloat scale)
{
    return CGSizeByScale(CGSizeMake(width,height), scale);
}

#define CLAMP(x, low, high) ({\
  __typeof__(x) __x = (x); \
  __typeof__(low) __low = (low);\
  __typeof__(high) __high = (high);\
  __x > __high ? __high : (__x < __low ? __low : __x);\
  })

#define NORMALIZE(x, min, max) ((x-min)/(max-min))

CG_INLINE CGFloat
MAXRadiusInBoundsFromPoint(CGPoint point, CGRect bounds)
{
    AGKQuad q = AGKQuadMakeWithCGRect(bounds);
    CGFloat mr = CGPointLengthBetween_AGK(point, q.bl);
    mr = MAX(mr, CGPointLengthBetween_AGK(point, q.br));
    mr = MAX(mr, CGPointLengthBetween_AGK(point, q.tl));
    return MAX(mr, CGPointLengthBetween_AGK(point, q.tr));
}

CG_INLINE CGFloat
MAXDiameterInBoundsFromPoint(CGPoint point, CGRect bounds)
{
    return MAXRadiusInBoundsFromPoint(point, bounds)*2.f;
}

CG_INLINE CGFloat
CGPointLengthBetween(CGPoint p1, CGPoint p2)
{
    CGPoint p = CGPointMake(p2.x - p1.x, p2.y - p1.y);
    return sqrtf(powf(p.x, 2.0f) + powf(p.y, 2.0f));
}

CG_INLINE CGSize
CGSizeMakeToFitScreenAsRaster(CGFloat imagePixelWidth, CGFloat imagePixelHeight, CGFloat minScale, CGFloat maxScale, BOOL useMinScaleIfNeeded){
    CGFloat photoSizeRatio = imagePixelWidth/imagePixelHeight;
    CGSize photosPixelSize = CGSizeMake(imagePixelWidth, imagePixelHeight);
    CGFloat photosPixelSizeMaxSide = CGSizeMaxSide(photosPixelSize);
    CGSize screensPixelSize = CGSizeMake(
            [UIScreen mainScreen].bounds.size.width,
            [UIScreen mainScreen].bounds.size.width * (photoSizeRatio>1? photoSizeRatio : 1/photoSizeRatio)
    );
    CGFloat screenPixelSizeMaxSide = CGSizeMaxSide(screensPixelSize);
    CGFloat scale = photosPixelSizeMaxSide > screenPixelSizeMaxSide && useMinScaleIfNeeded ? minScale : maxScale;
    return CGSizeByScale(CGSizeByScale(photosPixelSize, scale), screenPixelSizeMaxSide / photosPixelSizeMaxSide);
}

CG_INLINE CGSize
CGSizeMakeToFitScreenAsRasterByMinScale(CGFloat imagePixelWidth, CGFloat imagePixelHeight, CGFloat minScale, BOOL useMinScaleIfNeeded){
    return CGSizeMakeToFitScreenAsRaster(imagePixelWidth,imagePixelHeight,minScale, [UIScreen mainScreen].scale, useMinScaleIfNeeded);
}

#pragma mark CGPoint
CG_INLINE CGFloat
CGFloatNearestMax2DecimalPosition(CGFloat value){
    return floorf(value * 100 + 0.5) / 100;
}

CG_INLINE CGPoint
CGPointNearestMax2DecimalPosition(CGPoint point)
{
    return CGPointMake(CGFloatNearestMax2DecimalPosition(point.x), CGFloatNearestMax2DecimalPosition(point.y));
}

CG_INLINE BOOL
CGPointEqualToPointByNearest2Decimal(CGPoint p1, CGPoint p2)
{
    return CGFloatNearestMax2DecimalPosition(p1.x) == CGFloatNearestMax2DecimalPosition(p2.x)
            && CGFloatNearestMax2DecimalPosition(p1.y) == CGFloatNearestMax2DecimalPosition(p2.y);
}

#define BEGIN_DEALLOC_CATEGORY + (void)load {\
        SEL originalSelector = NSSelectorFromString(@"dealloc");\
        SEL overrideSelector = @selector(__dealloc__);\
        Method originalMethod = class_getInstanceMethod(self, originalSelector);\
        Method overrideMethod = class_getInstanceMethod(self, overrideSelector);\
        if (class_addMethod(self, originalSelector, method_getImplementation(overrideMethod), method_getTypeEncoding(overrideMethod))) {\
            class_replaceMethod(self, overrideSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));\
        } else {\
            method_exchangeImplementations(originalMethod, overrideMethod);\
        }\
    }\
\
- (void)__dealloc__{\

#define END_DEALLOC_CATEGORY }

#define DEFINE_ASSOCIATOIN_KEY(kKeyName) static const void *kKeyName = &kKeyName;

#define DEFINE_ASSOCIATOIN_PROPERTY(T,propertyName,setterMethod,castingMethod)  @dynamic propertyName ; \
static const void *k##propertyName = &k##propertyName ; \
- ( T ) propertyName {\
    return ( T )[[self bk_associatedValueForKey: k##propertyName ] castingMethod ];\
}\
- (void) setterMethod :( T ) propertyName {\
    [self bk_associateValue:@( propertyName ) withKey:k##propertyName ];\
}\

// Example: 1   UIKit                               0x00540c89 -[UIApplication _callInitializationDelegatesForURL:payload:suspended:] + 1163
#define CALLER_INFO NSMutableArray *__caller_info__ = [NSMutableArray arrayWithArray:[[NSThread callStackSymbols][1] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"]]];\
[__caller_info__ removeObject:@""];\

#define CALLER_INFO_INDEX_STACK 0
#define CALLER_INFO_INDEX_FRAMEWORK 1
#define CALLER_INFO_INDEX_MEMADDR 2
#define CALLER_INFO_INDEX_CLASS 3
#define CALLER_INFO_INDEX_FUNCTION 4
#define CALLER_INFO_INDEX_LINE 5

#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
#define __typed_collection(iterablesCls, elementsType) iterablesCls<elementsType> *
#define __typed_collection_knd(iterablesCls, elementsType) iterablesCls<__kindof elementsType> *
#else
#define __typed_collection(iterablesCls, elementsType) iterablesCls *
#define __typed_collection_knd(iterablesCls, elementsType) iterablesCls *
#endif

#define UIViewParentController(__view) ({ \
    UIResponder *__responder = __view; \
    while ([__responder isKindOfClass:[UIView class]]) \
        __responder = [__responder nextResponder]; \
    (UIViewController *)__responder; \
})

NS_INLINE BOOL
isInstanceMethodOverridden(Class cls, SEL selector)
{
    IMP selfImplementation = class_getMethodImplementation(cls, selector);
    BOOL overridden = NO;
    Class superclass = cls;
    while ((superclass = [superclass superclass])){
        Method superMethod = class_getInstanceMethod(superclass, selector);
        if (superMethod && method_getImplementation(superMethod) != selfImplementation){
            overridden = YES;
            break;
        }
    }
    return overridden;
}