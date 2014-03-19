//
//  NSMutableString+Utility.h
//  seguecode
//
//  Created by Ian Grossberg on 3/18/14.
//  Copyright (c) 2014 Adorkable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableString (Utility)

- (void)appendStringNilSafe:(NSString *)aString;
- (void)appendString:(NSString *)aString joinedWith:(NSString *)joinString;

@end
