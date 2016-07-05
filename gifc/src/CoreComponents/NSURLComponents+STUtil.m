//
// Created by BLACKGENE on 15. 9. 2..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <BlocksKit/NSArray+BlocksKit.h>
#import "NSURLComponents+STUtil.h"

@implementation NSURLComponents (STUtil)

- (NSURLComponents *)st_query:(NSDictionary *)dict{
    NSArray * addingQueries = [[dict allKeys] bk_map:^id(id key) {
        return [NSURLQueryItem queryItemWithName:key value:dict[key]];
    }];
    self.queryItems = self.queryItems ? [self.queryItems arrayByAddingObjectsFromArray:addingQueries] : addingQueries;
    return self;
}

- (NSURLComponents *)st_host:(NSString *)host{
    self.host = host;
    return self;
}

- (NSURLComponents *)st_scheme:(NSString *)scheme{
    self.scheme = scheme;
    return self;
}

- (NSURLComponents *)st_path:(NSString *)path{
    self.path = path;
    return self;
}
@end