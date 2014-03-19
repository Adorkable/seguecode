//
//  SecondViewController.m
//  seguecode
//
//  Created by Ian on 12/12/13.
//  Copyright (c) 2013 Adorkable. All rights reserved.
//

#import "SecondViewController.h"

#import "SecondViewController+Main_iPhone.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)segueToFirst:(id)sender
{
    [self segueBackToFirstFrom1stSecondFrom1stSecond];
}

@end
