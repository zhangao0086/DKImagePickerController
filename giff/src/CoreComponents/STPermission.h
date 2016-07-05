#import <Foundation/Foundation.h>

typedef enum {
    STPermissionStatusUninitialized = 0,
    STPermissionStatusNotDetermined,
    STPermissionStatusAuthorized,
    STPermissionStatusDenied,
    STPermissionStatusRestricted,
    STPermissionStatusServiceNotAvailable = 0xFF
} STPermissionStatus;

typedef void (^STPermissionEmptyBlock)();

@protocol STPermissionProtocol <NSObject>
@required
+(instancetype)permissionWithLabelText:(NSString*)labelText;
-(void)updatePermissionStatus;
-(void)presentSystemPromtWithCompletionBlock:(STPermissionEmptyBlock)completionBlock;
@end



@interface STPermission : NSObject  <STPermissionProtocol>
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *labelText;
@property (nonatomic) STPermissionStatus status;
@property (nonatomic) BOOL required;
-(instancetype)initWithType:(NSString*)type labelText:(NSString*)labelText;
-(NSString*)stringForStatus;
@end


