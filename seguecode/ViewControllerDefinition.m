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

#import "HeaderTemplate.h"

#import <TypeForKey/NSDictionary+TypeForKey.h>

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

XMLMappedProperty(viewControllerID, @"id");
XMLMappedProperty(storyboardIdentifier, @"storyboardIdentifier");
XMLMappedProperty(customClass, @"customClass");
XMLMappedProperty(sceneMemberID, @"sceneMemberID");

- (NSString *)customOrDefaultClass
{
    NSString *result = self.customClass;
    if (result.length == 0)
    {
        result = @"UIViewController";
    }
    return result;
}

- (NSArray *)segueConstantDeclarations
{
    NSMutableArray *result = [NSMutableArray array];
    for (id object in [self.segues allValues] )
    {
        if ( [object isKindOfClass:[SegueDefinition class] ] )
        {
            SegueDefinition* segueDefinition = (SegueDefinition *)object;
            [result addObject:[segueDefinition constantDeclaration] ];
        }
    }
    return result;
}
    
- (NSArray *)segueConstantDefinitions
{
    NSMutableArray *result = [NSMutableArray array];
    for (id object in [self.segues allValues] )
    {
        if ( [object isKindOfClass:[SegueDefinition class] ] )
        {
            SegueDefinition* segueDefinition = (SegueDefinition *)object;
            [result addObject:[segueDefinition constantDefinition] ];
        }
    }
    return result;
}

- (NSString *)categoryDeclarationImport:(NSString *)categoryName
{
    NSString *result;
    if (self.customClass)
    {
        result = [DefaultControllerCategoryDeclarationImport segueCodeTemplateFromDict:[self templateMap:categoryName] ];
    }
    return result;
}

- (NSString *)categoryDeclarations:(NSString *)categoryName
{
    NSString *result;
    NSDictionary *templateMap = [self templateMap:categoryName];
    
    if ( [ [templateMap stringForKey:@"SegueSelectorDeclarations"] length] > 0)
    {
        result = [DefaultControllerCategoryDeclaration segueCodeTemplateFromDict:[self templateMap:categoryName] ];
    }
    
    return result;
}

+ (NSString *)categorySection:(NSString *)sectionTemplate withCategoryName:(NSString *)categoryName forDefinitions:(NSArray *)definitions
{
    NSString *result;
    
    if (definitions.count > 0)
    {
        NSMutableString *segueSelectorDefinitions = [NSMutableString string];
        NSMutableString *segueSelectorDeclarations = [NSMutableString string];
        
        for (id object in definitions)
        {
            if ( [object isKindOfClass:[ViewControllerDefinition class] ] )
            {
                ViewControllerDefinition *definition = object;
                [segueSelectorDeclarations appendString:[definition segueSelectorDeclarations] joinedWith:@"\n"];
                [segueSelectorDefinitions appendString:[definition segueSelectorDefinitions] joinedWith:@"\n"];
            }
        }
        
        id object = [definitions firstObject];
        if ( [object isKindOfClass:[ViewControllerDefinition class] ] )
        {
            ViewControllerDefinition *definition = object;
            NSMutableDictionary *templateMap = [ [definition templateMap:categoryName] mutableCopy];
            
            [templateMap setObject:segueSelectorDeclarations forKey:@"SegueSelectorDeclarations"];
            [templateMap setObject:segueSelectorDefinitions forKey:@"SegueSelectorDefinitions"];
            
            result = [sectionTemplate segueCodeTemplateFromDict:templateMap];
        }
    }
    
    return result;
}

+ (NSString *)categoryDeclarations:(NSString *)categoryName forDefinitions:(NSArray *)definitions
{
    NSMutableString *result = [NSMutableString string];
    
    if (definitions.count > 0)
    {
        id object = [definitions firstObject];
        if ( [object isKindOfClass:[ViewControllerDefinition class] ] )
        {
            ViewControllerDefinition *definition = object;
            
            [result appendStringNilSafe:[definition categoryDeclarationImport:categoryName] ];
            
            [result appendString:[self categorySection:DefaultControllerCategoryDeclaration withCategoryName:categoryName forDefinitions:definitions] joinedWith:@"\n"];

        }
    }
    
    return result;
}

- (NSString *)categoryDefinitions:(NSString *)categoryName
{
    NSString *result;
    NSDictionary *templateMap = [self templateMap:categoryName];

    if ( [ [templateMap stringForKey:@"SegueSelectorDefinitions"] length] > 0)
    {
        result = [DefaultControllerCategoryDefinition segueCodeTemplateFromDict:templateMap ];
    }
    
    return result;
}

+ (NSString *)categoryDefinitions:(NSString *)categoryName forDefinitions:(NSArray *)definitions
{
    return [self categorySection:DefaultControllerCategoryDefinition withCategoryName:categoryName forDefinitions:definitions];
}

- (NSString *)segueSelectorDeclarations
{
    NSMutableString *result = [NSMutableString string];
    for (id object in [self.segues allValues] )
    {
        if ( [object isKindOfClass:[SegueDefinition class] ] )
        {
            SegueDefinition* segueDefinition = (SegueDefinition *)object;
            [result appendString:[segueDefinition selectorDeclarations]
                      joinedWith:@"\n"];
        }
    }
    return result;
}

- (NSString *)segueSelectorDefinitions
{
    NSMutableString *result = [NSMutableString string];
    for (id object in [self.segues allValues] )
    {
        if ( [object isKindOfClass:[SegueDefinition class] ] )
        {
            SegueDefinition* segueDefinition = (SegueDefinition *)object;
            [result appendString:[segueDefinition selectorDefinitions]
                      joinedWith:@"\n"];
        }
    }
    return result;
}

- (NSDictionary *)templateMap:(NSString *)categoryName
{
    return @{
             @"ViewControllerName" : self.customOrDefaultClass
             , @"StoryboardName" : categoryName
             , @"SegueSelectorDeclarations" : self.segueSelectorDeclarations
             , @"SegueSelectorDefinitions" : self.segueSelectorDefinitions
             };
}

@end
