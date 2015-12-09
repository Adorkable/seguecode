//
//  NSURL+Utility.h
//  seguecodePlugin
//
//  Created by Ian Grossberg on 11/17/15.
//  Copyright © 2015 Adorkable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (Utility)

+ (NSURL *)URLWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

- (NSRange)rangeOfString:(NSString *)searchString;

- (NSString *)pathWithSlashedSpaces;

@end
