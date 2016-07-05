#import <BlocksKit/NSArray+BlocksKit.h>
#import "MFMailComposeViewController+URL.h"
#import "NSURL+STUtil.h"
#import "NSString+STUtil.h"


@implementation MFMailComposeViewController (URL)

- (BOOL)setFromUrl:(NSURL *)aUrl {
	if ([MFMailComposeViewController canSendMail]) {

		NSMutableArray *toRecipients = [NSMutableArray array];

		[toRecipients addObject:[aUrl URLComponent].path];

		for(NSURLQueryItem * q in [aUrl URLComponent].queryItems){
			NSString * key = q.name;
			NSString * value = q.value;

			if ([key isEqualToString:@"subject"]) {
				[self setSubject:value];
			}

			if ([key isEqualToString:@"body"]) {
				[self setMessageBody:value isHTML:NO];
			}

			if ([key isEqualToString:@"to"]) {
				[toRecipients addObjectsFromArray:[value componentsSeparatedByString:@","]];
			}

			if ([key isEqualToString:@"cc"]) {
				NSArray *recipients = [value componentsSeparatedByString:@","];
				[self setCcRecipients:recipients];
			}

			if ([key isEqualToString:@"bcc"]) {
				NSArray *recipients = [value componentsSeparatedByString:@","];
				[self setBccRecipients:recipients];
			}
		}

		[self setToRecipients:toRecipients];

		return YES;
	}
	else {
		return NO;
	}
}
@end
