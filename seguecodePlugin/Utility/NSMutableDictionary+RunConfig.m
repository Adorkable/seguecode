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

+ (NSString *)outputPathKey
{
    return @"outputPath";
}

- (void)setOutputPath:(NSString *)outputPath
{
    if (outputPath)
    {
        [self setObject:outputPath
                 forKey:[NSMutableDictionary outputPathKey]
         ];
    } else
    {
        [self removeObjectForKey:[NSMutableDictionary outputPathKey] ];
    }
}

- (NSString *)outputPath
{
    return [self objectForKey:[NSMutableDictionary outputPathKey] ];
}

+ (NSString *)combineKey
{
    return @"combine";
}

- (void)setCombine:(BOOL)combine
{
    [self setObject:[NSNumber numberWithBool:combine]
             forKey:[NSMutableDictionary combineKey]
     ];
}

- (BOOL)combine
{
    BOOL result;
    
    NSNumber *number = [self objectForKey:[NSMutableDictionary combineKey] ];
    if (number != nil)
    {
        result = [number boolValue];
    } else
    {
        result = NO;
    }
    
    return result;
}

+ (NSString *)projectNameKey
{
    return @"projectName";
}

- (void)setProjectName:(NSString *)projectName
{
    if (projectName)
    {
        [self setObject:projectName
                 forKey:[NSMutableDictionary outputPathKey]
         ];
    } else
    {
        [self removeObjectForKey:[NSMutableDictionary projectNameKey] ];
    }
}

- (NSString *)projectName
{
    return [self objectForKey:[NSMutableDictionary projectNameKey] ];
}

+ (BOOL)removeRunConfigForStoryboardAtPath:(NSString *)storyboardPath
{
    return [ [NSFileManager defaultManager] removeItemAtPath:[self runConfigPathForStoryboardAtPath:storyboardPath] error:nil];
}

@end
