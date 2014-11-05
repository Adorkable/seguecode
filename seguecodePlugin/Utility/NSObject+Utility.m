//
//  NSObject+Utility.m
//  seguecode
//
//  Created by Ian on 11/5/14.
//  Copyright (c) 2014 Adorkable. All rights reserved.
//

#import "NSObject+Utility.h"

NSString *const NSObjectUtilityClassInfoPropertyNamesKey = @"properties";
NSString *const NSObjectUtilityClassInfoMethodNamesKey = @"methods";
NSString *const NSObjectUtilityClassInfoIVarNamesKey = @"ivars";

@implementation NSObject (Utility)

+ (NSString *)propertyName:(objc_property_t)property
{
    const char *propertyName = property_getName(property);
    return [NSString stringWithCString:propertyName encoding:NSASCIIStringEncoding];
}

+ (NSString *)methodName:(Method)method
{
    NSString *result;
    
    SEL selector = method_getName(method);
    NSString *methodName = NSStringFromSelector(selector);
    if (methodName)
    {
        result = methodName;
    } else
    {
        result = [NSString stringWithFormat:@"Cannot find method %@", method];
    }

    return result;
}

+ (NSString *)ivarName:(Ivar)ivar
{
    const char* ivarName = ivar_getName(ivar);
    return [NSString stringWithCString:ivarName encoding:NSASCIIStringEncoding];
}

+ (NSDictionary *)classInfoForClass:(Class)class
{
    // based on: https://stackoverflow.com/questions/2299841/objective-c-introspection-reflection/2302808#2302808
    u_int count;
    
    objc_property_t* properties = class_copyPropertyList(class, &count);
    NSMutableArray* propertyArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count ; i++)
    {
        [propertyArray addObject:[self propertyName:properties[i] ] ];
    }
    free(properties);
    
    Method* methods = class_copyMethodList(class, &count);
    NSMutableArray* methodArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count ; i++)
    {
        [methodArray addObject:[self methodName:methods[i] ] ];
    }
    free(methods);
    
    Ivar* ivars = class_copyIvarList(class, &count);
    NSMutableArray* ivarArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count ; i++)
    {
        [ivarArray addObject:[self ivarName:ivars[i] ] ];
    }
    free(ivars);
    
    return @{
             NSObjectUtilityClassInfoPropertyNamesKey : propertyArray,
             NSObjectUtilityClassInfoMethodNamesKey : methodArray,
             NSObjectUtilityClassInfoIVarNamesKey : ivarArray
             };
}

+ (NSDictionary *)classInfoForClassName:(NSString *)name
{
    NSDictionary *result;
    
    Class class = NSClassFromString(name);
    if (class)
    {
        result = [self classInfoForClass:class];
    } else
    {
        result = @{@"error" : [NSString stringWithFormat:@"Cannot find class named %@", name]};
    }
    return result;
}

- (NSDictionary *)classInfo
{
    return [NSObject classInfoForClass:[self class] ];
}

- (id)valueForPropertyWithName:(NSString *)propertyName
{
    id result;
    
    @try
    {
        result = [self valueForKey:propertyName];
    } @catch (NSException *exception)
    {
        result = exception;
    }
    
    return result;
}

- (id)valueForMethodWithName:(NSString *)methodName
{
    id result;
    
    if ( [methodName rangeOfString:@":"].location == NSNotFound)
    {
        SEL selector = NSSelectorFromString(methodName);
        if (selector && [self respondsToSelector:selector] )
        {
            result = [self performSelector:selector];
        } else
        {
            result = [NSString stringWithFormat:@"Selector %@ not found in instance", NSStringFromSelector(selector) ];
        }
    } else
    {
        result = [NSString stringWithFormat:@"?"];
    }
    
    return result;
}

- (NSDictionary *)instanceInfo
{
    NSDictionary *classInfo = [self classInfo];

    NSArray *propertyNames = [classInfo objectForKey:NSObjectUtilityClassInfoPropertyNamesKey];
    NSMutableArray *propertiesWithValues = [NSMutableArray arrayWithCapacity:propertyNames.count];
    for (NSString *propertyName in propertyNames)
    {
        NSString *propertyWithValue = [NSString stringWithFormat:@"%@ = %@", propertyName, [self valueForPropertyWithName:propertyName] ];
        [propertiesWithValues addObject:propertyWithValue];
    }
    
    NSArray *methodNames = [classInfo objectForKey:NSObjectUtilityClassInfoMethodNamesKey];
    NSMutableArray *methodsWithValues = [NSMutableArray arrayWithCapacity:methodNames.count];
    for (NSString *methodName in methodNames)
    {
        NSString *methodWithValue = [NSString stringWithFormat:@"%@ = %@", methodName, [self valueForMethodWithName:methodName] ];
        [methodsWithValues addObject:methodWithValue];
    }
    
    NSArray *ivarNames = [classInfo objectForKey:NSObjectUtilityClassInfoIVarNamesKey];
    NSMutableArray *ivarsWithValues = [NSMutableArray arrayWithCapacity:ivarNames.count];
    for (NSString *ivarName in ivarNames)
    {
        NSString *ivarWithValue = [NSString stringWithFormat:@"%@ = %@", ivarName, [self valueForPropertyWithName:ivarName] ];
        [ivarsWithValues addObject:ivarWithValue];
    }
    
    return @{
             NSObjectUtilityClassInfoPropertyNamesKey : propertiesWithValues,
             NSObjectUtilityClassInfoMethodNamesKey : methodsWithValues,
             NSObjectUtilityClassInfoIVarNamesKey : ivarsWithValues
             };
}

@end
