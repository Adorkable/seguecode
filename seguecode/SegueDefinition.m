//
//  SegueDefinition.m
//  seguecode
//
//  Created by Ian on 12/10/13.
//  Copyright (c) 2013 Adorkable. All rights reserved.
//

#import "SegueDefinition.h"

#import "ViewControllerDefinition.h"

#import <RaptureXML/RXMLElement.h>

#import "Utility.h"

#import "HeaderTemplate.h"

@interface SegueDefinition ()

@property (strong) RXMLElement *element;

@end

@implementation SegueDefinition

@synthesize source = _source;
@synthesize destination = _destination;

- (instancetype)initWithDefinition:(RXMLElement *)definitionElement andSource:(ViewControllerDefinition *)source
{
    if (definitionElement && ![ [definitionElement attribute:@"relationship"] isEqualToString:@"rootViewController"] )
    {
        self = [self init];
        if (self)
        {
            self.element = definitionElement;
            _source = source;
        }
    } else
    {
        self = nil;
    }
    return self;
}

+ (instancetype)definitionFrom:(RXMLElement *)definitionElement andSource:(ViewControllerDefinition *)source
{
    return [ [SegueDefinition alloc] initWithDefinition:definitionElement andSource:source];
}

- (void)setupDestinationFrom:(NSDictionary *)destinationDefinitions
{
    _destination = [destinationDefinitions objectForKey:self.destinationID];
}

XMLMappedProperty(id, @"id");
XMLMappedProperty(identifier, @"identifier");
XMLMappedProperty(destinationID, @"destination");
XMLMappedProperty(kind, @"kind");
XMLMappedProperty(customClass, @"customClass");
    
- (NSString *)constantName
{
    return [DefaultSegueConstant segueCodeTemplateFromDict:[self templateMapBySkipping:@[@"ConstantName"] ] ];
}

- (NSString *)constantValue
{
    return self.identifier;
}
    
- (NSString *)constantDeclaration
{
    return [DefaultSegueConstantDeclarationTemplate segueCodeTemplateFromDict:[self templateMap] ];
}

- (NSString *)constantDefinition
{
    return [DefaultSegueConstantDefinitionTemplate segueCodeTemplateFromDict:[self templateMap] ];
}
    
- (NSString *)selectorDeclarations
{
    return [DefaultSegueSelectorDeclaration segueCodeTemplateFromDict:[self templateMap] ];
}

- (NSString *)selectorDefinitions
{
    return [DefaultSegueSelectorDefinition segueCodeTemplateFromDict:[self templateMap] ];
}

- (NSDictionary *)templateMap
{
    return [self templateMapBySkipping:nil];
}

#define addIfNotSkipped(result, key, value, skipArray) \
    if ( ![skipArray containsObject:key] ) \
    {\
        [result setValue:value forKey:key];\
    }

- (NSDictionary *)templateMapBySkipping:(NSArray *)skipFields
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];

    addIfNotSkipped(result, @"SegueName", self.identifier, skipFields);
    addIfNotSkipped(result, @"ConstantName", self.constantName, skipFields);
    addIfNotSkipped(result, @"ConstantValue", self.constantValue, skipFields);
    addIfNotSkipped(result, @"SourceViewControllerName", self.source.storyboardIdentifier, skipFields);
    addIfNotSkipped(result, @"DestinationViewControllerName", self.destination.storyboardIdentifier, skipFields);
    
    return result;
}

@end
