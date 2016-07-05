//
// Created by BLACKGENE on 2015. 2. 12..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STExporter.h"
#import "STExporterAsyncPreparing.h"
#import "STExporter+URL.h"

@interface STExporterInstagram : STExporterAsyncPreparing <STExporterSocialURLProtocol, UIDocumentInteractionControllerDelegate>
@end