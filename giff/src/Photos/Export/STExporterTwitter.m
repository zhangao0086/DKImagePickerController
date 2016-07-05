//
// Created by BLACKGENE on 2015. 2. 16..
// Copyright (c) 2015 stells. All rights reserved.
//

#import "STExporterTwitter.h"
#import "NSURL+STUtil.h"
#import "NSURLComponents+STUtil.h"
#import "NSString+STUtil.h"

@implementation STExporterTwitter {

}

/*
twitter://user?screen_name=lorenb
twitter://user?id=12345
twitter://status?id=12345
twitter://timeline
twitter://mentions
twitter://messages
twitter://list?screen_name=lorenb&slug=abcd
twitter://post?message=hello%20world
twitter://post?message=hello%20world&in_reply_to_status_id=12345
twitter://search?query=%23hashtag
 */

+ (NSString *)scheme {
    return @"twitter";
}

+ (NSString *)appURLStringWithHashtagName:(NSString *)hashtag {
    return [[[[self scheme] URLSchemeComponent] st_host:@"search"] st_query:@{@"query":[@"#" st_add:hashtag]}].string;
}

+ (NSString *)appURLStringWithUserName:(NSString *)userName {
    return [[[self appURL].URLComponent st_host:@"user"] st_query:@{@"screen_name" : userName}].string;
}

+ (NSString *)webURLStringWithUserName:(NSString *)userName {
    return [[self webURL] URLByAppendingPathComponent:userName].absoluteString;
}

+ (NSString *)webURLStringWithHashtagName:(NSString *)hashtag {
    return [NSString stringWithFormat:@"http://twitter.com/hashtag/%@?src=hash",hashtag];
}

+ (NSString *)webURLString {
    return @"http://twitter.com";
}

- (NSString *)SLServiceType; {
    return SLServiceTypeTwitter;
}

@end