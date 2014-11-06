//
//  NSMutableDictionary+RunConfig.h
//  seguecode
//
//  Created by Ian on 11/5/14.
//  Copyright (c) 2014 Adorkable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (RunConfig)

+ (NSMutableDictionary *)dictionaryWithContentsOfJSONFile:(NSString *)path;
+ (NSMutableDictionary *)dictionaryWithContentsOfJSONURL:(NSURL *)url;

+ (NSMutableDictionary *)runConfigForStoryboardAtPath:(NSString *)storyboardPath;

@property (readwrite) NSString *outputDirectory;
@property (readwrite) BOOL squashVCS;
@property (readwrite) BOOL exportConstants;

- (BOOL)writeContentsToJSONFile:(NSString *)path;
- (BOOL)writeContentsToJSONURL:(NSURL *)url;
- (BOOL)writeRunConfigForStoryboardAtPath:(NSString *)storyboardPath;

@end
