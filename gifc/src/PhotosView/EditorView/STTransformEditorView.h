//
//  FXPhotoEditView.h
//
//  Version 1.0 beta
//
//  Created by Nick Lockwood on 09/11/2011.
//  Copyright 2011 Charcoal Design
//
//  Distributed under the permissive zlib license
//  Get the latest version from here:
//
//  https://github.com/nicklockwood/FXPhotoEditView
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

@class STTransformEditorResult;

@interface STTransformEditorView : UIView

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, assign) CGSize zoomInset;
@property (nonatomic, assign, getter = isEditing) BOOL editing;
@property (nonatomic, readonly) BOOL modified;

- (void)setEditing:(BOOL)editing animated:(BOOL)animated;
- (void)reset:(BOOL)animated;
- (void)constrain:(CGFloat)aspectRatio animated:(BOOL)animated;
- (void)rotateLeft:(BOOL)animated;
- (void)crop;
- (STTransformEditorResult *)cropResult;

@end
