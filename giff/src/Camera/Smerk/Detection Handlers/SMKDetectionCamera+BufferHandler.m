//
//  SMKDetectorView+BufferHandler.m
//  Smerk
//
//  Created by teejay on 1/22/14.
//  Copyright (c) 2014 Smerk. All rights reserved.
//

#import "SMKDetectionCamera_private.h"
#import "SMKDetectionCamera+BufferHandler.h"

@implementation SMKDetectionCamera (BufferHandler)

#pragma mark - Face Detection Delegate Callback
- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    //CIFaceDetector is slow, so in order to keep things in line, we allow frames to drop.
	if ( !self.processingInProgress ) {
		CFAllocatorRef allocator = CFAllocatorGetDefault();
		CMSampleBufferRef sbufCopyOut;
		CMSampleBufferCreateCopy(allocator, sampleBuffer, &sbufCopyOut);
		[self performSelectorInBackground:@selector(grepFacesForSampleBuffer:) withObject:CFBridgingRelease(sbufCopyOut)];
	}
}

- (void)grepFacesForSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
	self.processingInProgress = TRUE;
    
	CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
	CIImage *convertedImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(__bridge NSDictionary *)attachments];
    
	if (attachments) {
		CFRelease(attachments);
    }
    
    
	NSInteger exifOrientation = [self getExifOrientationValue];
    
    NSDictionary *imageOptions = @{CIDetectorImageOrientation : @(exifOrientation),
                                   CIDetectorSmile : @(YES)};
    
	self.coreImageFaceFeatures = [self.faceDetector featuresInImage:convertedImage options:imageOptions];
    
	CMFormatDescriptionRef fdesc = CMSampleBufferGetFormatDescription(sampleBuffer);
    self.clap = CMVideoFormatDescriptionGetCleanAperture(fdesc, false);
    
	[self.detectionDelegate detectorWillOuputFaceFeatures:self.coreImageFaceFeatures inClap:self.clap];
    
    if (self.coreImageFaceFeatures.count == 0) {
		self.idleCount++;
	} else {
		self.idleCount = 0;
	}
    
	self.processingInProgress = FALSE;
}

- (NSInteger)getExifOrientationValue
{
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    
    NSInteger exifOrientation;
    
    enum {
		PHOTOS_EXIF_0ROW_TOP_0COL_LEFT          = 1, //   1  =  0th row is at the top, and 0th column is on the left (THE DEFAULT).
		PHOTOS_EXIF_0ROW_TOP_0COL_RIGHT         = 2, //   2  =  0th row is at the top, and 0th column is on the right.
		PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT      = 3, //   3  =  0th row is at the bottom, and 0th column is on the right.
		PHOTOS_EXIF_0ROW_BOTTOM_0COL_LEFT       = 4, //   4  =  0th row is at the bottom, and 0th column is on the left.
		PHOTOS_EXIF_0ROW_LEFT_0COL_TOP          = 5, //   5  =  0th row is on the left, and 0th column is the top.
		PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP         = 6, //   6  =  0th row is on the right, and 0th column is the top.
		PHOTOS_EXIF_0ROW_RIGHT_0COL_BOTTOM      = 7, //   7  =  0th row is on the right, and 0th column is the bottom.
		PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM       = 8  //   8  =  0th row is on the left, and 0th column is the bottom.
	};
    
	BOOL isUsingFrontFacingCamera = FALSE;
	AVCaptureDevicePosition currentCameraPosition = [self cameraPosition];
    
	if (currentCameraPosition != AVCaptureDevicePositionBack) {
		isUsingFrontFacingCamera = TRUE;
	}
    
	switch (deviceOrientation) {
		case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
			exifOrientation = PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM;
			break;
            
		case UIDeviceOrientationLandscapeLeft:       // Device oriented horizontally, home button on the right
			if (isUsingFrontFacingCamera) {
				exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
            } else {
				exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
            }
			break;
            
		case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
			if (isUsingFrontFacingCamera) {
				exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
			} else {
				exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
            }
			break;
            
		case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
		default:
			exifOrientation = PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP;
			break;
	}
    
    return exifOrientation;
}

@end
