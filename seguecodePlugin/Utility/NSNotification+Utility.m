//
//  NSNotification+Utility.m
//  seguecode
//
//  Created by Ian on 11/5/14.
//  Copyright (c) 2014 Adorkable. All rights reserved.
//

#import "NSNotification+Utility.h"

@implementation NSNotification (Utility)

- (BOOL)isXcodeEvent
{
    return !( [ [self name] length] >= 2 && [ [ [self name] substringWithRange:NSMakeRange(0, 2) ] isEqualTo:@"NS"] );
}

+ (NSString *)transitionFromOneFileToAnotherName
{
    return @"transition from one file to another";
}

- (BOOL)isTransitionFromOneFileToAnother
{
    return [ [self name] isEqualToString:[NSNotification transitionFromOneFileToAnotherName] ];
}

- (NSDictionary *)transitionFromOneFileToAnotherInfo
{
    NSDictionary *result;
    if ( [self isTransitionFromOneFileToAnother] && [ [self object] isKindOfClass:[NSDictionary class] ] )
    {
        result = [self object];
    }
    return result;
}

- (id)transitionFromOneFileToAnotherNext
{
    id result;
    if ( [self isTransitionFromOneFileToAnother] )
    {
        NSDictionary *info = [self transitionFromOneFileToAnotherInfo];
        result = [info objectForKey:@"next"];
    }
    
    return result;
}

- (NSURL *)transitionFromOneFileToAnotherNextDocumentURL
{
    NSURL *result;
    
    if ( [self isTransitionFromOneFileToAnother] )
    {
        id nextObject = [self transitionFromOneFileToAnotherNext];
        Class DVTDocumentLocation = NSClassFromString(@"DVTDocumentLocation");
        if ( [nextObject isKindOfClass:DVTDocumentLocation] )
        {
            id documentURLObject = [nextObject performSelector:@selector(documentURL) ];
            if ( [documentURLObject isKindOfClass:[NSURL class] ] )
            {
                result = documentURLObject;
            }
        }
    }
    
    return result;
}

+ (NSString *)ideEditorDocumentDidSaveName
{
    return @"IDEEditorDocumentDidSaveNotification";
}

- (BOOL)isIDEEditorDocumentDidSave
{
    return [ [self name] isEqualToString:[NSNotification ideEditorDocumentDidSaveName] ];
}

@end
