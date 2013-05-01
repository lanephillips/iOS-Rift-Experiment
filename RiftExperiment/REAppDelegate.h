//
//  REAppDelegate.h
//  RiftExperiment
//
//  Created by Lane Phillips on 5/1/13.
//  Copyright (c) 2013 Milk LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RERiftDisplay.h"

@interface REAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, readonly) RERiftDisplay* rift;

@end

#define APP ((REAppDelegate*)[UIApplication sharedApplication].delegate)
