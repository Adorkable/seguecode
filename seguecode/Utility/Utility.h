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

#import "NSString+seguecode.h"
#import "NSMutableString+seguecode.h"
#import "NSMutableDictionary+NilSafe.h"