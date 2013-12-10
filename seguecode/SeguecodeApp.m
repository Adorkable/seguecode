//
//  SeguecodeApp.m
//  seguecode
//
//  Created by Ian on 12/9/13.
//  Copyright (c) 2013 Adorkable. All rights reserved.
//

#import "SeguecodeApp.h"

#import <ddcli/DDGetoptLongParser.h>
#import <ddcli/DDCliUtil.h>

#import "StoryboardFile.h"

#define SegueCodeAppVersion @"1.0"

@interface SeguecodeApp ()
{
    BOOL _help;
    BOOL _version;
}

@end

@implementation SeguecodeApp

- (void)application:(DDCliApplication *)app willParseOptions:(DDGetoptLongParser *)optionsParser
{
    DDGetoptOption optionTable[] =
    {
        // Long         Short   Argument options
        {"output-dir",     'o',    DDGetoptRequiredArgument},
        
        {"const-prefix",   'p',    DDGetoptOptionalArgument},
        
        {"help",       'h',    DDGetoptNoArgument},
        {"version",    'v',    DDGetoptNoArgument},
        {nil,           0,      0},
    };
    [optionsParser addOptionsFromTable: optionTable];
}

- (void)printUsage
{
    ddprintf(@"%@: Usage [OPTIONS] <argument> first.storyboard [second.storyboard...]\n", DDCliApp);
/*    printf("\n"
           "  -m, --model MODEL             Path to model\n"
           "  -C, --configuration CONFIG    Only consider entities included in the named configuration\n"
           "      --base-class CLASS        Custom base class\n"
           "      --base-class-import TEXT        Imports base class as #import TEXT\n"
           "      --base-class-force CLASS  Same as --base-class except will force all entities to have the specified base class. Even if a super entity exists\n"
           "      --includem FILE           Generate aggregate include file for .m files for both human and machine generated source files\n"
           "      --includeh FILE           Generate aggregate include file for .h files for human generated source files only\n"
           "      --template-path PATH      Path to templates (absolute or relative to model path)\n"
           "      --template-group NAME     Name of template group\n"
           "      --template-var KEY=VALUE  A key-value pair to pass to the template file. There can be many of these.\n"
           "  -O, --output-dir DIR          Output directory\n"
           "  -M, --machine-dir DIR         Output directory for machine files\n"
           "  -H, --human-dir DIR           Output directory for human files\n"
           "      --list-source-files       Only list model-related source files\n"
           "      --orphaned                Only list files whose entities no longer exist\n"
           "      --version                 Display version and exit\n"
           "  -h, --help                    Display this help and exit\n"
           "\n"
           "Implements generation gap codegen pattern for Core Data.\n"
           "Inspired by eogenerator.\n");
 */
}

- (BOOL)exportStoryboardFile:(NSString *)fileName
{
    BOOL error = NO;
    
    NSString *pathFileName;
    if ( [fileName length] > 0 && [fileName characterAtIndex:0] )
    {
        pathFileName = fileName;
    } else
    {
        NSString *path = [ [NSFileManager defaultManager] currentDirectoryPath];
        pathFileName = [NSString stringWithFormat:@"%@/%@", path, fileName];
    }

    StoryboardFile *storyboardFile = [StoryboardFile storyboardFileAtPathFileName:pathFileName];
    if (storyboardFile != nil)
    {
    } else
    {
        error = YES;
    }
    return error;
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
        NSLog(@"%@ %@\n", DDCliApp, SegueCodeAppVersion);
        return EXIT_SUCCESS;
    }
    
    __block BOOL error = NO;
    [arguments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        if ( [obj isKindOfClass:[NSString class] ] )
        {
            if ( [self exportStoryboardFile:(NSString *)obj] )
            {
                error = YES;
            }
        }
    }];
    
    return error;
}

@end
