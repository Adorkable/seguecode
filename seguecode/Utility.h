//
//  Utility.h
//  seguecode
//
//  Created by Ian on 12/10/13.
//  Copyright (c) 2013 Adorkable. All rights reserved.
//

#pragma once

#define XMLMappedProperty(name, attributeName) \
- (NSString *)name \
{ \
    return [self.element attribute:attributeName]; \
}

#import <CCTemplate/CCTemplate.h>

@interface NSString (seguecode)

- (NSString *)segueCodeTemplateFromDict:(NSDictionary *)dict;

@end
