//
//  NSMutableDictionary+RunConfig.m
//  seguecode
//
//  Created by Ian on 11/5/14.
//  Copyright (c) 2014 Adorkable. All rights reserved.
//

#import "NSMutableDictionary+RunConfig.h"

NSString *const RunConfigSuffix = @".seguecode.json";

@implementation NSMutableDictionary (RunConfig)

+ (NSMutableDictionary *)dictionaryWithContentsOfJSONFile:(NSString *)path
{
    return [self dictionaryWithContentsOfJSONURL:[ [NSURL alloc] initFileURLWithPath:path] ];
}

+ (NSMutableDictionary *)dictionaryWithContentsOfJSONURL:(NSURL *)url
{
    NSMutableDictionary *result;
    
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    NSError *error;
    if (data)
    {
        result = [NSJSONSerialization JSONObjectWithData:data
                                                 options:0
                                                   error:&error];
        
        if (error)
        {
            NSLog(@"Error when reading JSON config from %@", url);
        }
    }
    
    return result;
}

+ (NSMutableDictionary *)runConfigForStoryboardAtPath:(NSString *)storyboardPath
{
    NSString *configPath = [NSString stringWithFormat:@"%@%@", [storyboardPath stringByDeletingPathExtension], RunConfigSuffix];
    
    return [NSMutableDictionary dictionaryWithContentsOfJSONFile:configPath];
}

- (BOOL)writeContentsToJSONFile:(NSString *)path
{
    return [self writeContentsToJSONURL:[ [NSURL alloc] initFileURLWithPath:path] ];
}

- (BOOL)writeContentsToJSONURL:(NSURL *)url
{
    BOOL result = NO;
    
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self
                                                   options:0
                                                     error:&error];
    if (error)
    {
        NSLog(@"Error when writing JSON config from %@", url);
    }
    
    if (data)
    {
        result = [data writeToURL:url
                          options:NSDataWritingAtomic
                            error:&error];
    }
    
    return result;
}

- (BOOL)writeRunConfigForStoryboardAtPath:(NSString *)storyboardPath
{
    NSString *configPath = [NSString stringWithFormat:@"%@%@", [storyboardPath stringByDeletingPathExtension], RunConfigSuffix];
    
    return [self writeContentsToJSONFile:configPath];
}

+ (NSString *)outputDirectoryKey
{
    return @"outputDirectory";
}

- (void)setOutputDirectory:(NSString *)outputDirectory
{
    if (outputDirectory)
    {
        [self setObject:outputDirectory
                 forKey:[NSMutableDictionary outputDirectoryKey]
         ];
    } else
    {
        [self removeObjectForKey:[NSMutableDictionary outputDirectoryKey] ];
    }
}

- (NSString *)outputDirectory
{
    return [self objectForKey:[NSMutableDictionary outputDirectoryKey] ];
}

+ (NSString *)squashVCSKey
{
    return @"squashVCS";
}

- (void)setSquashVCS:(BOOL)squashVCS
{
    [self setObject:[NSNumber numberWithBool:squashVCS]
             forKey:[NSMutableDictionary squashVCSKey]
     ];
}

- (BOOL)squashVCS
{
    BOOL result;
    
    NSNumber *number = [self objectForKey:[NSMutableDictionary squashVCSKey] ];
    if (number != nil)
    {
        result = [number boolValue];
    } else
    {
        result = NO;
    }
    
    return result;
}

+ (NSString *)exportConstantsKey
{
    return @"exportConstants";
}

- (void)setExportConstants:(BOOL)exportConstants
{
    [self setObject:[NSNumber numberWithBool:exportConstants]
             forKey:[NSMutableDictionary exportConstantsKey]
     ];
}

- (BOOL)exportConstants
{
    BOOL result;
    
    NSNumber *number = [self objectForKey:[NSMutableDictionary exportConstantsKey] ];
    if (number != nil)
    {
        result = [number boolValue];
    } else
    {
        result = NO;
    }
    
    return result;
}

@end
