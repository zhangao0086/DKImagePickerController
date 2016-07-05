//
// Created by BLACKGENE on 2016. 3. 13..
// Copyright (c) 2016 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STExportContentView.h"


@interface STExportLoginContentView : STExportContentView <UITextFieldDelegate>
@property (copy) void(^didReturnInputBlock)(NSString *id, NSString * password);

- (void)returnInputResults;
@end