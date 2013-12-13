//
//  ViewController.m
//  SegueCodeExample
//
//  Created by Ian on 12/9/13.
//  Copyright (c) 2013 Adorkable. All rights reserved.
//

#import "FirstViewController.h"

#import "Main_iPhone.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)segueToSecond:(id)sender
{
    [self performSegueWithIdentifier:FromFirstForwardToSecond sender:nil];
}

@end
