//
//  ViewController.m
//  SegueCodeExample
//
//  Created by Ian on 12/9/13.
//  Copyright (c) 2013 Adorkable. All rights reserved.
//

#import "FirstViewController.h"

#import "iOSExample-Swift.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (IBAction)goToUIViewController:(id)sender
{
    [self performFirstForwardToUIVCWithSender:sender];
}

@end
