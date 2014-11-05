//
//  NSObject+Utility.h
//  seguecode
//
//  Created by Ian on 11/5/14.
//  Copyright (c) 2014 Adorkable. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <objc/runtime.h>

@interface NSObject (Utility)

+ (NSDictionary *)classInfoForClass:(Class)class;
+ (NSDictionary *)classInfoForClassName:(NSString *)name;
- (NSDictionary *)classInfo;
- (NSDictionary *)instanceInfo;

@end
