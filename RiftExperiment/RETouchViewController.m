//
//  RETouchViewController.m
//  RiftExperiment
//
//  Created by Lane Phillips on 5/1/13.
//  Copyright (c) 2013 Milk LLC. All rights reserved.
//

#import "RETouchViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <asl.h>

@interface RETouchViewController ()
{
    // TODO: hacky, query log periodically, does ASL provide some sort of callback?
    NSTimer* _logTimer;
}
@end

@implementation RETouchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _logView.text = @"";

    _shadowView.frame = _logView.frame;
    _shadowView.clipsToBounds = NO;
    _shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    _shadowView.layer.shadowOpacity = 0.6f;
    _shadowView.layer.shadowRadius = 5.0f;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _logTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerFire:) userInfo:nil repeats:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_logTimer invalidate];
    _logTimer = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)refreshLog
{
    NSMutableString* s = [NSMutableString string];
    
    // this code from here: http://www.cocoanetics.com/2011/03/accessing-the-ios-system-log/
    // and here: http://stackoverflow.com/a/7151773/214070
    aslmsg q, m;
    const char *val;
    
    q = asl_new(ASL_TYPE_QUERY);
    
    asl_set_query(q, ASL_KEY_SENDER, [NSProcessInfo processInfo].processName.UTF8String, ASL_QUERY_OP_EQUAL);
    aslresponse r = asl_search(NULL, q);
    
    // TODO: do something smarter than rebuild this string every time
    while (NULL != (m = aslresponse_next(r)))
    {
        val = asl_get(m, ASL_KEY_MSG);
        
        NSString *string = [NSString stringWithUTF8String:val];
        
        [s appendString:string];
        [s appendString:@"\n"];
    }
    aslresponse_free(r);
    
    _logView.text = s;
}

-(void)timerFire:(NSTimer*)timer
{
    [self refreshLog];
}

@end
