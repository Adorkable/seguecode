//
//  SeguecodeCLIApp.m
//  seguecode
//
//  Created by Ian Grossberg on 8/24/15.
//  Copyright (c) 2015 Adorkable. All rights reserved.
//

#import "SeguecodeCLIApp.h"

#import <DDGetoptLongParser.h>
#import <DDCliUtil.h>

@import seguecodeKit;

#define SegueCodeAppVersion @"2.1.1"

@interface SeguecodeCLIApp ()
{
    BOOL _combine;
    
    BOOL _verbose;
    
    BOOL _help;
    BOOL _version;
}

@end

@implementation SeguecodeCLIApp

- (void)application:(DDCliApplication *)app willParseOptions:(DDGetoptLongParser *)optionsParser
{
    DDGetoptOption optionTable[] =
    {
        {"outputPath",     'o',    DDGetoptRequiredArgument},
        
        {"combine", 'c', DDGetoptNoArgument},
        
        {"projectName", 'p', DDGetoptRequiredArgument},
        
        {"verbose",    'l',    DDGetoptNoArgument},
        
        {"help",       'h',    DDGetoptNoArgument},
        {"version",    'v',    DDGetoptNoArgument},
        {nil,           0,      0},
    };
    [optionsParser addOptionsFromTable: optionTable];
}

- (void)printUsage
{
    ddprintf(@"%@: Usage [OPTIONS] <argument> first.storyboard [second.storyboard...]\n", DDCliApp);
    ddprintf(@"  -o, --outputPath DIR         (Required) Path to output generated files.\n"
             @"  -c, --combine                Export the View Controllers combined in one file\n"
             @"  -p, --projectName NAME       Name to use as project in source file header comment\n"
             @"\n"
             @"  -l, --verbose                Output verbose logging\n"
             @"\n"
             @"  -v, --version                Display seguecode's version\n"
             @"  -h, --help                   Display help\n");
}

- (BOOL)exportStoryboardFile:(NSString *)fileName
{
    BOOL result = NO;
    
    NSString *pathFileName;
    if ( [fileName length] > 0 && [fileName characterAtIndex:0] == '/' )
    {
        pathFileName = fileName;
    } else
    {
        NSString *path = [ [NSFileManager defaultManager] currentDirectoryPath];
        pathFileName = [NSString stringWithFormat:@"%@/%@", path, fileName];
    }
    NSURL *storyboardPathFileNameUrl = [NSURL fileURLWithPath:pathFileName];
    
    NSString *outputPath;
    if ( [self.outputPath length] > 0 && [self.outputPath characterAtIndex:0] == '/' )
    {
        outputPath = self.outputPath;
    } else
    {
        NSString *path = [ [NSFileManager defaultManager] currentDirectoryPath];
        outputPath = [NSString stringWithFormat:@"%@/%@", path, self.outputPath];
    }
    NSURL *outputPathUrl = [NSURL fileURLWithPath:outputPath];
    
    BOOL combine = _combine;
    BOOL verboseLogging = _verbose;
    
    if (outputPathUrl != nil)
    {
        result = YES;
        [seguecode parse:storyboardPathFileNameUrl outputPath:outputPathUrl projectName:self.projectName exportTogether:combine verboseLogging:verboseLogging];
    }

    return result;
}

- (int)application:(DDCliApplication *)app runWithArguments:(NSArray *)arguments
{
    if (_help)
    {
        [self printUsage];
        return EXIT_SUCCESS;
    }
    
    if (_version)
    {
        ddprintf(@"%@ %@\n", DDCliApp, SegueCodeAppVersion);
        return EXIT_SUCCESS;
    }
    
    __block BOOL error = NO;
    [arguments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         if ( [obj isKindOfClass:[NSString class] ] )
         {
             if ( ![self exportStoryboardFile:(NSString *)obj] )
             {
                 error = YES;
             }
         }
     }];
    
    return error;
}

@end
