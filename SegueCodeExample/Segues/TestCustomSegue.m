//
//  TestCustomSegue.m
//  TestStoryboard
//
//  Created by Ian on 12/9/13.
//  Copyright (c) 2013 Adorkable. All rights reserved.
//

#import "TestCustomSegue.h"

@implementation TestCustomSegue

- (void)perform
{
    UIViewController *sourceViewController = self.sourceViewController;
    UIViewController *destinationViewController = self.destinationViewController;
    
    [sourceViewController.view.superview addSubview:destinationViewController.view];

    destinationViewController.view.frame = CGRectMake(
                                                      sourceViewController.view.frame.origin.x + sourceViewController.view.frame.size.width,
                                                      0.0f,
                                                      destinationViewController.view.frame.size.width,
                                                      destinationViewController.view.frame.size.height
                                                      );
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         sourceViewController.view.transform = CGAffineTransformMakeTranslation(-sourceViewController.view.frame.size.width, 0.f);
         destinationViewController.view.transform = CGAffineTransformMakeTranslation(-destinationViewController.view.frame.size.width, 0.0f);
     }
                     completion:^(BOOL finished)
     {
         [destinationViewController.view removeFromSuperview];
         [sourceViewController presentViewController:destinationViewController animated:NO completion:nil];
     }];}

@end
