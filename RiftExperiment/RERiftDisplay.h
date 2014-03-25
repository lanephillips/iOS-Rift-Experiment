//
//  RERiftDisplay.h
//  RiftExperiment
//
//  Created by Lane Phillips (@bugloaf) on 5/1/13.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2013-2014 Milk LLC (@Milk_LLC).
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@class RERiftDisplay;

@protocol RERiftDisplayDelegate <NSObject>

@optional
-(void)riftWillAppear:(RERiftDisplay*)rift;
-(void)riftWillDisappear:(RERiftDisplay*)rift;

@end

extern NSString* const RERiftWillAppearNotification;
extern NSString* const RERiftWillDisappearNotification;

typedef enum {
    RELeftEye = 0,
    RERightEye = 1
} REEye;

@interface RERiftDisplay : NSObject

// the screen and window for the connected device, or nil if not connected
@property (readonly,nonatomic) UIScreen* screen;
@property (readonly,nonatomic) UIWindow* window;

// these properties come from the Rift docs
@property (readonly,nonatomic) CGFloat hScreenSize;
@property (readonly,nonatomic) CGFloat vScreenSize;
@property (readonly,nonatomic) CGFloat vScreenCenter;
@property (readonly,nonatomic) CGFloat eyeToScreenDistance;
@property (readonly,nonatomic) CGFloat lensSeparationDistance;
@property (readonly,nonatomic) const CGFloat* distortionK;
// user configurable, defaults to 64mm
@property (nonatomic) CGFloat interpupillaryDistance;
// set to the logical UI resolution, since it may not match the physical screen
@property (nonatomic) CGSize resolution;

// these are updated if any of the above change
@property (readonly,nonatomic) CGFloat aspect;
@property (readonly,nonatomic) CGFloat yFOV;
@property (readonly,nonatomic) const GLKMatrix4* projectionMatrices;
// multiply on the left of the view center to get the viewing matrix for this eye
@property (readonly,nonatomic) const GLKMatrix4* viewMatrices;

@property (nonatomic) NSObject<RERiftDisplayDelegate>* delegate;

-(id)initWithDelegate:(NSObject<RERiftDisplayDelegate>*)delegate;

@end
