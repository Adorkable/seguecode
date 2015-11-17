//
//  NSMutableDictionary+RunConfig.h
//  seguecode
//
//  Created by Ian on 11/5/14.
//  Copyright (c) 2014 Adorkable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (RunConfig)

+ (NSMutableDictionary *)dictionaryWithContentsOfJSONURL:(NSURL *)url;

+ (NSMutableDictionary *)runConfigForStoryboardAtURL:(NSURL *)storyboardURL;

@property (readwrite) NSString *outputPath;
@property (readwrite) BOOL combine;

@property (readwrite) NSString *projectName;

- (BOOL)writeContentsToJSONURL:(NSURL *)url;
- (BOOL)writeRunConfigForStoryboardAtURL:(NSURL *)storyboardURL;

+ (BOOL)removeRunConfigForStoryboardAtURL:(NSURL *)storyboardURL;

@end
