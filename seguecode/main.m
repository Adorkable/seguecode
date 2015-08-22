//
//  main.m
//  seguecode
//
//  Created by Ian Grossberg on 8/22/15.
//  Copyright (c) 2015 Adorkable. All rights reserved.
//

#import <Foundation/Foundation.h>

@import seguecodeKit;

int main(int argc, const char * argv[]) {
    
    @autoreleasepool {
        NSMutableArray *parameters = [NSMutableArray arrayWithCapacity:argc];
        
        for (int index = 0; index < argc; index ++) {
            NSString *parameter = [NSString stringWithCString:argv[index] encoding:NSUTF8StringEncoding];
            [parameters addObject:parameter];
        }
        [seguecode handleParametersAndRun:parameters];
    }
    
    [ [NSRunLoop currentRunLoop] run];
    
    return 0;
}