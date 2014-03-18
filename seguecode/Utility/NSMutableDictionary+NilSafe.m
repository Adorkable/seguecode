//
//  NSMutableDictionary+NilSafe.m
//  seguecode
//
//  Created by Ian Grossberg on 3/18/14.
//  Copyright (c) 2014 Adorkable. All rights reserved.
//

#import "NSMutableDictionary+NilSafe.h"

@implementation NSMutableDictionary (NilSafe)

- (BOOL)setObjectNilSafe:(id)anObject forKey:(id<NSCopying>)aKey
{
    BOOL result = NO;
    if (anObject && aKey)
    {
        result = YES;
        [self setObject:anObject forKey:aKey];
    }
    
    return result;
}

@end
