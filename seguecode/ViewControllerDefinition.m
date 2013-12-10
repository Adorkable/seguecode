//
//  ViewControllerDefinition.m
//  seguecode
//
//  Created by Ian on 12/10/13.
//  Copyright (c) 2013 Adorkable. All rights reserved.
//

#import "ViewControllerDefinition.h"

#import <RaptureXML/RXMLElement.h>

#import "SegueDefinition.h"

#import "Utility.h"

@interface ViewControllerDefinition ()
{
    NSMutableDictionary *_segues;
}

@property (strong) RXMLElement *element;

@end

@implementation ViewControllerDefinition

@synthesize segues = _segues;

- (instancetype)initWithDefinition:(RXMLElement *)definitionElement
{
    if (definitionElement)
    {
        self = [self init];
        if (self)
        {
            self.element = definitionElement;
            [self parseSegues];
        }
    } else
    {
        self = nil;
    }
    return self;
}

+ (instancetype)definitionFrom:(RXMLElement *)definitionElement
{
    return [ [ViewControllerDefinition alloc] initWithDefinition:definitionElement];
}

- (void)parseSegues
{
    _segues = [NSMutableDictionary dictionary];
    
    [_element iterate:@"connections" usingBlock:^(RXMLElement *connections)
    {
        [connections iterate:@"segue" usingBlock:^(RXMLElement *segue)
        {
            SegueDefinition *definition = [SegueDefinition definitionFrom:segue andSource:self];
            if (definition)
            {
                [_segues setObject:definition forKey:definition.id];
            }
        }];
    }];
}

XMLMappedProperty(id, @"id");
XMLMappedProperty(storyboardIdentifier, @"storyboardIdentifier");
XMLMappedProperty(customClass, @"customClass");
XMLMappedProperty(sceneMemberID, @"sceneMemberID");

@end
