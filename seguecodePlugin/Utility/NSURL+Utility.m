//
//  NSURL+Utility.h
//  seguecodePlugin
//
//  Created by Ian Grossberg on 11/17/15.
//  Copyright © 2015 Adorkable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <stdarg.h>

@implementation NSURL (Utility)

+ (NSURL *)URLWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2)
{
    va_list args;
    va_start(args, format);
    NSString *resultingString = [ [NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    return [NSURL URLWithString:resultingString];
}

- (NSRange)rangeOfString:(NSString *)searchString
{
    NSString *selfAsString = [self absoluteString];
    return [selfAsString rangeOfString:searchString];
}

- (NSString *)pathWithSlashedSpaces
{
    NSString *path = [self path];
    
    return [path stringByReplacingOccurrencesOfString:@" " withString:@"\\\\ "];
}

@end
