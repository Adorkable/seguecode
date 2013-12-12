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

@interface SegueDefinition ()

@property (strong) RXMLElement *element;

@end

@implementation SegueDefinition

@synthesize source = _source;
@synthesize destination = _destination;

- (instancetype)initWithDefinition:(RXMLElement *)definitionElement andSource:(ViewControllerDefinition *)source
{
    if (definitionElement)
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
    return [NSString stringWithFormat:@"From%@%@To%@",
            self.source.storyboardIdentifier,
            self.identifier,
            self.destination.storyboardIdentifier];
}

- (NSString *)constantValue
{
    return self.identifier;
}
    
#define DefaultConstantDeclarationTemplate @"\
extern const NSString *<#(ConstantName)#>;"
    
#define DefaultConstantDefinitionTemplate @"\
const NSString *<#(ConstantName)#> = @\"<#(ConstantValue)#>\";"
    
- (NSString *)constantDeclaration
{
    return [DefaultConstantDeclarationTemplate segueCodeTemplateFromDict:[self templateMap] ];
}

- (NSString *)constantDefinition
{
    return [DefaultConstantDefinitionTemplate segueCodeTemplateFromDict:[self templateMap] ];
}
    
- (NSDictionary *)templateMap
{
    return @{
             @"ConstantName" : self.constantName,
             @"ConstantValue" : self.constantValue
             };
}

@end
