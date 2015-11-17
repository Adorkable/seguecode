//
//  NSMutableDictionary+RunConfig.m
//  seguecode
//
//  Created by Ian on 11/5/14.
//  Copyright (c) 2014 Adorkable. All rights reserved.
//

#import "NSMutableDictionary+RunConfig.h"

#import "NSURL+Utility.h"

NSString *const RunConfigSuffix = @".seguecode.json";

@implementation NSMutableDictionary (RunConfig)

+ (NSURL *)runConfigPathForStoryboardAtURL:(NSURL *)storyboardURL
{
    return [NSURL URLWithFormat:@"%@%@", [storyboardURL URLByDeletingPathExtension], RunConfigSuffix];
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

+ (NSMutableDictionary *)runConfigForStoryboardAtURL:(NSURL *)storyboardURL
{
    return [NSMutableDictionary dictionaryWithContentsOfJSONURL:[self runConfigPathForStoryboardAtURL:storyboardURL] ];
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
        NSLog(@"Error when serializing JSON config: %@", error);
    }
    
    if (data)
    {
        result = [data writeToURL:url
                          options:NSDataWritingAtomic
                            error:&error];
        
        if (error)
        {
            NSLog(@"Error when writing JSON config to %@: %@", url, error);
        }
    }
    
    return result;
}

- (BOOL)writeRunConfigForStoryboardAtURL:(NSURL *)storyboardURL
{
    return [self writeContentsToJSONURL:[NSMutableDictionary runConfigPathForStoryboardAtURL:storyboardURL] ];
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
                 forKey:[NSMutableDictionary projectNameKey]
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

+ (BOOL)removeRunConfigForStoryboardAtURL:(NSURL *)storyboardURL
{
    return [ [NSFileManager defaultManager] removeItemAtURL:[self runConfigPathForStoryboardAtURL:storyboardURL] error:nil];
}

@end
