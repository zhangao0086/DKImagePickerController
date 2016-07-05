#import "STPermission.h"

@interface STPermission ()

@end

@implementation STPermission


- (instancetype)initWithType:(NSString*)type labelText:(NSString*)labelText{
    self = [super init];
    if (self) {
        _type = type;
        _labelText = labelText;
        _status = STPermissionStatusUninitialized;
    }
    return self;
}

+(instancetype)permissionWithLabelText:(NSString*)labelText{
    NSAssert(NO, @"Child class must impelment");
    return nil;    
}

-(instancetype)initWithLabelText:(NSString*)labelText{
    NSAssert(NO, @"Child class must impelment");
    return nil;
}

-(void)updatePermissionStatus{
    NSAssert(NO, @"Child class must impelment");
}

-(void)presentSystemPromtWithCompletionBlock:(STPermissionEmptyBlock)completionBlock{
    NSAssert(NO, @"Child class must impelment");
}

-(NSString*)description{
    return [NSString stringWithFormat:@"%@ - %@", NSStringFromClass([self class]), [self stringForStatus]];
}

-(NSString*)stringForStatus{
    switch (self.status) {
        case STPermissionStatusAuthorized:
            return @"Authorized";
            break;
        case STPermissionStatusNotDetermined:
            return @"Not determined";
            break;
        case STPermissionStatusDenied:
            return @"Denied";
            break;
        case STPermissionStatusRestricted:
            return @"Restricted";
            break;
        case STPermissionStatusUninitialized:
        default:
            return @"Not initialized";
            break;
    }
}

@end
