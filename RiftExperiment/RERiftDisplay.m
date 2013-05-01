//
//  RERiftDisplay.m
//  RiftExperiment
//
//  Created by Lane Phillips on 5/1/13.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2013 Milk LLC.
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

@interface RERiftDisplay ()
{
}

@end

@implementation RERiftDisplay

-(id)initWithDelegate:(NSObject<RERiftDisplayDelegate> *)delegate
{
    self = [super init];
    if (self) {
        _delegate = delegate;
        
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
        for (UIScreenMode* mode in _screen.availableModes) {
            NSLog(@"\t%@ %f", NSStringFromCGSize(mode.size), mode.pixelAspectRatio);
            if (mode.size.width == 1280 &&
                // right now it's giving me 1280 x 720 as the only 1280-wide option
                (!match || (mode.size.height > match.size.height && mode.size.height <= 800)))
                match = mode;
        }
        if (match) {
            NSLog(@"changing mode");
            _screen.currentMode = match;
        }
        NSLog(@"current mode: %@ %f", NSStringFromCGSize(_screen.currentMode.size), _screen.currentMode.pixelAspectRatio);
        
        // Get the screen's bounds so that you can create a window of the correct size.
        CGRect screenBounds = _screen.bounds;
        NSLog(@"current bounds: %@", NSStringFromCGRect(screenBounds));
        
        _window = [[UIWindow alloc] initWithFrame:screenBounds];
        _window.screen = _screen;
        
        // Set up initial content to display...
        [self postConnectNotification];
        
        // Show the window.
        _window.hidden = NO;
    } else {
        NSLog(@"external screen not found");
        _screen = nil;
        _window.hidden = YES;
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
    NSLog(@"delegate: %@", _delegate);
    if ([_delegate respondsToSelector:@selector(riftWillAppear:)])
        [_delegate riftWillAppear:self];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRERiftWillAppearNotification object:self];
}

-(void)postDisonnectNotification
{
    NSLog(@"delegate: %@", _delegate);
    if ([_delegate respondsToSelector:@selector(riftWillDisappear:)])
        [_delegate riftWillDisappear:self];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRERiftWillDisappearNotification object:self];
}

@end
