//
//  RETouchViewController.m
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

#import "RETouchViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <asl.h>

@interface RETouchViewController ()

@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UITextView *logView;

// TODO: hacky, query log periodically, does ASL provide some sort of callback?
@property (nonatomic) NSTimer* logTimer;

@end

@implementation RETouchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.logView.text = @"";

    self.shadowView.frame = self.logView.frame;
    self.shadowView.clipsToBounds = NO;
    self.shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.shadowView.layer.shadowOpacity = 0.6f;
    self.shadowView.layer.shadowRadius = 5.0f;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.logTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerFire:) userInfo:nil repeats:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.logTimer invalidate];
    self.logTimer = nil;
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
    
    self.logView.text = s;
}

-(void)timerFire:(NSTimer*)timer
{
    [self refreshLog];
}

@end
