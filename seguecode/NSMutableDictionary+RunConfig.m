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

+ (NSString *)runConfigPathForStoryboardAtPath:(NSString *)storyboardPath
{
    return [NSString stringWithFormat:@"%@%@", [storyboardPath stringByDeletingPathExtension], RunConfigSuffix];
}

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
    return [NSMutableDictionary dictionaryWithContentsOfJSONFile:[self runConfigPathForStoryboardAtPath:storyboardPath] ];
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
    return [self writeContentsToJSONFile:[NSMutableDictionary runConfigPathForStoryboardAtPath:storyboardPath] ];
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

+ (BOOL)removeRunConfigForStoryboardAtPath:(NSString *)storyboardPath
{
    return [ [NSFileManager defaultManager] removeItemAtPath:[self runConfigPathForStoryboardAtPath:storyboardPath] error:nil];
}

@end
