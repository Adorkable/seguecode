//
//  NSString+seguecode.m
//  seguecode
//
//  Created by Ian Grossberg on 3/18/14.
//  Copyright (c) 2014 Adorkable. All rights reserved.
//

#import "NSString+seguecode.h"

#import <CCTemplate/CCTemplate.h>

@implementation NSString (seguecode)

- (NSString *)segueCodeTemplateFromDict:(NSDictionary *)dict
{
    CCTemplate *parser = [ [CCTemplate alloc] init];
    parser.head = @"<#(";
    parser.tail = @")#>";
    return [parser scan:self dict:dict];
}

@end