//
//  RERiftDisplay.m
//  RiftExperiment
//
//  Created by Lane Phillips (@bugloaf) on 5/1/13.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2013 Milk LLC (@Milk_LLC).
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

#import "RERiftDisplay.h"

NSString* const RERiftWillAppearNotification = @"RERiftWillAppearNotification";
NSString* const RERiftWillDisappearNotification = @"RERiftWillDisappearNotification";

@interface RERiftDisplay ()
{
    GLKMatrix4 _mutableProjectionMatrices[2];
    GLKMatrix4 _mutableViewMatrices[2];
}

@end

@implementation RERiftDisplay

-(id)initWithDelegate:(NSObject<RERiftDisplayDelegate> *)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
        
        [self setDefaultValues];
        [self checkForScreen];
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        
        [center addObserver:self selector:@selector(handleScreenDidConnectNotification:)
                       name:UIScreenDidConnectNotification object:nil];
        [center addObserver:self selector:@selector(handleScreenDidDisconnectNotification:)
                       name:UIScreenDidDisconnectNotification object:nil];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// TODO: avoid initializing multiple times, and sending duplicate notifications
-(void)checkForScreen
{
    if ([[UIScreen screens] count] > 1)
    {
        NSLog(@"found external screen");
        // Get the screen object that represents the external display.
        _screen = [[UIScreen screens] objectAtIndex:1];
        
        NSLog(@"display modes:");
        UIScreenMode* match = nil;
        for (UIScreenMode* mode in self.screen.availableModes) {
            NSLog(@"\t%@ %f", NSStringFromCGSize(mode.size), mode.pixelAspectRatio);
            if (mode.size.width == 1280 &&
                // right now it's giving me 1280 x 720 as the only 1280-wide option
                (!match || (mode.size.height > match.size.height && mode.size.height <= 800)))
                match = mode;
        }
        if (match) {
            NSLog(@"changing mode");
            self.screen.currentMode = match;
        }
        NSLog(@"current mode: %@ %f", NSStringFromCGSize(self.screen.currentMode.size), self.screen.currentMode.pixelAspectRatio);
        
        // Get the screen's bounds so that you can create a window of the correct size.
        CGRect screenBounds = self.screen.bounds;
        NSLog(@"current bounds: %@", NSStringFromCGRect(screenBounds));
        self.resolution = screenBounds.size;
        
        _window = [[UIWindow alloc] initWithFrame:screenBounds];
        self.window.screen = self.screen;
        
        // Set up initial content to display...
        [self postConnectNotification];
        
        // Show the window.
        self.window.hidden = NO;
    } else {
        NSLog(@"external screen not found");
        _screen = nil;
        self.window.hidden = YES;
        _window = nil;
        
        [self postDisonnectNotification];
    }
}

- (void)handleScreenDidConnectNotification:(NSNotification*)aNotification
{
    [self checkForScreen];
}

- (void)handleScreenDidDisconnectNotification:(NSNotification*)aNotification
{
    [self checkForScreen];
}

-(void)postConnectNotification
{
    NSLog(@"delegate: %@", self.delegate);
    if ([self.delegate respondsToSelector:@selector(riftWillAppear:)])
        [self.delegate riftWillAppear:self];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RERiftWillAppearNotification object:self];
}

-(void)postDisonnectNotification
{
    NSLog(@"delegate: %@", self.delegate);
    if ([self.delegate respondsToSelector:@selector(riftWillDisappear:)])
        [self.delegate riftWillDisappear:self];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RERiftWillDisappearNotification object:self];
}

-(void)setInterpupillaryDistance:(CGFloat)interpupillaryDistance
{
    if (_interpupillaryDistance != interpupillaryDistance) {
        _interpupillaryDistance = interpupillaryDistance;
        [self updateProperties];
    }
}

-(void)setResolution:(CGSize)resolution
{
    if (resolution.width != _resolution.width || resolution.height != _resolution.height) {
        _resolution = resolution;
        [self updateProperties];
    }
}

-(void)setDefaultValues
{
    // TODO: there will be other Rifts, can we detect them?
    _hScreenSize = 0.14976f;
    _vScreenSize = 0.0936f;
    _vScreenCenter = self.vScreenSize / 2;
    _eyeToScreenDistance = 0.041f;
    _lensSeparationDistance = 0.0635f;
    static const float k[] = { 1.0f, 0.22f, 0.24f };
    _distortionK = k;
    _interpupillaryDistance = 0.064f;
    _resolution = CGSizeMake(1280, 800);
    
    [self updateProperties];
}

-(void)updateProperties
{
    // code from rift docs
    
    // Compute Aspect Ratio. Stereo mode cuts width in half.
    _aspect = self.resolution.width * 0.5 / self.resolution.height;
    
    // Compute Vertical FOV based on distance.
    _yFOV = 2 * atanf(self.vScreenCenter / self.eyeToScreenDistance);
    
    // Post-projection viewport coordinates range from (-1.0, 1.0), with the
    // center of the left viewport falling at (1/4) of horizontal screen size.
    // We need to shift this projection center to match with the lens center.
    // We compute this shift in physical units (meters) to correct
    // for different screen sizes and then rescale to viewport coordinates.
    float viewCenter = self.hScreenSize * 0.25f;
    float eyeProjectionShift = viewCenter - self.lensSeparationDistance*0.5f;
    float projectionCenterOffset = 4.0f * eyeProjectionShift / self.hScreenSize;
    
    // Projection matrix for the "center eye", which the left/right matrices are based on.
    GLKMatrix4 projCenter = GLKMatrix4MakePerspective(self.yFOV, self.aspect, 0.3f, 1000.0f);
    _mutableProjectionMatrices[0] = GLKMatrix4Multiply(GLKMatrix4MakeTranslation( projectionCenterOffset, 0, 0), projCenter);
    _mutableProjectionMatrices[1] = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(-projectionCenterOffset, 0, 0), projCenter);
    _projectionMatrices = _mutableProjectionMatrices;
    
    // View transformation translation in world units.
    float halfIPD = self.interpupillaryDistance * 0.5f;
    _mutableViewMatrices[0] = GLKMatrix4MakeTranslation( halfIPD, 0, 0);
    _mutableViewMatrices[1] = GLKMatrix4MakeTranslation(-halfIPD, 0, 0);
    _viewMatrices = _mutableViewMatrices;
}

@end
