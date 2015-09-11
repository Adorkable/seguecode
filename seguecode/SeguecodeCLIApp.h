//
//  SeguecodeCLIApp.h
//  seguecode
//
//  Created by Ian Grossberg on 8/24/15.
//  Copyright (c) 2015 Adorkable. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <DDCliApplication.h>

@interface SeguecodeCLIApp : NSObject<DDCliApplicationDelegate>

@property (readwrite, assign) NSString *outputPath;

@property (readwrite, assign) NSString *projectName;

@property (readonly) BOOL combine;

@property (readonly) BOOL verbose;

@end
