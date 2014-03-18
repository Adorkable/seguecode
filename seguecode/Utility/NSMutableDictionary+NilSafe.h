//
//  NSMutableDictionary+NilSafe.h
//  seguecode
//
//  Created by Ian Grossberg on 3/18/14.
//  Copyright (c) 2014 Adorkable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (NilSafe)

- (BOOL)setObjectNilSafe:(id)anObject forKey:(id<NSCopying>)aKey;

@end
