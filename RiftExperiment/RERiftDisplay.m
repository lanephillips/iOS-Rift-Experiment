//
//  RERiftDisplay.m
//  RiftExperiment
//
//  Created by Lane Phillips on 5/1/13.
//  Copyright (c) 2013 Milk LLC. All rights reserved.
//

#import "RERiftDisplay.h"
#import "REViewController.h"
#import "REAppDelegate.h"

@interface RERiftDisplay ()
{
    // for debugging: cycle colors on connect/disconnect
    NSArray* _debugColors;
    int _connectCount;
}

@end

@implementation RERiftDisplay

+(RERiftDisplay *)rift
{
    static RERiftDisplay* _rift = nil;
    if (!_rift) {
        _rift = [[RERiftDisplay alloc] init];
    }
    return _rift;
}

-(id)init
{
    self = [super init];
    if (self) {
        _debugColors = @[[UIColor redColor], [UIColor greenColor], [UIColor blueColor], [UIColor magentaColor], [UIColor yellowColor], [UIColor cyanColor]];
        
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

-(void)checkForScreen
{
    if ([[UIScreen screens] count] > 1)
    {
        NSLog(@"found external screen");
        // Get the screen object that represents the external display.
        _screen = [[UIScreen screens] objectAtIndex:1];
        // Get the screen's bounds so that you can create a window of the correct size.
        CGRect screenBounds = _screen.bounds;
        
        _window = [[UIWindow alloc] initWithFrame:screenBounds];
        _window.screen = _screen;
        
        // TODO: Set up initial content to display...
        REViewController* vc = [APP.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"riftView"];
        _window.rootViewController = vc;
        [_window addSubview:vc.view];
        
        // Show the window.
        _window.hidden = NO;
    } else {
        NSLog(@"external screen not found");
        _screen = nil;
        _window.hidden = YES;
        _window = nil;
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
    if ([_delegate respondsToSelector:@selector(riftDidConnect:)])
        [_delegate riftDidConnect:self];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRERiftDidConnectNotification object:self];
}

-(void)postDisonnectNotification
{
    if ([_delegate respondsToSelector:@selector(riftDidDisconnect:)])
        [_delegate riftDidDisconnect:self];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRERiftDidDisconnectNotification object:self];
}

@end
