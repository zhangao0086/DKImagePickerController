//
// Created by BLACKGENE on 2015. 2. 9..
// Copyright (c) 2015 stells. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STExporter.h"

@class STPhotoItem;
@class STExporter;


@interface STExportManager : NSObject <UINavigationControllerDelegate, UIDocumentInteractionControllerDelegate>
@property (readonly) STExporter * currentExporter;
@property (readonly) NSArray *acquiredTypes;

+ (STExportManager *)sharedManager;

- (void)setup;

- (NSArray *)acquire:(NSArray *)photoItems;

- (void)finish;

- (BOOL)ready:(STExportType)type;

- (BOOL)export:(STExportType)type;

- (BOOL)export:(STExportType)type finished:(void (^)(STExportResult))block;

- (BOOL)export:(STExportType)type processing:(void (^)(BOOL processing))processingBlock finished:(void (^)(STExportResult))block;

- (BOOL)export:(STExportType)type will:(void (^)(STExporter *exporter))willBlock processing:(void (^)(BOOL processing))processingBlock finished:(void (^)(STExportResult))block;

- (BOOL)handle:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

@end