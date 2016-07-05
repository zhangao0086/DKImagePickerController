//
//  LEColorPicker.h
//  LEColorPicker
//
//  Created by Luis Enrique Espinoza Severino on 10-12-12.
//  Copyright (c) 2012 Luis Espinoza. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import <QuartzCore/QuartzCore.h>

#ifndef LECOLORPICKER
#define LECOLORPICKER

#ifdef LE_DEBUG
#	 define LELog(s,...) NSLog((@"[%s] " s),__func__,## __VA_ARGS__);
#else
#	 define LELog(...) /* */
#endif

@interface LEColorScheme : NSObject
@property(nonatomic,strong)UIColor *backgroundColor;
@property(nonatomic,strong)UIColor *primaryTextColor;
@property(nonatomic,strong)UIColor *secondaryTextColor;
@end

@interface LEColorPicker : NSObject
{
    //GLuint _vertexArray;
    GLuint _vertexBuffer;
    GLuint _indexBuffer;
    GLuint _colorRenderBuffer;
    GLuint _depthRenderBuffer;
    GLuint _program;
    GLuint _proccesedWidthSlot;
    GLuint _totalWidthSlot;
    GLuint _positionSlot;
    GLuint _colorSlot;
    GLuint _texCoordSlot;
    GLuint _textureUniform;
    GLuint _aTexture;
    GLuint _tolerance;
    GLuint _colorToFilter;
    UIImage *_currentImage;
    CAEAGLLayer* _eaglLayer;
    EAGLContext *_context;
    dispatch_queue_t taskQueue;
}
/**
 This instance method allows the client object to generate three colors from a specific UIImage. This method generate synchronously colors for background, primary and secondary colors, encapsulated in a LEColorScheme object.
 
 @param image Input image, wich will be used to generate the three colors.
 @returns LEColorScheme with three output colors.
 */
- (LEColorScheme*)colorSchemeFromImage:(UIImage*)image;

/**
 This instance method allows the client object to generate three colors from a specific UIImage. The complete
 block recieves as parameter a LEColorScheme wich is the object that encapsulates the output colors.
 
 @param image Input image, wich will be used to generate the three colors.
 @param completeBlock Execution block for when the task is complete.
 */
- (void)pickColorsFromImage:(UIImage*)image onComplete:(void (^)(LEColorScheme *colorScheme))completeBlock;

/**
 This class methods allows the client to generate three colors from a specific UIImage. The "complete"
 block recieves as parameter colorsDictionary, wich is the dictionary with the resultant colors.
 
 BackgroundColor : is the key for the background color.
 PrimaryTextColor : is the key for the primary text color.
 SecondaryTextColor : is the key for the secondary text color.
 
 @param image Input image, wich will be used to generate the three colors.
 @param completeBlock Execution block for when the task is complete.
 */
+ (void)pickColorFromImage:(UIImage*)image
                onComplete:(void (^)(NSDictionary *colorsPickedDictionary))completeBlock;

@end

#endif  /* LECOLORPICKER */

