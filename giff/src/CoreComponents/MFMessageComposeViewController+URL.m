//
// Created by BLACKGENE on 2015. 12. 1..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "MFMessageComposeViewController+URL.h"
#import "NSURL+STUtil.h"
#import "NSString+STUtil.h"

@implementation MFMessageComposeViewController (URL)

// e.g : sms:{phonenumber1},{phonenumber1},{phonenumber1}?body={message}&attachments={url0},{url1},{url2}

- (BOOL)setFromUrl:(NSURL *)aUrl {
    if ([MFMessageComposeViewController canSendText]) {

        self.recipients = [[aUrl URLComponent].path split:@","];

        for(NSURLQueryItem * q in [aUrl URLComponent].queryItems){
            NSString * key = q.name;
            NSString * value = q.value;

            if ([@"subject" isEqualToString:key] && [MFMessageComposeViewController canSendSubject]) {
                [self setSubject:value];
            }

            if ([@"body" isEqualToString:key]) {
                [self setBody:value];
            }

            if ([@"attachments" isEqualToString:key] && [MFMessageComposeViewController canSendAttachments]) {
                [[value split:@","] eachWithIndex:^(NSString * path, NSUInteger index) {
                    if([[NSFileManager defaultManager] fileExistsAtPath:path]){
                        [self addAttachmentURL:[NSURL fileURLWithPath:path] withAlternateFilename:[NSString stringWithFormat:@"image%d.png",index]];
                    }
                }];
            }
        }

        return YES;
    }
    else {
        return NO;
    }
}

@end