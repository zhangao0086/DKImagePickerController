//
// Created by BLACKGENE on 15. 9. 2..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLComponents (STUtil)

//result: if NSURLComponents initialized with 'string:' -> 'string://host'
- (NSURLComponents *)st_host:(NSString *)host;

- (NSURLComponents *)st_scheme:(NSString *)scheme;

- (NSURLComponents *)st_path:(NSString *)path;

- (NSURLComponents *)st_query:(NSDictionary *)dictionary;
@end