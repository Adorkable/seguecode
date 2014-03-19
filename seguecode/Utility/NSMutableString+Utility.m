//
//  NSMutableString+Utility.m
//  seguecode
//
//  Created by Ian Grossberg on 3/18/14.
//  Copyright (c) 2014 Adorkable. All rights reserved.
//

#import "NSMutableString+Utility.h"

@implementation NSMutableString (Utility)

- (void)appendStringNilSafe:(NSString *)aString
{
    if (aString.length > 0)
    {
        [self appendString:aString];
    }
}

- (void)appendString:(NSString *)aString joinedWith:(NSString *)joinString
{
    if ( [aString length] > 0)
    {
        if ( [self length] == 0)
        {
            [self appendStringNilSafe:aString];
        } else
        {
            [self appendFormat:@"%@%@", joinString, aString];
        }
    }
}

@end