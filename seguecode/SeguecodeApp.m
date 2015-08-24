//
//  SeguecodeApp.m
//  seguecode
//
//  Created by Ian on 12/9/13.
//  Copyright (c) 2013 Adorkable. All rights reserved.
//

#import "SeguecodeApp.h"

#import <DDGetoptLongParser.h>
#import <DDCliUtil.h>

#import "StoryboardFile.h"

#import "HeaderTemplate.h"

#define SegueCodeAppVersion @"1.1.1"

static SeguecodeApp *staticSharedDelegate;

@interface SeguecodeApp ()
{
    BOOL _squashVcs;
    
    BOOL _exportConstants;
    
    BOOL _help;
    BOOL _version;
}

@end

@implementation SeguecodeApp

@synthesize exportConstants = _exportConstants;

+ (SeguecodeApp *)sharedDelegate
{
    return staticSharedDelegate;
}

- (void)application:(DDCliApplication *)app willParseOptions:(DDGetoptLongParser *)optionsParser
{
    staticSharedDelegate = self;
    
    DDGetoptOption optionTable[] =
    {
        {"output-dir",     'o',    DDGetoptRequiredArgument},
        
        {"squash-vcs", 's', DDGetoptNoArgument},
        
        {"export-constants", 'c', DDGetoptNoArgument},
        
//        {"const-prefix",   'p',    DDGetoptOptionalArgument},
        
        {"help",       'h',    DDGetoptNoArgument},
        {"version",    'v',    DDGetoptNoArgument},
        {nil,           0,      0},
    };
    [optionsParser addOptionsFromTable: optionTable];
}

- (void)printUsage
{
    ddprintf(@"%@: Usage [OPTIONS] <argument> first.storyboard [second.storyboard...]\n", DDCliApp);
    ddprintf(@"  -o, --output-dir DIR         (Required) Specify location to save generated files\n"
             @"  -s, --squash-vcs             Store all UIViewController and subclass categories in one file\n"
             @"  -c, --export-constants       Include segue ID constants in the header\n"
//           @"  -p, --const-prefix PREFIX    Prefix to prepend to constant names\n"
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

    NSString *outputPath;
    if ( [self.outputDir length] > 0 && [self.outputDir characterAtIndex:0] == '/' )
    {
        outputPath = self.outputDir;
    } else
    {
        NSString *path = [ [NSFileManager defaultManager] currentDirectoryPath];
        outputPath = [NSString stringWithFormat:@"%@/%@", path, self.outputDir];
    }
    StoryboardFile *storyboardFile = [StoryboardFile storyboardFileAtPathFileName:pathFileName];
    if (storyboardFile != nil)
    {
        storyboardFile.exportViewControllersSeparately = !_squashVcs;
        
        [storyboardFile exportTo:outputPath withTemplateHeader:DefaultTemplateHeader andSource:DefaultTemplateSource];
        result = YES;
    } else
    {
        result = NO;
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
