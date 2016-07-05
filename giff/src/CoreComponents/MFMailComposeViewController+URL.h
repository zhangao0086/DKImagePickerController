#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@interface MFMailComposeViewController (URL)

- (BOOL)setFromUrl:(NSURL *)url;
@end
