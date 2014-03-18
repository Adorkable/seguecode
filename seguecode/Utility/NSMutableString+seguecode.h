//
//  NSMutableString+seguecode.h
//  seguecode
//
//  Created by Ian Grossberg on 3/18/14.
//  Copyright (c) 2014 Adorkable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableString (seguecode)

- (void)appendString:(NSString *)aString joinedWith:(NSString *)joinString;

@end
